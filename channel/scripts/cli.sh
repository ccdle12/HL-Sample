#!/bin/bash

# Create Channel
peer channel create -o ${ORDERER_DOMAIN}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem

# Join Peer to Channel 
peer channel join -b ${CHANNEL_NAME}.block

# Join ORG2 Peer to Channel
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG2_DOMAIN}/users/Admin@${ORG2_DOMAIN}/msp \ 
CORE_PEER_ADDRESS=${ORG2_DOMAIN}:${ORG2_PORT} \
CORE_PEER_LOCALMSPID=${ORG2_MSP} \
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG2_DOMAIN}/peers/peer0.${ORG2_DOMAIN}/tls/ca.crt \
peer channel join -b ${CHANNEL_NAME}.block

# Update ORG1 Anchor Peer
peer channel update -o ${ORDERER_DOMAIN}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f ./channel-artifacts/${ORG1_ANCHOR}.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem

# Update ORG2 Anchor Peer 
peer channel update -o ${ORDERER_DOMAIN}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f ./channel-artifacts/${ORG2_ANCHOR}.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${CHANNEL_DOMAIN}/orderers/${ORDERER_DOMAIN}/msp/tlscacerts/tlsca.${CHANNEL_DOMAIN}-cert.pem

# Install Chaincode
peer chaincode install -n ${CHAINCODE_NAME} -v 1.0 -p ${CHAINCODE_FOLDER}

# Keep CLI alive
sleep infinity