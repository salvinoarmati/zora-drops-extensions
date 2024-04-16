// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";

import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {IERC721AUpgradeable} from "erc721a-upgradeable/IERC721AUpgradeable.sol";
import {Serials} from "./../../src/oviators/Serials.sol";
import {SerialsRenderer} from "./../../src/oviators/SerialsRenderer.sol";
import {IPFSRenderer} from "./../../src/oviators/IPFSRenderer.sol";

contract SerialsTest is Test {
    address constant VV      = 0xc8f8e2F59Dd95fF67c3d39109ecA2e2A017D4c8a;
    address constant JALIL   = 0xe11Da9560b51f8918295edC5ab9c0a90E9ADa20B;
    address constant HOLDER  = 0xb0161d9457f9E4EBEE1BF700dAA0001126158c68;
    uint256 constant OVIATOR = 460;

    ERC721Drop oviatorsV1 = ERC721Drop(payable(0x8991a2794cA6Fb1F0F7872b476Bb9f2FB800ADC1));
    Serials serials;
    SerialsRenderer serialsRenderer;

    function setUp() public {
        vm.startPrank(VV);

        // Deploy the renderer
        serialsRenderer = new SerialsRenderer({
            _description: "The possibility of digital provenance.",
            _imagesBase: "ipfs://bafybeiau63hogredyfwss5vwssk5sd4vznwcqcpefn45sebgzrd3qqumci/",
            _rendererBase: "ipfs://bafybeigyvmqmonqlvzyhegtjiuodqakdliqparxbom6f2svsqwtavwhwoy/?id=",
            _contractURI: "ipfs://bafkreihot37xklzclupz5ylqbq2kd3gwekxtxfppxshou4xlolruzyztzi"
        });

        // Deploy the new collection
        serials = new Serials({
            _source: address(oviatorsV1),
            _renderer: address(serialsRenderer)
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
        serials.claim(tokenIds, "OV-SILV-REG");

        vm.stopPrank();
    }

    function testExchangeWithApproval() public {
        vm.startPrank(JALIL);

        oviatorsV1.setApprovalForAll(address(serials), true);

        uint[] memory tokenIds = new uint[](1);
        tokenIds[0] = 460;

        serials.claim(tokenIds, "OV-SILV-REG");

        assertEq(serials.balanceOf(JALIL), 1);
        assertEq(serials.ownerOf(460), JALIL);

        string memory expectedMetadata = "data:application/json;base64,eyJuYW1lIjogIlNlcmlhbCAjNDYwIiwgImRlc2NyaXB0aW9uIjogIlRoZSBwb3NzaWJpbGl0eSBvZiBkaWdpdGFsIHByb3ZlbmFuY2UuIiwgImltYWdlIjogImlwZnM6Ly9iYWZ5YmVpYXU2M2hvZ3JlZHlmd3NzNXZ3c3NrNXNkNHZ6bndjcWNwZWZuNDVzZWJnenJkM3FxdW1jaS80NjAucG5nIiwgImFuaW1hdGlvbl91cmkiOiAiaXBmczovL2JhZnliZWlneXZtcW1vbnFsdnp5aGVndGppdW9kcWFrZGxpcXBhcnhib202ZjJzdnNxd3Rhdndod295Lz9pZD00NjAifQ==";
        assertEq(serials.tokenURI(460), expectedMetadata);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(460);

        vm.stopPrank();
    }

    function testExchangeManyWithApproval() public {
        vm.startPrank(HOLDER);

        oviatorsV1.setApprovalForAll(address(serials), true);

        uint[] memory tokenIds = new uint[](3);
        tokenIds[0] = 21;
        tokenIds[1] = 62;
        tokenIds[2] = 68;

        serials.claim(tokenIds, "OV-SILV-LG");

        assertEq(serials.balanceOf(HOLDER), 3);
        assertEq(serials.ownerOf(21), HOLDER);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(21);

        vm.expectRevert(IERC721AUpgradeable.OwnerQueryForNonexistentToken.selector);
        oviatorsV1.ownerOf(68);

        uint[] memory moreTokenIds = new uint[](1);
        moreTokenIds[0] = 73;
        vm.expectRevert(Serials.NoInventory.selector);
        serials.claim(moreTokenIds, "OV-SILV-LG");

        vm.stopPrank();
    }

    function testSetInventoryNotAllowed() public {
        string[] memory inventoryKeys = new string[](2);
        uint16[] memory inventoryCounts = new uint16[](2);

        inventoryKeys[0]   = "OV-SILV-REG";
        inventoryCounts[0] = 1;

        inventoryKeys[1]   = "OV-SILV-LG";
        inventoryCounts[1] = 1;

        vm.expectRevert("Ownable: caller is not the owner");
        serials.setInventory(inventoryKeys, inventoryCounts);
    }

    function testSetInventory() public {
        vm.startPrank(VV);

        // Set minimal Inventory
        string[] memory inventoryKeys = new string[](1);
        uint16[] memory inventoryCounts = new uint16[](1);

        inventoryKeys[0]   = "OV-SILV-LG";
        inventoryCounts[0] = 1;

        serials.setInventory(inventoryKeys, inventoryCounts);

        vm.stopPrank();
        vm.startPrank(HOLDER);

        oviatorsV1.setApprovalForAll(address(serials), true);

        uint[] memory tokenIds = new uint[](2);
        tokenIds[0] = 118;
        tokenIds[1] = 119;

        vm.expectRevert(Serials.NoInventory.selector);
        serials.claim(tokenIds, "OV-SILV-LG");

        uint[] memory tokenIds2 = new uint[](1);
        tokenIds2[0] = 118;

        serials.claim(tokenIds2, "OV-SILV-LG");

        uint[] memory tokenIds3 = new uint[](1);
        tokenIds3[0] = 119;

        vm.expectRevert(Serials.NoInventory.selector);
        serials.claim(tokenIds3, "OV-SILV-LG");

        // Increase inventory again
        string[] memory inventoryKeys2 = new string[](1);
        uint16[] memory inventoryCounts2 = new uint16[](1);

        inventoryKeys2[0]   = "OV-SILV-LG";
        inventoryCounts2[0] = 263;

        vm.startPrank(VV);
        serials.setInventory(inventoryKeys2, inventoryCounts2);
        vm.stopPrank();

        vm.startPrank(HOLDER);
        serials.claim(tokenIds3, "OV-SILV-LG");
        assertEq(serials.ownerOf(119), HOLDER);
        vm.stopPrank();

        vm.startPrank(VV);
        string[] memory inventoryKeys3 = new string[](1);
        uint16[] memory inventoryCounts3 = new uint16[](1);
        inventoryKeys3[0]   = "OV-SILV-LG";
        inventoryCounts3[0] = 1;

        vm.expectRevert(Serials.InventoryOverallocated.selector);
        serials.setInventory(inventoryKeys3, inventoryCounts3);
        vm.stopPrank();
    }

    function testSetRenderer() public {
        SerialsRenderer renderer = new SerialsRenderer(
            "Foo",
            "Bar",
            "Baz",
            "Huhu"
        );

        vm.expectRevert("Ownable: caller is not the owner");
        serials.setRenderer(address(renderer));

        vm.startPrank(VV);
        serials.setRenderer(address(renderer));
        vm.stopPrank();

        renderer.setDescription("Foo Bar Baz");
    }

    function testIPFSRenderer() public {
        vm.startPrank(VV);

        // Deploy the renderer
        IPFSRenderer renderer = new IPFSRenderer({
            _metadataCID: "bafybeieu6qloo6icryxfak2vflmzjr3izpyvdyjhb6cmucdcpv7zhxojnm",
            _contractCID: "bafkreihot37xklzclupz5ylqbq2kd3gwekxtxfppxshou4xlolruzyztzi"
        });

        // Deploy the new collection
        serials = new Serials({
            _source: address(oviatorsV1),
            _renderer: address(renderer)
        });

        assertEq(serials.tokenURI(9), "ipfs://bafybeieu6qloo6icryxfak2vflmzjr3izpyvdyjhb6cmucdcpv7zhxojnm/9");
        assertEq(serials.contractURI(), "ipfs://bafkreihot37xklzclupz5ylqbq2kd3gwekxtxfppxshou4xlolruzyztzi");

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

        serials.setInventory(inventoryKeys, inventoryCounts);
    }
}
