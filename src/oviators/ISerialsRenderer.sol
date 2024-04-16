// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ISerialsRenderer {
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for collection contract.
     */
    function contractURI() external view returns (string memory);
}
