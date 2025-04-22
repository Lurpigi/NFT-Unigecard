// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2Upgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract InfUnigeNFT is Initializable, ERC1155Upgradeable, Ownable2StepUpgradeable, ERC2981Upgradeable, UUPSUpgradeable, VRFConsumerBaseV2Upgradeable {
    
    uint256 private constant amount = 5; //number of cards to mint at once
    uint256 public constant numCard = 80; //number of cards
    uint256 private constant numCopiesNormalCard = 20; //max copies for each student card 20. id: [1-69] + 79 = 70
    uint256 private constant numCopiesSpecialCard = 10; //max copies for each specials card 10. id: 0 + [70-78] = 10
    uint256 public constant maxCards = 250; //max number of cards to mint, 60 packs of 5 cards

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;

    uint256 public MINT_FEE = 0.05 ether;
    uint96 public royaltyBasis = 1000;

    

    event Minted(address indexed to, uint256[] ids, uint256[] amounts, uint256 packsOpened);
    event Withdrawn(address indexed to, uint256 value);
    event FeeChanged(uint256 newFees);
    event BaseUriChanged(string baseURI_);

    error DeploymentWithETH(uint256 amount);
    error MaxCardsReached();
    error NotEnoughCardsLeft();
    error InvalidRecipient();
    error WithdrawFailed();
    error RefundFailed();
    error ReentrantCall();
    error InsufficientETH();
    error UnexistingUri();
    error InvalidBatchLength();


    modifier noReentrancy() {
        if(_status != _NOT_ENTERED) revert ReentrantCall();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // total of 300 packs
    uint256 private constant batchOrderLength = 1500; //uint16(70 * uint16(numCopiesNormalCard) + 10 * uint16(numCopiesSpecialCard));
    bytes private batchOrder; 

    uint256 private pointer;

    //VRF of sepolia
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 private _subscriptionId = 1;
    uint256 private _latestRequestId = 1;
    address private _vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 private _keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 private _callbackGasLimit = 40000;
    uint16 private _requestConfirmations = 3;
    uint32 private _numWords =  1;

    // @custom:oz-upgrades-unsafe-allow constructor
    //payable because fee, solidityscan docet
    constructor() payable{
        if (msg.sender == address(0)) revert InvalidRecipient();
        // Revert and refund ETH if any was sent, payable constructor cost less
        if (msg.value != 0) {
            (bool success, ) = msg.sender.call{value: msg.value}("");
            if(!success) revert RefundFailed();
            revert DeploymentWithETH(msg.value);
        }
        _disableInitializers(); //set the contract state to not initialized
    }

    function initialize(
        uint64 subscriptionId
    ) public initializer {
        __ERC1155_init("ipfs://QmXrx46YwgKzptm1dzN8fcSRMFMQLhBMTSw9GcZbmVqA7n/{id}.json");
        __Ownable_init(msg.sender);
        __ERC2981_init();
        __UUPSUpgradeable_init();


        _subscriptionId = subscriptionId;
        __VRFConsumerBaseV2Upgradeable_init(_vrfCoordinator);
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);

        pointer = 1;
        _status = _NOT_ENTERED;
        MINT_FEE = 0.05 ether;
        royaltyBasis = 1000;

        //batchOrder = _setBatchOrder();
        //require(batchOrder.length == batchOrderLength, "Invalid batch length");
        _setDefaultRoyalty(msg.sender, royaltyBasis); // 1000 = 10% in basis points
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


    function requestShuffle() external onlyOwner returns (uint256 requestId) {
        require(pointer == 1, "Batch already set");
        requestId = COORDINATOR.requestRandomWords(
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            _numWords
        );
        _latestRequestId = requestId;
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        bytes memory batch = new bytes(batchOrderLength);
        uint256 index;
        uint256 copies;

        for (uint8 id; id < numCard;) {
            copies = _isSpecial(uint256(id))? numCopiesSpecialCard : numCopiesNormalCard;
            for (uint256 j; j < copies;) {
                batch[index] = bytes1(id);
                unchecked { ++j; ++index; }
            }
            unchecked { ++id; }
        }

        batchOrder = _shuffleWithSeed(batch, randomWords[0]);
        if(batchOrder.length != batchOrderLength) revert InvalidBatchLength();
    }

    function _shuffleWithSeed(bytes memory batch, uint256 seed) private pure returns (bytes memory) {
        uint256 _length = batch.length;
        for (uint256 i; i < _length;) {
            uint256 j = i + uint256(keccak256(abi.encode(seed, i))) % (_length - i);
            (batch[i], batch[j]) = (batch[j], batch[i]);
            unchecked { ++i; }
        }
        return batch;
    }

    function _isSpecial(uint256 id) private pure returns (bool) {
        return ((id >= 70 && id <= 78) || (id == 0));
    }

    function _isInPos(uint8 id, uint8[] memory ids, uint256 length) private pure returns (int256 pos) {
        pos =-1;
        for (uint256 i; i < length;) {
            if (ids[i] == id) {
                pos = int256(i);
                break;
            }
            unchecked { ++i; }
        }
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


    function mint(address to, uint256 packs) private {
        if (to == address(0)) revert InvalidRecipient();
        uint256 _amount = amount;
        _amount = _amount * packs;
        uint256 _pointer = pointer == 1? 0 : pointer;
        bytes storage _batchOrder = batchOrder;
        if (_pointer + _amount >= _batchOrder.length) revert NotEnoughCardsLeft();
        uint256 totalNFTs = getTotalNFTsOf(to);
        if (totalNFTs + _amount >= maxCards) revert MaxCardsReached();
        

        // Overestimate max size to amount, since we may push less
        uint8[] memory tempIds = new uint8[](_amount);
        uint256[] memory tempAmounts = new uint256[](_amount);
        uint256 uniqueCount;
        
        for (uint256 i; i < _amount;) {
            bytes1 cardId = _batchOrder[_pointer + i];
            int256 pos = _isInPos(uint8(cardId), tempIds, uniqueCount);
            if (pos == -1) {
                tempIds[uniqueCount] = uint8(cardId);
                tempAmounts[uniqueCount] = 1;
                unchecked { ++uniqueCount;}
            } else {
                unchecked { ++tempAmounts[uint256(pos)];}
            }
            unchecked { ++i; }
        }

        pointer = _pointer + _amount;

        // Resize arrays to uniqueCount
        uint256[] memory ids = new uint256[](uniqueCount);
        uint256[] memory amounts = new uint256[](uniqueCount);
        for (uint256 i; i < uniqueCount;) {
            ids[i] = tempIds[i];
            amounts[i] = tempAmounts[i];
            unchecked{ ++i; }
        }

        _mintBatch(to, ids, amounts, "");
        emit Minted(to, ids, amounts, packs);
    }

    

    /// @notice Mint NFTs for the sender, paying the minting fee
    /// @dev Public minting allowed, no access restriction
    function mint4To(address to, uint256 packsToOpen) public payable noReentrancy {
        assert(packsToOpen > 1 && packsToOpen <= maxCards/amount); //max packs 60
        if(msg.value < MINT_FEE * packsToOpen) revert InsufficientETH();
        mint(to, packsToOpen);
    }

    /// @notice Mint NFTs for the sender, paying the minting fee
    /// @dev Public minting allowed, no access restriction
    function mint4Me(uint256 packsToOpen) external payable noReentrancy {
        mint4To(msg.sender, packsToOpen);
    }
    
    function getTotalNFTsOf(address user) public view returns (uint256 count) {
        for (uint256 i; i < numCard;) {
            uint256 bal = balanceOf(user, i);
            if (bal > 0) {
                count = count + bal;
            }
            unchecked{ ++i; }
        }
    } 

    function getTotalMyNFTs() external view returns (uint256) {
        return getTotalNFTsOf(msg.sender);
    }

    
    function getNFTsOf(address user) public view returns (uint256[] memory, uint256[] memory) {
        uint256 count;
        uint256 _numCard = numCard;
        for (uint256 i; i < _numCard;) {
            if (balanceOf(user, i) > 0) {
                unchecked { ++count; }
            }
            unchecked{ ++i;}
        }

        uint256[] memory ids = new uint256[](count);
        uint256[] memory amounts = new uint256[](count);
        uint256 index;

        for (uint256 i; i < _numCard;) {
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
        if(id >= numCard) revert UnexistingUri();
        return super.uri(id);
    }

    function name() public pure returns (string memory) {
        return "InfUnigeNFT";
    }


    //payable because will lower the gas cost, solidityscan docet
    function withdraw() external payable onlyOwner {
        uint256 value = address(this).balance;
        (bool success, ) = payable(owner()).call{value: value}("");
        if(!success) revert WithdrawFailed();
        emit Withdrawn(msg.sender, value);
    }


    function toAsciiString(address x) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i; i < 20;) {
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
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes.concat(
                        bytes('{"name":"InfUnigeNFT","seller_fee_basis_points":'),
                        bytes(Strings.toString(royaltyBasis)),
                        bytes(',"fee_recipient":"0x'),
                        bytes(toAsciiString(owner())),
                        bytes('"}')
                    )
                )
            )
        );
    }
}

    

