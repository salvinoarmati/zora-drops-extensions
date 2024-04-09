
# RunNounsVision

An integration test for nouns vision that goes through all the steps for testing.
Meant to be run in simulation mode only.

```
creatorProxy=0xb9583D05Ba9ba8f7F14CCEe3Da10D2bc0A72f519 deployer=0x9444390c01Dd5b7249E53FAc31290F7dFF53450D forge script ./script/nouns-vision/RunNounsVisionMultistep.sol --rpc-url $ETH_RPC_GOERLI
```

# DeployNounsVision

Deploy:
```
deployer=$DEPLOYER_ACCOUNT forge script script/oviators/DeployOviatorsMultistep.sol:DeployOviators --rpc-url $RPC_URL --broadcast --interactives 1 --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

Variables:
```
creator_proxy= from https://github.com/ourzora/zora-drops-contracts/blob/main/addresses/1.json ZORA_NFT_CREATOR_PROXY change 1 to the network id
deployer= user deploying contracts
nouns_token= address to use as the nouns token
new_admin_address= address to set as the admin for the new drop contract. if the same as deployer, the address is not reset but if it's different permissions are removed from the deployer and set to this address

$ETH_RPC - RPC URI (per network)
$ETHERSCAN_API_KEY - get from etherscan.io for verification
```

# DeployOviators

Test locally:
```
anvil --fork-url https://mainnet.base.org --fork-block-number 12947075
```

Deploy locally:
```
deployer=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 oviators_v1_address=0x8991a2794ca6fb1f0f7872b476bb9f2fb800adc1 forge script script/oviators/DeployOviators.sol:DeployOviators --rpc-url http://127.0.0.1:8545 --broadcast --interactives 1
```
