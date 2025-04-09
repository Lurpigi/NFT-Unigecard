// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract InfUnigeNFT is ERC1155, Ownable {

    string private _name = "InfUnigeNFT";
    uint8 private constant amount = 5; //number of cards to mint at once
    uint8 private constant numCard = 80; //number of cards
    uint8 private constant numCopiesNormalCard = 20; //max copies for each student card 20. id: [1-69] + 79 = 70
    uint8 private constant numCopiesSpecialCard = 10; //max copies for each specials card 10. id: 0 + [70-78] = 10
    uint8 private constant maxCards = 250; //max number of cards to mint, 60 packs of 5 cards

    bool internal locked;
    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }
    event Minted(address indexed to, uint256[] ids, uint256[] amounts);

    //TODO MAKE PRIVATE
    // total of 300 packs
    uint8[1500] public batchOrder; 

    uint16 private pointer;

    constructor() ERC1155("ipfs://bafybeifcu5xt7nkivxlspeis3tcvrshdsbz4balj66ersmoytp4z55lshy/{id}.json") Ownable(msg.sender){
        _setBatchOrder();
    }

    function _setBatchOrder() private {
        require(pointer == 0, "Batch already set");
        uint16 index;
        uint8 copies;
        for (uint8 id; id < numCard; id++) {
            copies = _isSpecial(id)? numCopiesSpecialCard : numCopiesNormalCard;
            for (uint8 j; j < copies; j++) {
                batchOrder[index++] = id;
            }
        }
       _shuffleBatchOrder();
    }

    function _isSpecial(uint8 id) private pure returns (bool) {
        if ((id >= 70 && id <= 78) || (id == 0)){
            return true;
        }
        return false;
    }

    function _isInPos(uint8 id, uint8[] memory ids, uint8 length) private pure returns (int8) {
        for (uint8 i; i < length; i++) {
            if (ids[i] == id) {
                return int8(i);
            }
        }
        return -1;
    }

    function _shuffleBatchOrder() private {
        for (uint256 i = 0; i < batchOrder.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, i))) % (batchOrder.length - i);
            uint8 temp = batchOrder[n];
            batchOrder[n] = batchOrder[i];
            batchOrder[i] = temp;
        }
    }

    
    function changeURI(string memory baseURI_) public onlyOwner {
        _setURI(baseURI_);
    }


    function mint(address to) public noReentrancy {
        require(pointer + amount <= batchOrder.length, "Not enough cards left");

        // Overestimate max size to amount, since we may push less
        uint8[] memory tempIds = new uint8[](amount);
        uint8[] memory tempAmounts = new uint8[](amount);
        uint8 uniqueCount = 0;

        for (uint8 i = 0; i < amount; i++) {
            uint8 cardId = batchOrder[pointer + i];
            int8 pos = _isInPos(cardId, tempIds, uniqueCount);
            if (pos == -1) {
                tempIds[uniqueCount] = cardId;
                tempAmounts[uniqueCount] = 1;
                uniqueCount++;
            } else {
                tempAmounts[uint8(pos)]++;
            }
        }

        pointer += amount;

        // Resize arrays to uniqueCount
        uint256[] memory ids = new uint256[](uniqueCount);
        uint256[] memory amounts = new uint256[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            ids[i] = tempIds[i];
            amounts[i] = tempAmounts[i];
        }

        _mintBatch(to, ids, amounts, "");
        emit Minted(to, ids, amounts);
    }
    
    function getNFTsOf(address user) public view returns (uint256[] memory, uint256[] memory) {
        uint256 count;
        for (uint256 i = 0; i < numCard; i++) {
            if (balanceOf(user, i) > 0) {
                count++;
            }
        }

        uint256[] memory ids = new uint256[](count);
        uint256[] memory amounts = new uint256[](count);
        uint256 index;

        for (uint256 i = 0; i < numCard; i++) {
            uint256 bal = balanceOf(user, i);
            if (bal > 0) {
                ids[index] = i;
                amounts[index] = bal;
                index++;
            }
        }

        return (ids, amounts);
    }

    function getMyNFTs() external view returns (uint256[] memory, uint256[] memory) {
        return getNFTsOf(msg.sender);
    }


    function uri(uint256 id) public view virtual override returns (string memory) {
        require(id < 80, "URI query for nonexistent token");
        return super.uri(id);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    

}