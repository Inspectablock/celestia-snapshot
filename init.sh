#!/bin/bash

# Check for dependencies
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v ethermintd > /dev/null 2>&1 || { echo >&2 "ethermintd not installed."; exit 1; }

if [[ -z "${NODE_URL}" ]]; then
  echo "usage NODE_URL=http://xxx.xxx.xxx.xxx:26659 ./init.sh"
  exit 1;
fi

# Start ethermintd
echo "Starting ethermintd ...."
NAMESPACE_ID=$(openssl rand -hex 8)
DA_BLOCK_HEIGHT=$(curl -s https://rpc-blockspacerace.pops.one/block | jq -r '.result.block.header.height')
ethermintd start --rollkit.aggregator true --rollkit.da_layer celestia --rollkit.da_config='{"base_url":"'$NODE_URL'","timeout":60000000000,"gas_limit":6000000,"fee":6000}' --rollkit.namespace_id $NAMESPACE_ID --rollkit.da_start_height $DA_BLOCK_HEIGHT &>/dev/null &
sleep 10

# To kill the above process
# kill $(ps aux | grep 'ethermint' | awk '{print $2}')

# Deploy the Polling contract
echo "Deploying polling contract ...."
PRIVATE_KEY=$(ethermintd keys unsafe-export-eth-key mykey --keyring-backend test)
RPC_URL=http://localhost:8545
forge script script/Polling.s.sol:PollingScript --fork-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

# Extract deployment address
CONTRACT_ADDRESS=$(jq -r '.transactions[0].contractAddress' broadcast/Polling.s.sol/9000/run-latest.json)
echo -e "\n=========================\nCONTRACT ADDRESS IS $CONTRACT_ADDRESS\n=========================\n\n"


# Install frontend dependencies
echo "Installing frontend ...."
cd frontend
yarn

cp .env.local.example .env.local
# Set address to deployed contract address
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/VITE_CONTRACT_ADDRESS=???/VITE_CONTRACT_ADDRESS='$CONTRACT_ADDRESS'/g' .env.local
else
    sed -i 's/VITE_CONTRACT_ADDRESS=???/VITE_CONTRACT_ADDRESS='$CONTRACT_ADDRESS'/g' .env.local
fi