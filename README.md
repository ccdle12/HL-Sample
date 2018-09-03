# HL Sample

## Prerequisites
Make sure you have setup your environment according to the Hyper Ledger Fabric instructions located [here](https://hyperledger-fabric.readthedocs.io/en/release-1.2/getting_started.html)

* Replace ```channel/.env.example``` with an ```.env``` file containing your environment variables for 
your channel.

## Overview of running the project
* Update ```.env``` file in ```/channel``` to choose the chaincode to deploy
* Start the Network
* Exec into the CLI container
* Instantiate the Chaincode
* Call read/write queries on the Chaincode

## Getting Started
### Start the Network
```make```

### Stop the Network
```make clean```

## Chain Code
There are currently two Chaincodes that can be deployed:
* ```example02```
* ```marbles```

### example02
A very simple Chaincode that uses the default ```goleveldb```.

Update the ```.env``` file in ```/channel``` to install this Chaincode when running the network.

```
# Chain Code
CHAINCODE_FOLDER=github.com/chaincode/example02/
```

### marbles
This Chaincode creates ```marbles```, allowing users to create and transfer marbles to other users.
The Chaincode demonstrates the use of ```couchdb``` instead of the the default ```goleveldb```.

CouchDB allows for more complex reads from the Chaincode and for a dev environment, allows the dev
to view the state of the DB via the localhost.

```http://localhost:5984/_utils```

Update the ```.env``` file in ```/channel``` to install this Chaincode when running the network.

```
# Chain Code
CHAINCODE_FOLDER=github.com/chaincode/marbles/
```

## Use the CLI
When all the containers have been brought up, exec into the cli container:
```docker exec -it cli /bin/bash```

## Instantiate example02 Chaincode
Instantiate the Chaincode giving "a" 100 and "b" 200:

#### NOTE:

* ```-C``` = *Channel Name*
* ```-n``` = *Chaincode Name*
* ```-P``` = *Policy (Requires "endorsement" from peers, ```AND``` meaning both, ```OR``` meaning at least 1)*

```peer chaincode instantiate -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('${ORG1_MSP}.peer','${ORG2_MSP}.peer')"```

### Query the Chaincode
Query the Chaincode to check that "a" has received 100:

```peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["query","a"]}'```

### Invoke the Chain Code
Invoke the Chaincode by sending 10 tokens from "a" to "b"
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["invoke","a","b","10"]}'```

Call query on "a" again to check that the query returns ```90``` meaning ```10``` has been sent to ```b```

## Instantiate marbles Chaincode
#### Instantiate the Chaincode

```peer chaincode instantiate -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v 1.0 -c '{"Args":["init"]}' -P "OR ('${ORG1_MSP}.peer','${ORG2_MSP}.peer')"```

#### Initialize a couple of Marbles

```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["initMarble","marble1","blue","35","tom"]}'```

```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["initMarble","marble2","red","50","tom"]}'```

```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["initMarble","marble3","blue","70","tom"]}'```


#### Transfer Marbles
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["transferMarble","marble2","jerry"]}'```

#### Query the state of a Marble
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["readMarble","marble2"]}'```

#### Transfer Marbles by color
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["transferMarblesBasedOnColor","blue","jerry"]}'```

#### Delete a Marble
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["delete","marble1"]}'```

#### Query a Marbles history
```peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["getHistoryForMarble","marble1"]}'```

#### Query Marbles data according to owner
```peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["queryMarblesByOwner","jerry"]}'```
