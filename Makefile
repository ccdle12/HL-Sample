.PHONY: build gen env-up clean

# Channel Information
CHANNEL_NAME=mychannel
GENESIS=TwoOrgsOrdererGenesis
PROFILE=TwoOrgsChannel

# Crypto-Config and Channel Commands
OUT_BLO=-outputBlock
OUT_CHA=-outputCreateChannelTx
OUT_ANC=-outputAnchorPeersUpdate

# Channel Variables
ORG1_ANCHOR=Org1MSPanchors
ORG2_ANCHOR=Org2MSPanchors
ORG1_MSP=Org1MSP
ORG2_MSP=Org2MSP

default: clean build gen env-up

# build will build all the dependencies for the project
build:
	@echo "[Rebuilding Docker Images...]"
	@cd channel && docker-compose -f docker-compose-cli.yaml build

	@echo "[Building chaincode...]"
	@cd chaincode && go build -v ./...

# gen will generate all the channel artifacts and crypto configuration for the network
gen:
	@echo "[Generating crypto-certs...]"
	@cd channel && cryptogen generate --config=crypto-config.yaml

	@echo "[Building Genesis Block...]"
	@cd channel && configtxgen -profile $(GENESIS) $(OUT_BLO) ./channel-artifacts/genesis.block

	@echo "[Building channel transaction configuration...]"
	@cd channel && configtxgen -profile $(PROFILE) -channelID $(CHANNEL_NAME) $(OUT_CHA) ./channel-artifacts/channel.tx

	@echo "[Building the Anchor peers...]"
	@cd channel && configtxgen -profile $(PROFILE) -channelID $(CHANNEL_NAME) $(OUT_ANC) ./channel-artifacts/$(ORG1_ANCHOR).tx -asOrg $(ORG1_MSP)
	@cd channel && configtxgen -profile $(PROFILE) -channelID $(CHANNEL_NAME) $(OUT_ANC) ./channel-artifacts/$(ORG2_ANCHOR).tx -asOrg $(ORG2_MSP)

# env-up will launche the channel using the docker-compose file
env-up:
	@echo "[Starting environment...]"
	@cd channel && docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d
	@echo "[Environment up]"

# clean will tear down the docker network and remove any crypto,channel assets
clean:
	@echo "[Tearing down environment...]"
	@cd channel && docker-compose -f docker-compose-cli.yaml down --volumes --remove-orphans
	
	@echo "[Removing chaincode bins...]"
	@cd chaincode && rm chaincode || true

	@echo "[Removing all assets from channel-artifacts...]"
	@cd channel/channel-artifacts && rm -rf *

	@echo "[Removing all assets from crypto-config...]"
	@cd channel/crypto-config && rm -rf *
