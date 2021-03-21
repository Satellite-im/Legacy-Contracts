// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Sticker is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public creator;
    uint public maxSupply;
    uint public price;

    modifier byCreator {
        require(msg.sender == creator, "Not allowed");
        _;
    }

    constructor(string memory tokenName, 
                string memory tokenSymbol,
                uint limit, 
                string memory uri,
                address stickerCreator,
                uint initialPrice
    ) ERC721(tokenName, tokenSymbol) {
        creator = stickerCreator;
        maxSupply = limit;
        price = initialPrice;

        _setBaseURI(uri);

        mintOne(stickerCreator);
    }

    function mintOne(address receiver) internal {
        require(_tokenIds.current() < maxSupply, "No more tokens to mint");
        
        uint newTokenId = _tokenIds.current();
        _mint(receiver, newTokenId);
        _setTokenURI(newTokenId, baseURI());
        _tokenIds.increment();
    }
    
    function addSet() public payable {
        require(msg.value == price, "Price value not reached");
        mintOne(msg.sender);
    }

    function setPrice(uint newPrice) public byCreator {
        price = newPrice;
    }

    function claim() public byCreator {
        msg.sender.transfer(address(this).balance);
    }
}

