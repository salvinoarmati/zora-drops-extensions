# DeployOviators

Test locally:
```
anvil --fork-url https://mainnet.base.org --fork-block-number 12947075
```

Deploy locally:
```
deployer=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 oviators_v1_address=0x8991a2794ca6fb1f0f7872b476bb9f2fb800adc1 forge script script/oviators/DeployOviators.sol:DeployOviators --rpc-url http://127.0.0.1:8545 --broadcast --interactives 1
```
