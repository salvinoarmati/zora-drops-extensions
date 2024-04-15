// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Ownable}          from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings}          from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64}           from "@openzeppelin/contracts/utils/Base64.sol";
import {ISerialsRenderer} from "./ISerialsRenderer.sol";

contract SerialsRenderer is ISerialsRenderer, Ownable {

    /// @dev The description of each token.
    string description;

    /// @dev The base URI for the token images.
    string imagesBase;

    /// @dev The base URI for the generative art renderer.
    string rendererBase;

    /// @notice The metadata for the collection.
    string public contractURI;

    /// @dev Initialize the Serials collection by linking the pre-claim collection and images, metadata, ...
    constructor(
        string memory _description,
        string memory _imagesBase,
        string memory _rendererBase,
        string memory _contractURI
    ) {
        description  = _description;
        imagesBase   = _imagesBase;
        rendererBase = _rendererBase;
        contractURI = _contractURI;
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
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string memory id = Strings.toString(tokenId);

        return
            string(
                encodeMetadataJSON(
                    abi.encodePacked(
                        '{"name": "',
                        string(abi.encodePacked("Serial #", id)),
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
