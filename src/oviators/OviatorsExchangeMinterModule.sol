// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import {ERC721DropMinterInterface} from "./ERC721DropMinterInterface.sol";
// import {ERC721OwnerInterface} from "./ERC721OwnerInterface.sol";
import {IERC721Drop} from "zora-drops-contracts/interfaces/IERC721Drop.sol";
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";
import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {NFTMetadataRenderer} from "zora-drops-contracts/utils/NFTMetadataRenderer.sol";
import {MetadataRenderAdminCheck} from "zora-drops-contracts/metadata/MetadataRenderAdminCheck.sol";

/// @notice Exchanges one drop for another through burn mechanism
contract OviatorsExchangeMinterModule is
    IMetadataRenderer,
    MetadataRenderAdminCheck
{
    struct ColorInfo {
        uint128 claimedCount;
        uint128 maxCount;
    }

    struct ColorSetting {
        string color;
        uint128 maxCount;
    }

    event ExchangedTokens(
        address indexed sender,
        uint256 targetLength,
        uint256[] fromIds
    );

    event UpdatedColor(string color, ColorSetting settings);
    event UpdatedDescription(string newDescription);
    event UpdatedImagesBase(string newBase);
    event UpdatedRendererBase(string newBase);

    ERC721Drop public immutable source;
    ERC721Drop public immutable sink;

    string description;
    string imagesBase;
    string rendererBase;
    string public contractURI;

    mapping(string => ColorInfo) public colors;
    mapping(uint256 => string) public idToColor;

    constructor(
        IERC721Drop _source, 
        IERC721Drop _sink,
        string memory _imagesBase,
        string memory _rendererBase,
        string memory _description
    ) {
        source = ERC721Drop(payable(address(_source)));
        sink = ERC721Drop(payable(address(_sink)));
        description = _description;
        imagesBase = _imagesBase;
        rendererBase = _rendererBase;
    }

    uint128 public maxCount;

    function setDescription(string memory newDescription)
        external
        requireSenderAdmin(address(source))
    {
        description = newDescription;
        emit UpdatedDescription(newDescription);
    }

    function setImagesBase(string memory newBase)
        external
        requireSenderAdmin(address(source))
    {
        imagesBase = newBase;
        emit UpdatedImagesBase(newBase);
    }

    function setRendererBase(string memory newBase)
        external
        requireSenderAdmin(address(source))
    {
        rendererBase = newBase;
        emit UpdatedRendererBase(newBase);
    }

    function setContractURI(string memory newContractURI)
        external
        requireSenderAdmin(address(source))
    {
        contractURI = newContractURI;
    }

    // This is called along with the create callcode in the deployer contract as one
    // function call allowing the init to be a public function since it's within one transaction.
    // This function currently is a no-op
    function initializeWithData(bytes memory) external {
    }

    function setColorLimits(ColorSetting[] calldata colorSettings)
        external
        requireSenderAdmin(address(sink))
    {
        uint128 maxCountCache = maxCount;
        for (uint256 i = 0; i < colorSettings.length; ) {
            string memory color = colorSettings[i].color;
            require(
                colors[color].claimedCount <= colorSettings[i].maxCount,
                "Cannot decrease beyond claimed"
            );
            maxCountCache -= colors[color].maxCount;
            maxCountCache += colorSettings[i].maxCount;
            colors[color].maxCount = colorSettings[i].maxCount;

            emit UpdatedColor(color, colorSettings[i]);

            unchecked {
                ++i;
            }
        }
        maxCount = maxCountCache;
    }

    function exchange(uint256[] calldata fromIds, string memory color)
        external
    {
        require(
            source.isApprovedForAll(msg.sender, address(this)),
            "Exchange module is not approved to manage tokens"
        );
        uint128 targetLength = uint128(fromIds.length);
        require(
            colors[color].claimedCount + targetLength <= colors[color].maxCount,
            "Ran out of color"
        );
        colors[color].claimedCount += targetLength;

        // last minted token id
        for (uint256 i = 0; i < targetLength;) {
            require(source.ownerOf(fromIds[i]) == msg.sender, "Not owned by sender");

            // If the user (account) is able to burn then they also are able to exchange.
            // If they are not allowed, the burn call will fail.
            source.burn(fromIds[i]);

            // Transfer the token from the contract to the sender
            // Assumes token owned by collection contract + address(this) approved
            sink.transferFrom(address(this), msg.sender, fromIds[i]);

            unchecked {
                ++i;
            }
        }

        emit ExchangedTokens({
            sender: msg.sender,
            targetLength: targetLength,
            fromIds: fromIds
        });
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return
            NFTMetadataRenderer.createMetadataEdition({
                name: "Oviators", // Token ID is added by NFTMetadataRenderer
                description: description,
                imageURI: string(abi.encodePacked(imagesBase, tokenId, ".png")),
                animationURI: string(abi.encodePacked(rendererBase, tokenId)),
                tokenOfEdition: tokenId,
                editionSize: 0 // We don't want the NFTMetadataRenderer to name these editioned
            });
    }
}
