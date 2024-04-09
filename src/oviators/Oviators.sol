// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";

contract Oviators is ERC721, Ownable {
    ERC721Drop public immutable source;

    error OnlyExchange();
    error NotOwnedByClaimer();
    error NoInventory();

    struct ColorInfo {
        string color;
        uint128 claimedCount;
        uint128 maxCount;
    }

    event ExchangedTokens(address indexed sender, uint256 count, uint256[] tokenIds);

    mapping(string => ColorInfo) public colors;

    string description;
    string imagesBase;
    string rendererBase;
    string public contractURI;

    constructor(address _source) ERC721("Oviators", "$OVIATOR") {
        source = ERC721Drop(payable(_source));
    }

    function claim (uint256[] calldata tokenIds, string calldata color) external {
        uint128 count = uint128(tokenIds.length);

        // Make sure we have enough inventory
        if (colors[color].claimedCount + count > colors[color].maxCount) {
            revert NoInventory();
        }
        colors[color].claimedCount += count;

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

        emit ExchangedTokens({
            sender: msg.sender,
            count: count,
            tokenIds: tokenIds
        });
    }

    function setColorLimits(ColorInfo[] calldata colorInfos) external onlyOwner {
        uint256 count = colorInfos.length;

        for (uint256 i = 0; i < count;) {
            string memory color = colorInfos[i].color;
            require(
                colors[color].claimedCount <= colorInfos[i].maxCount,
                "Cannot decrease beyond claimed"
            );
            colors[color].maxCount = colorInfos[i].maxCount;

            unchecked {
                ++i;
            }
        }
    }

    function setDescription(string memory newDescription) external onlyOwner {
        description = newDescription;
    }

    function setImagesBase(string memory newBase) external onlyOwner {
        imagesBase = newBase;
    }

    function setRendererBase(string memory newBase) external onlyOwner {
        rendererBase = newBase;
    }

    function setContractURI(string memory newContractURI) external onlyOwner {
        contractURI = newContractURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                encodeMetadataJSON(
                    abi.encodePacked(
                        '{"name": "',
                        string(abi.encodePacked("Oviators ", tokenId)),
                        '", "description": "',
                        description,
                        '", "image": "',
                        string(abi.encodePacked(imagesBase, tokenId, ".png")),
                        '", "animation_uri": "',
                        string(abi.encodePacked(rendererBase, tokenId)),
                        '"}'
                    )
                )
            );
    }

    function totalSupply() external pure returns (uint256) {
        return 1717;
    }

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