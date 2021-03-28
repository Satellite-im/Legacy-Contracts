// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Sticker.sol";

contract StickerFactory {
    address owner;
    address[] stickers;
    mapping(address => Artist) artists;
    
    struct Artist {
        address addr;
        string name;
        string signature;
        string description;
    }

    modifier byOwner {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    event NewSticker(address indexed setAddress, address indexed creator);

    constructor(){
        owner = msg.sender;
    }

    function createSticker(
        string memory tokenName, 
        string memory tokenSymbol,
        uint limit, 
        string memory uri,
        uint initialPrice
    ) public {
        require(limit > 0, "You need to mint at least 1 token");
        Sticker sticker = new Sticker(
            tokenName,
            tokenSymbol,
            limit,
            uri,
            msg.sender,
            initialPrice
        );

        stickers.push(address(sticker));

        emit NewSticker(address(sticker), msg.sender);
    }

    function getAvailableSets() public view returns (address[] memory) {
        return stickers;
    }

    function registerArtist(
        address artistAddr,
        string name,
        string signature,
        string description) public byOwner {
            Artist artist = new Artist(
                artistAddr,
                name,
                signature,
                description
            );
            artists[artistAddr] = artist;
    }
}

