// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {Oviators} from "../../src/oviators/Oviators.sol";

contract DeployOviators is Script, Test {
    function run() external {
        vm.startBroadcast(vm.envAddress("deployer"));

        // New collection
        Oviators oviators = new Oviators(vm.envAddress("oviators_v1_address"));

        // Set inventory of each glassas variant. Can also be done via etherscan
        // Quantities are from https://www.notion.so/Manufacturing-Details-d875dd12244d411eaf1343c1144e04c1
        Oviators.ColorInfo[] memory colorInfos = 
            new Oviators.ColorInfo[](4);

        colorInfos[0] = Oviators.ColorInfo({
            color: "OV-SILV-REG",
            claimedCount: 0,
            maxCount: 612
        });
        colorInfos[1] = Oviators.ColorInfo({
            color: "OV-SILV-LG",
            claimedCount: 0,
            maxCount: 263
        });
        colorInfos[2] = Oviators.ColorInfo({
            color: "OV-GOLD-REG",
            claimedCount: 0,
            maxCount: 612
        });
        colorInfos[3] = Oviators.ColorInfo({
            color: "OV-GOLD-LG",
            claimedCount: 0,
            maxCount: 263
        });
        oviators.setColorLimits(colorInfos);

        vm.stopBroadcast();
    }
}
