// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";

import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {Oviators} from "../../src/oviators/Oviators.sol";

contract DeployOviators is Script {
    Oviators oviators;

    function run() external {
        vm.startBroadcast(vm.envAddress("deployer"));

        // Deploy the new collection
        oviators = new Oviators({
            _source: vm.envAddress("oviators_v1_address"),
            _description: "The token description",
            _imagesBase: "ipfs://bafybeigrptpotjop47aptsruxngmpzfbqqc77ozntjc5ixms2iutcwrfpu/",
            _rendererBase: "ipfs://bafybeidwdlcqc2eidjqq7afzy3hctmpav3fnrf7g2zhatvznfaoktixvoe/?id=",
            _contractURI: "ipfs://CONTRACT_URI"
        });

        // Set the initial inventory for each physical category
        initializeInventory();

        vm.stopBroadcast();
    }

    // Set inventory of each glassas variant. Can also be done via etherscan
    // Quantities are from https://www.notion.so/Manufacturing-Details-d875dd12244d411eaf1343c1144e04c1
    function initializeInventory() internal {
        string[] memory inventoryKeys = new string[](4);
        uint16[] memory inventoryCounts = new uint16[](4);

        inventoryKeys[0]   = "OV-SILV-REG";
        inventoryCounts[0] = 612;

        inventoryKeys[1]   = "OV-SILV-LG";
        inventoryCounts[1] = 263;

        inventoryKeys[2]   = "OV-GOLD-REG";
        inventoryCounts[2] = 612;

        inventoryKeys[3]   = "OV-GOLD-LG";
        inventoryCounts[3] = 263;

        oviators.setInventory(inventoryKeys, inventoryCounts);
    }
}
