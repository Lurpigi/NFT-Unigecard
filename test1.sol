// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HouseToken is ERC721, Ownable {
    uint8 private _nextTokenId;
    uint8 constant TOKEN_CAP = 2;
    string public baseURI;

    constructor(address initialOwner,string memory baseURI_)
        ERC721("ProvaNFT2", "PFT")
        Ownable(initialOwner)
        {
            baseURI = baseURI_;
        }

    function changeURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function safeMint(address to) public onlyOwner {
        require (_nextTokenId < TOKEN_CAP, "Token cap exceeded");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json"));
    }
}