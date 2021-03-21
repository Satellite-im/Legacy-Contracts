// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISticker is IERC721 {
    function addSet() external;
    function setPrice(uint) external;
}

