include .env

.PHONY: all test deploy

build:
	forge build

test:
	forge test

install:
	forge install foundry-rs/forge-std@v1.8.2 && \
	forge install smartcontractkit/chainlink-brownie-contracts && \
	forge install foundry-rs/forge-std@v1.8.2 && \
	forge install transmissions11/solmate

# MAKE SURE YOU HAVE DEPLOYED AND TESTED ON LOCAL (ANVIL) CHAIN BEFORE TESTNET
# AND THEN OBVIOUSLY TESTNET BEFORE MAINNET
deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --account default --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv