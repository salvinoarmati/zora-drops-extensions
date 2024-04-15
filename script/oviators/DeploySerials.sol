// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";

import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {Serials} from "../../src/oviators/Serials.sol";

contract DeploySerials is Script {
    Serials serials;

    function run() external {
        vm.startBroadcast(vm.envAddress("deployer"));

        // Deploy the new collection
        serials = new Serials({
            _source: vm.envAddress("oviators_v1_address"),
            _description: "The possibility of digital provenance.",
            _imagesBase: "ipfs://bafybeiau63hogredyfwss5vwssk5sd4vznwcqcpefn45sebgzrd3qqumci/",
            _rendererBase: "ipfs://bafybeigyvmqmonqlvzyhegtjiuodqakdliqparxbom6f2svsqwtavwhwoy/?id=",
            _contractURI: "ipfs://bafkreihot37xklzclupz5ylqbq2kd3gwekxtxfppxshou4xlolruzyztzi"
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

        serials.setInventory(inventoryKeys, inventoryCounts);
    }
}