// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//
//       ████████▄    ▄██████▄
//       ██████████  ██████████
//       ██████████  ██████████
//        ▀██████▀    ▀██████▀
//

import {Ownable}    from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721}     from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings}    from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64}     from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";

contract Oviators is ERC721, Ownable {

    /// @dev The pre-claim oviators contract. We'll burn these tokens in exchange for this new collection.
    ERC721Drop public immutable source;

    /// @dev Thrown when a pre-claim token isn't owned by the account requesting the exchange.
    error NotOwnedByClaimer();

    /// @dev Thrown when no tokens are left.
    error NoInventory();

    /// @dev Thrown when inventory is over-allocated.
    error InventoryOverallocated();

    /// @dev Emitted when one or many tokens have been exchanged/claimed.
    event ExchangedTokens(address indexed sender, string inventoryKey, uint256[] tokenIds);

    /// @dev Holds the inventory details for the physical glasses.
    struct InventoryItem {
        uint128 claimed;
        uint128 max;
    }

    /// @notice The inventory mapping of color identifiers to their amount info.
    mapping(string => InventoryItem) public inventory;

    /// @dev The description of each token.
    string description;

    /// @dev The base URI for the token images.
    string imagesBase;

    /// @dev The base URI for the generative art renderer.
    string rendererBase;

    /// @notice The metadata for the collection.
    string public contractURI;

    /// @dev Initialize the Oviators collection by linking the pre-claim collection and images, metadata, ...
    constructor(
        address _source,
        string memory _description,
        string memory _imagesBase,
        string memory _rendererBase,
        string memory _contractURI
    )
        ERC721("Oviators", "$OVIATOR")
    {
        source = ERC721Drop(payable(_source));
        description  = _description;
        imagesBase   = _imagesBase;
        rendererBase = _rendererBase;
        contractURI = _contractURI;
    }

    /// @notice Exchange a pre-claim Oviator token for the physical & post-claim collectible.
    /// @param tokenIds The tokens to exchange.
    /// @param inventoryKey Which inventory group to claim (e.g. color).
    function claim (uint256[] calldata tokenIds, string calldata inventoryKey) external {
        uint128 count = uint128(tokenIds.length);

        // Get the inventory
        InventoryItem storage inventoryItem = inventory[inventoryKey];

        // Make sure we have enough inventory
        if (inventoryItem.claimed + count > inventoryItem.max) {
            revert NoInventory();
        }

        // Echange each old token for its new counterpart
        for (uint128 i = 0; i < count;) {
            // Make sure the claimer is the owner of the original oviator
            if (source.ownerOf(tokenIds[i]) != msg.sender) {
                revert NotOwnedByClaimer();
            }

            // Burn the original oviator
            source.burn(tokenIds[i]);

            // Mint the new generative piece
            _mint(msg.sender, tokenIds[i]);

            unchecked {
                ++i;
            }
        }

        // Update inventory to reflect new claim
        inventoryItem.claimed += count;

        // Inform third parties about the new token claim
        emit ExchangedTokens({
            sender: msg.sender,
            inventoryKey: inventoryKey,
            tokenIds: tokenIds
        });
    }

    /// @notice Update the inventory for the physical counterparts.
    function setInventory(string[] calldata inventoryKeys, uint16[] calldata inventoryAmounts) external onlyOwner {
        uint256 count = inventoryKeys.length;

        for (uint256 i = 0; i < count;) {
            InventoryItem storage inventoryItem = inventory[inventoryKeys[i]];
            uint16 newMax = inventoryAmounts[i];

            if (inventoryItem.claimed > newMax) revert InventoryOverallocated();

            inventoryItem.max = newMax;

            unchecked {
              ++i;
            }
        }
    }

    /// @notice Set the description of the collection.
    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }

    /// @notice Set the base URL for the preview images.
    function setImagesBase(string memory _imagesBase) external onlyOwner {
        imagesBase = _imagesBase;
    }

    /// @notice Set the base URL for the token renderer.
    function setRendererBase(string memory _rendererBase) external onlyOwner {
        rendererBase = _rendererBase;
    }

    /// @notice Set the URL to the contract metadata.
    function setContractURI(string memory _contractURI) external onlyOwner {
        contractURI = _contractURI;
    }

    /// @notice Get the metadata for a given token.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory id = Strings.toString(tokenId);

        return
            string(
                encodeMetadataJSON(
                    abi.encodePacked(
                        '{"name": "',
                        string(abi.encodePacked("Oviators ", id)),
                        '", "description": "',
                        description,
                        '", "image": "',
                        string(abi.encodePacked(imagesBase, id, ".png")),
                        '", "animation_uri": "',
                        string(abi.encodePacked(rendererBase, id)),
                        '"}'
                    )
                )
            );
    }

    /// @notice The maximum amount of tokens to exist in this collection.
    function totalSupply() external pure returns (uint256) {
        return 1717;
    }

    /// @dev Render a JSON blob as a data-encoded url.
    function encodeMetadataJSON(bytes memory json) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(json)
                )
            );
    }
}
