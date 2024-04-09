// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import {ZoraNFTCreatorV1} from "zora-drops-contracts/ZoraNFTCreatorV1.sol";
import {ZoraNFTCreatorProxy} from "zora-drops-contracts/ZoraNFTCreatorProxy.sol";
import {ZoraFeeManager} from "zora-drops-contracts/ZoraFeeManager.sol";
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {IERC721Drop} from "zora-drops-contracts/interfaces/IERC721Drop.sol";
import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {FactoryUpgradeGate} from "zora-drops-contracts/FactoryUpgradeGate.sol";
import {EditionMetadataRenderer} from "zora-drops-contracts/metadata/EditionMetadataRenderer.sol";
import {DropMetadataRenderer} from "zora-drops-contracts/metadata/DropMetadataRenderer.sol";

import {ERC721OviatorsExchangeSwapMinter} from "../../src/oviators/ERC721OviatorsExchangeSwapMinter.sol";
import {OviatorsExchangeMinterModule} from "../../src/oviators/OviatorsExchangeMinterModule.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract DeployOviators is Script {
    ZoraNFTCreatorV1 creatorProxy;

    struct Addresses {
        address payable deployer;
        address oviatorsAddress;
        address oviatorsRedeemedAddress;
    }

    uint64 public constant MAX_DISCO_SUPPLY = 500;
    uint256 public constant PRICE_PER_DISCO = 0.19 ether;

    function run() external {
        // 1. Deploy our new redeemed collection (manually in Zora)
        // 2. Deploy our exchange minter module
        // 2a. Set inventory of each glasses variant (setColorLimits)
        // 3. Set our Minter Module as the Metadata Renderer on the new collection
        // 4. Mint our 1717 tokens on the new collection (airdropped to the exchange minter contract)

        Addresses memory adrs = Addresses({
            deployer: payable(vm.envAddress("deployer")),
            oviatorsAddress: vm.envAddress("oviators_address"), // Token before redemption
            oviatorsRedeemedAddress: vm.envAddress("oviators_address_redeemed") // Token after redemption
        });

        vm.startBroadcast(adrs.deployer);

        // Deploy our exchange minter module
        OviatorsExchangeMinterModule exchangeMinterModule = new OviatorsExchangeMinterModule({
            _source: IERC721Drop(adrs.oviatorsAddress),
            _sink: IERC721Drop(adrs.oviatorsRedeemedAddress),
            _imagesBase: "ipfs://bafybeigrptpotjop47aptsruxngmpzfbqqc77ozntjc5ixms2iutcwrfpu/",
            _rendererBase: "ipfs://bafybeidwdlcqc2eidjqq7afzy3hctmpav3fnrf7g2zhatvznfaoktixvoe/?id=",
            _description: "~~~TODO~~~" // FIXME: alskdfjalskdfa;ldkf
        });
        
        // Set inventory of each glassas variant. Can also be done via etherscan
        // Quantities are from https://www.notion.so/Manufacturing-Details-d875dd12244d411eaf1343c1144e04c1
        OviatorsExchangeMinterModule.ColorSetting[] memory colorSettings = 
            new OviatorsExchangeMinterModule.ColorSetting[](4);

        colorSettings[0] = OviatorsExchangeMinterModule.ColorSetting({
            color: "OV-SILV-REG",
            maxCount: 612
        });
        colorSettings[1] = OviatorsExchangeMinterModule.ColorSetting({
            color: "OV-SILV-LG",
            maxCount: 263
        });
        colorSettings[2] = OviatorsExchangeMinterModule.ColorSetting({
            color: "OV-GOLD-REG",
            maxCount: 612
        });
        colorSettings[3] = OviatorsExchangeMinterModule.ColorSetting({
            color: "OV-GOLD-LG",
            maxCount: 263
        });
        exchangeMinterModule.setColorLimits(colorSettings);

        // Sets redeemed metadata renderer and updates address of underlying redeemed edition
        ERC721Drop(payable(adrs.oviatorsRedeemedAddress)).setMetadataRenderer(exchangeMinterModule, "");

        // Admin mint our 1717 tokens to the exchange minter module
        ERC721Drop(payable(adrs.oviatorsRedeemedAddress)).adminMint(address(exchangeMinterModule), 1717);

        vm.stopBroadcast();
    }
}
