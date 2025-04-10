// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract InfUnigeNFT is Initializable, ERC1155Upgradeable, Ownable2StepUpgradeable, ERC2981Upgradeable, UUPSUpgradeable {
    
    bytes32 private constant _name = "InfUnigeNFT";
    uint8 public constant amount = 5; //number of cards to mint at once
    uint8 public constant numCard = 80; //number of cards
    uint8 public constant numCopiesNormalCard = 20; //max copies for each student card 20. id: [1-69] + 79 = 70
    uint8 public constant numCopiesSpecialCard = 10; //max copies for each specials card 10. id: 0 + [70-78] = 10
    uint8 public constant maxCards = 250; //max number of cards to mint, 60 packs of 5 cards

    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;
    uint8 private _status = _NOT_ENTERED;

    uint256 public MINT_FEE = 0.05 ether;
    uint96 public royaltyBasis = 1000;

    modifier noReentrancy() {
        require(_status == _NOT_ENTERED, "Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    event Minted(address indexed to, uint256[] ids, uint256[] amounts, uint8 packsOpened);
    event Withdrawn(address indexed to, uint256 value);
    event FeeChanged(uint256 newFees);
    event BaseUriChanged(string baseURI_);

    error DeploymentWithETH(uint256 amount);
    error MaxCardsReached();
    error NotEnoughCardsLeft();
    error InvalidRecipient();

    // total of 300 packs
    uint16 private constant batchOrderLength = 1500; //uint16(70 * uint16(numCopiesNormalCard) + 10 * uint16(numCopiesSpecialCard));
    bytes private batchOrder; 

    uint16 private pointer;

    // @custom:oz-upgrades-unsafe-allow constructor
    //payable because fee, solidityscan docet
    constructor() payable{
        if (msg.sender == address(0)) revert InvalidRecipient();
        // Revert and refund ETH if any was sent, payable constructor cost less
        if (msg.value != 0) {
            (bool success, ) = msg.sender.call{value: msg.value}("");
            require(success, "ETH refund failed");
            revert DeploymentWithETH(msg.value);
        }
        _disableInitializers(); //set the contract state to not initialized
    }

    function initialize() public initializer {
        __ERC1155_init("ipfs://bafybeifcu5xt7nkivxlspeis3tcvrshdsbz4balj66ersmoytp4z55lshy/{id}.json");
        __Ownable_init(msg.sender);
        __ERC2981_init();
        __UUPSUpgradeable_init();

        pointer = 1;
        _status = _NOT_ENTERED;
        MINT_FEE = 0.05 ether;
        royaltyBasis = 1000;

        batchOrder = _setBatchOrder();
        require(batchOrder.length == batchOrderLength, "Invalid batch length");
        _setDefaultRoyalty(msg.sender, royaltyBasis); // 1000 = 10% in basis points
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


    function _setBatchOrder() private view returns (bytes memory) {
        require(pointer == 1, "Batch already set");
        //cost less gas doing ops on memory, not storage
        bytes memory batch = new bytes(batchOrderLength);
        uint16 index;
        uint8 copies;
        for (uint8 id; id < numCard;) {
            copies = _isSpecial(id)? numCopiesSpecialCard : numCopiesNormalCard;
            for (uint8 j; j < copies;) {
                batch[index] = bytes1(id); // cast uint8 -> bytes1
                unchecked { ++j;++index; }
            }
            unchecked { ++id; }
        }
       return _shuffleBatchOrder(batch);
    }

    function _isSpecial(uint8 id) private pure returns (bool) {
        return ((id >= 70 && id <= 78) || (id == 0));
    }

    function _isInPos(uint8 id, uint8[] memory ids, uint8 length) private pure returns (int8 pos) {
        pos =-1;
        for (uint8 i; i < length;) {
            if (ids[i] == id) {
                pos = int8(i);
                break;
            }
            unchecked { ++i; }
        }
    }

    function _shuffleBatchOrder(bytes memory batch) private view returns(bytes memory){
        uint256 _lenght = batchOrderLength;
        for (uint256 i = 0; i < _lenght;) {
            uint256 j = i + uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, i))) % (_lenght - i);
            (batch[i], batch[j]) = (batch[j], batch[i]);
            unchecked { ++i; }
        }
        return batch;
    }

    
    function changeURI(string memory baseURI_) public onlyOwner {
        _setURI(baseURI_);
        emit BaseUriChanged(baseURI_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable, ERC2981Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    //payable because will lower the gas cost, solidityscan docet
    function setMintFee(uint256 fee) external payable onlyOwner {
        if (fee != MINT_FEE){
            MINT_FEE = fee;
        }
        emit FeeChanged(fee);
    }


    function mint(address to, uint8 packs) private {
        if (to == address(0)) revert InvalidRecipient();
        uint8 _amount = amount;
        _amount = _amount * packs;
        uint16 _pointer = pointer == 1? 0 : pointer;
        bytes storage _batchOrder = batchOrder;
        if (_pointer + _amount >= _batchOrder.length) revert NotEnoughCardsLeft();
        uint256 totalNFTs = getTotalNFTsOf(to);
        if (totalNFTs + _amount >= maxCards) revert MaxCardsReached();
        

        // Overestimate max size to amount, since we may push less
        uint8[] memory tempIds = new uint8[](_amount);
        uint8[] memory tempAmounts = new uint8[](_amount);
        uint8 uniqueCount = 0;
        
        for (uint8 i = 0; i < _amount;) {
            bytes1 cardId = _batchOrder[_pointer + i];
            int8 pos = _isInPos(uint8(cardId), tempIds, uniqueCount);
            if (pos == -1) {
                tempIds[uniqueCount] = uint8(cardId);
                tempAmounts[uniqueCount] = 1;
                unchecked { ++uniqueCount;}
            } else {
                unchecked { ++tempAmounts[uint8(pos)];}
            }
            unchecked { ++i; }
        }

        pointer = _pointer + _amount;

        // Resize arrays to uniqueCount
        uint256[] memory ids = new uint256[](uniqueCount);
        uint256[] memory amounts = new uint256[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount;) {
            ids[i] = tempIds[i];
            amounts[i] = tempAmounts[i];
            unchecked{ ++i; }
        }

        _mintBatch(to, ids, amounts, "");
        emit Minted(to, ids, amounts, packs);
    }

    /// @notice Mint NFTs for the sender, paying the minting fee
    /// @dev Public minting allowed, no access restriction
    function mint4Me(uint8 packsToOpen) external payable noReentrancy {
        assert(packsToOpen > 1 && packsToOpen <= maxCards/amount); //max packs 60
        require(msg.value >= MINT_FEE * packsToOpen, "Insufficient ETH amount");
        mint(msg.sender, packsToOpen);
    }

    /// @notice Mint NFTs for the sender, paying the minting fee
    /// @dev Public minting allowed, no access restriction
    function mint4To(address to, uint8 packsToOpen) external payable noReentrancy {
        assert(packsToOpen > 1 && packsToOpen <= maxCards/amount); //max packs 60
        require(msg.value >= MINT_FEE * packsToOpen, "Insufficient ETH amount");
        mint(to, packsToOpen);
    }
    
    function getTotalNFTsOf(address user) public view returns (uint256 count) {
        for (uint256 i = 0; i < numCard;) {
            if (balanceOf(user, i) > 0) {
                count = count + balanceOf(user, i);
            }
            unchecked{ ++i; }
        }
    } 

    function getTotalMyNFTs() external view returns (uint256) {
        return getTotalNFTsOf(msg.sender);
    }

    
    function getNFTsOf(address user) public view returns (uint256[] memory, uint256[] memory) {
        uint256 count;
        uint8 _numCard = numCard;
        for (uint256 i = 0; i < _numCard;) {
            if (balanceOf(user, i) > 0) {
                unchecked { ++count; }
            }
            unchecked{ ++i;}
        }

        uint256[] memory ids = new uint256[](count);
        uint256[] memory amounts = new uint256[](count);
        uint256 index;

        for (uint256 i = 0; i < _numCard;) {
            uint256 bal = balanceOf(user, i);
            if (bal > 0) {
                ids[index] = i;
                amounts[index] = bal;
                unchecked{ ++index; }
            }
            unchecked{ ++i; }
        }

        return (ids, amounts);
    }

    function getMyNFTs() external view returns (uint256[] memory, uint256[] memory) {
        return getNFTsOf(msg.sender);
    }


    function uri(uint256 id) public view virtual override returns (string memory) {
        require(id < numCard, "URI query for nonexistent token");
        return super.uri(id);
    }

    function name() public view virtual returns (string memory) {
        return string(bytes.concat(_name));
    }

    //payable because will lower the gas cost, solidityscan docet
    function withdraw() external payable onlyOwner {
        uint256 value = address(this).balance;
        (bool success, ) = payable(owner()).call{value: value}("");
        require(success, "Withdraw failed");
        emit Withdrawn(msg.sender, value);
    }


    function toAsciiString(address x) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20;) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);     
            unchecked{ ++i;}       
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) <= 9) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    string(abi.encodePacked('{"name":"', name(), '","seller_fee_basis_points":', Strings.toString(royaltyBasis), ',"fee_recipient":"', "0x", toAsciiString(address(owner())), '"}' ))
                )
            )
        ));
    }

    

}