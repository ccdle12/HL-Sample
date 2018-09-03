# HL Sample

## Prerequisites
Make sure you have setup your environment according to the Hyper Ledger Fabric instructions located [here](https://hyperledger-fabric.readthedocs.io/en/release-1.2/getting_started.html)

* Replace ```channel/.env.example``` with an ```.env``` file containing your environment variables for 
your channel.

## Getting Started
### Start the Network
```make```

### Stop the Network
```make clean```

## Chain Code
When all the containers have been brought up, exec into the cli container:
```docker exec -it cli /bin/bash```

### Instantiate the Chain Code
Instantiate the Chain Code giving "a" 100 and "b" 200:

#### NOTE:

* ```-C``` = *Channel Name*
* ```-n``` = *Chain Code Name*
* ```-P``` = *Policy (Requires "endorsement" from peers, ```AND``` meaning both, ```OR``` meaning at least 1)*

```peer chaincode instantiate -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('${ORG1_MSP}.peer','${ORG2_MSP}.peer')"```

### Query the Chain Code
Query the Chain Code to check that "a" has received 100:

```peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["query","a"]}'```

### Invoke the Chain Code
Invoke the Chain Code by sending 10 tokens from "a" to "b"
```peer chaincode invoke -o ${ORDERER_DOMAIN}:${ORDERER_PORT} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["invoke","a","b","10"]}'```

Call query on "a" again to check that the query returns ```90``` meaning ```10``` has been sent to ```b```
