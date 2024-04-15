// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinaryPatterns {
    // Function to calculate the length of the binary representation
    function binaryLength(uint n) private pure returns (uint) {
        uint length = 0;
        while (n != 0) {
            length++;
            n >>= 1;
        }
        return length;
    }

    // Function to check if the binary representation is a palindrome
    function isBinaryPalindrome(uint n) private pure returns (bool) {
        uint reversed = 0;
        uint original = n;
        while (n != 0) {
            reversed = (reversed << 1) | (n & 1);
            n >>= 1;
        }
        return original == reversed;
    }

    // Function to check if all bits are 1
    function onlyOnes(uint n) private pure returns (bool) {
        if (n == 0) return false; // No bits set
        // Check if n+1 is a power of two, which implies n is all ones
        uint plusOne = n + 1;
        return (plusOne & n) == 0;
    }

    // Function to check if the binary pattern is alternating
    function isAlternating(uint n) private pure returns (bool) {
        if (n == 0 || n == 1) return true;
        // Check if every pair of bits is 01 or 10
        uint mask = 3; // Binary 11
        while (n != 0 && n != 1) {
            if ((n & mask) != 1 && (n & mask) != 2) return false;
            n >>= 1;
        }
        return true;
    }

    // Main function to get binary patterns
    function binaryPatterns(uint n) public pure returns (uint length, bool palindrome, bool allOnes, bool alternating) {
        length = binaryLength(n);
        palindrome = isBinaryPalindrome(n);
        allOnes = onlyOnes(n);
        alternating = isAlternating(n);
        return (length, palindrome, allOnes, alternating);
    }
}
