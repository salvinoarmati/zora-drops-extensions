// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";

import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {IERC721AUpgradeable} from "erc721a-upgradeable/IERC721AUpgradeable.sol";
import {Oviators} from "./../../src/oviators/Oviators.sol";

contract OviatorsTest is Test {
    address constant VV      = 0xc8f8e2F59Dd95fF67c3d39109ecA2e2A017D4c8a;
    address constant JALIL   = 0xe11Da9560b51f8918295edC5ab9c0a90E9ADa20B;
    address constant HOLDER  = 0xb0161d9457f9E4EBEE1BF700dAA0001126158c68;
    uint256 constant OVIATOR = 460;

    ERC721Drop oviatorsV1 = ERC721Drop(payable(0x8991a2794cA6Fb1F0F7872b476Bb9f2FB800ADC1));
    Oviators oviators;

    function setUp() public {
        vm.startPrank(VV);

        // Deploy the new collection
        oviators = new Oviators({
            _source: address(oviatorsV1),
            _description: "The token description",
            _imagesBase: "ipfs://bafybeigrptpotjop47aptsruxngmpzfbqqc77ozntjc5ixms2iutcwrfpu/",
            _rendererBase: "ipfs://bafybeidwdlcqc2eidjqq7afzy3hctmpav3fnrf7g2zhatvznfaoktixvoe/?id=",
            _contractURI: "ipfs://CONTRACT_URI"
        });

        // Set the initial inventory for each physical category
        initializeInventory();

        vm.stopPrank();
    }

    function testExchangeBeforeApproval() public {
        vm.startPrank(JALIL);

        uint[] memory tokenIds = new uint[](1);
        tokenIds[0] = 460;

        vm.expectRevert(IERC721AUpgradeable.TransferCallerNotOwnerNorApproved.selector);
        oviators.claim(tokenIds, "OV-SILV-REG");

        vm.stopPrank();
    }

    function testExchangeWithApproval() public {
        vm.startPrank(JALIL);

        oviatorsV1.setApprovalForAll(address(oviators), true);

        uint[] memory tokenIds = new uint[](1);
        tokenIds[0] = 460;

        oviators.claim(tokenIds, "OV-SILV-REG");

        assertEq(oviators.balanceOf(JALIL), 1);
        assertEq(oviators.ownerOf(460), JALIL);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(460);

        vm.stopPrank();
    }

    function testExchangeManyWithApproval() public {
        vm.startPrank(HOLDER);

        oviatorsV1.setApprovalForAll(address(oviators), true);

        uint[] memory tokenIds = new uint[](3);
        tokenIds[0] = 21;
        tokenIds[1] = 62;
        tokenIds[2] = 68;

        oviators.claim(tokenIds, "OV-SILV-LG");

        assertEq(oviators.balanceOf(HOLDER), 3);
        assertEq(oviators.ownerOf(21), HOLDER);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(21);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(68);

        uint[] memory moreTokenIds = new uint[](1);
        moreTokenIds[0] = 73;
        vm.expectRevert(Oviators.NoInventory.selector);
        oviators.claim(moreTokenIds, "OV-SILV-LG");

        vm.stopPrank();
    }

    // Set inventory of each glassas variant. Can also be done via etherscan
    // Quantities are from https://www.notion.so/Manufacturing-Details-d875dd12244d411eaf1343c1144e04c1
    function initializeInventory() internal {
        string[] memory inventoryKeys = new string[](4);
        uint16[] memory inventoryCounts = new uint16[](4);

        inventoryKeys[0]   = "OV-SILV-REG";
        inventoryCounts[0] = 612;

        inventoryKeys[1]   = "OV-SILV-LG";
        inventoryCounts[1] = 3;

        inventoryKeys[2]   = "OV-GOLD-REG";
        inventoryCounts[2] = 612;

        inventoryKeys[3]   = "OV-GOLD-LG";
        inventoryCounts[3] = 263;

        oviators.setInventory(inventoryKeys, inventoryCounts);
    }
}
