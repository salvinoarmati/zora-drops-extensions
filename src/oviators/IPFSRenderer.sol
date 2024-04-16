// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Ownable}          from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings}          from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64}           from "@openzeppelin/contracts/utils/Base64.sol";
import {ISerialsRenderer} from "./ISerialsRenderer.sol";

contract IPFSRenderer is ISerialsRenderer, Ownable {

    /// @dev The base URI for the token metadata.
    string metadataCID;

    /// @notice The metadata for the collection.
    string contractCID;

    /// @dev Initialize the Serials collection by linking the pre-claim collection and images, metadata, ...
    constructor(string memory _metadataCID, string memory _contractCID) {
        metadataCID  = _metadataCID;
        contractCID = _contractCID;
    }

    /// @notice Set the CID of our metadata collection.
    function setMetadataCID(string memory _metadataCID) external onlyOwner {
        metadataCID = _metadataCID;
    }

    /// @notice Set the URL to the contract metadata.
    function setContractCID(string memory _contractCID) external onlyOwner {
        contractCID = _contractCID;
    }

    /// @notice Get the metadata for the collection.
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked("ipfs://", contractCID));
    }

    /// @notice Get the metadata for a given token.
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked("ipfs://", metadataCID, "/", Strings.toString(tokenId)));
    }

}
