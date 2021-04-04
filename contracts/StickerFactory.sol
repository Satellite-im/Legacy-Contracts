// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Sticker.sol";

contract StickerFactory {
    struct Artist {
        address addr;
        string name;
        string signature;
        string description;
    }

    struct StickerInfo {
        address stickerContract;
        address creator;
    }

    address owner;
    StickerInfo[] stickers;
    mapping(address => Artist) public artists;

    modifier byOwner {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    modifier byArtist {
        require(artists[msg.sender].addr != address(0), "Not allowed");
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
    ) public byArtist {
        require(limit > 0, "You need to mint at least 1 token");
        Sticker sticker = new Sticker(
            tokenName,
            tokenSymbol,
            limit,
            uri,
            msg.sender,
            initialPrice
        );

        stickers.push(StickerInfo(address(sticker), msg.sender));

        emit NewSticker(address(sticker), msg.sender);
    }

    function getAvailableSets() public view returns (StickerInfo[] memory) {
        return stickers;
    }

    function registerArtist(
        address artistAddr,
        string memory name,
        string memory signature,
        string memory description) public byOwner {
            Artist memory artist = Artist({
                addr: artistAddr,
                name: name,
                signature: signature,
                description: description
            });
            artists[artistAddr] = artist;
    }
}

