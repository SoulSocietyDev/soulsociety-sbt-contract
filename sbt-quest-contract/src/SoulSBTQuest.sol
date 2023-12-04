// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/ISoulSBTQuest.sol";
import "./interfaces/ISoulSBTQuestErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721, ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";


/// @title Implementation contract of  growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietySBT, only the owner can modify growth.
contract SoulSBTQuest is ISoulSBTQuest,  ISoulSBTQuestErrors , ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId = 1;

    // The number of users who own SBT.
    uint256 private _totalUser;

    // Total number of Quest Process
    uint256 private _totalCompletionCount;

    // Total number of GrowUp
    uint256 private _totalGrowUpCount;

    // Mapping from SBT ID to token Type
    mapping(uint256 => uint256) private _tokenTypes;

    // Mapping from SBT ID to current Growth
    mapping(uint256 => uint256) private _tokenGrowths;

    // Mapping from owner to list of owned tokey Types , address, tokenType, tokenId
    mapping(address => mapping(uint256 => uint256)) private _ownedTokensByTypes;

    // questId(SBT ID), address, processCount
    mapping(uint256 => mapping(address => uint256)) _questHistories;

    constructor() ERC721("Token SBT Quest", "SBTQ") Ownable(msg.sender) {
        emit ContractCreated(msg.sender,  block.timestamp, name(), symbol());
    }

    // -------------------------------------------------------------------------
    // Mint & Increase
    // -------------------------------------------------------------------------
    function mint(address to_ , uint256 tokenType_) external virtual onlyOwner returns(uint256) {
        uint256 currentTokenId = _nextTokenId;

        _questSbtMint(to_, currentTokenId, tokenType_);

        _nextTokenId++;

        return currentTokenId;
    }

    // A function that increase SBT processed count
    function increaseCompletion(address to_, uint256 tokenType_) external  onlyOwner returns(uint256) {
        return _increaseCompletion(to_, tokenType_);
    }

    // A function that grows the SBT you have
    function growUp(address to_, uint256 tokenType_) external  onlyOwner returns(uint256) {
        return _growUp(to_, tokenType_);
    }

    function growUpById(address to_, uint256 tokenId_) external onlyOwner returns(uint256) {
        return _growUpById(to_, tokenId_);
    }

    function totalUser() external view  returns (uint256) {
        return _totalUser;
    }

    function totalCompletionCount() external view returns (uint256) {
        return _totalCompletionCount;
    }

    function totalGrouwUpCount() external view returns (uint256) {
        return _totalGrowUpCount;
    }

    function getTokenType(uint256 tokenId_) external view returns (uint256) {
        return _tokenTypes[tokenId_];
    }

    function getTokenId(address to_, uint256 tokenType_) external view returns(uint256) {
        return _ownedTokensByTypes[to_][tokenType_];
    }

    function getCompletionCount(address to_, uint256 tokenType_) external view returns (uint256) {
        return _questHistories[tokenType_][to_];
    }

    function getGrowth(uint256 tokenId_) external view  returns (uint256) {
        return _tokenGrowths[tokenId_];
    }

    /**
     *  Does not provide a transfer feature.
     */
    function safeTransferFrom(address  , address  , uint256  , bytes memory ) override(ERC721, IERC721) public pure {
        revert SoulSBTQuestNotSupported("safeTransferFrom");
    }

    function transferFrom(address , address , uint256 ) override(ERC721, IERC721) public pure {
        revert SoulSBTQuestNotSupported("transferFrom");
    }

    function approve(address , uint256 ) override(ERC721, IERC721) public pure{
        revert SoulSBTQuestNotSupported("approve");
    }

    function setApprovalForAll(address , bool ) override(ERC721, IERC721) public pure {
        revert SoulSBTQuestNotSupported("setApprovalForAll");
    }

    function getApproved(uint256 ) override(ERC721, IERC721) public pure returns (address )  {
        revert SoulSBTQuestNotSupported("getApproved");
    }

    function isApprovedForAll(address , address ) override(ERC721, IERC721) public pure returns (bool) {
        revert SoulSBTQuestNotSupported("isApprovedForAll");
    }

    function _questSbtMint(address to_, uint256 tokenId_, uint256 tokenType_) internal virtual returns(uint256) {
        if (to_ == address(0)) {
            revert SoulSBTQuestInvalidReceiver(address(0));
        }

        if (_exists(tokenId_)) {
            revert SoulSBTQuestExistToken(tokenId_);
        }

        // if to is false , to address is new user
        if(!_existsOwner(to_)) {
            _totalUser += 1;
        }

        _tokenTypes[tokenId_] = tokenType_;
        _ownedTokensByTypes[to_][tokenType_] = tokenId_;
        _tokenGrowths[tokenId_] = 1;

        _safeMint(to_, tokenId_);

        emit Mint(address(0), to_, tokenId_, tokenType_);

        return tokenId_;
    }

    function _growUp(address to_, uint256 tokenType_) internal returns(uint256) {
        uint256 tokenId = _ownedTokensByTypes[to_][tokenType_];

        return _growUpById(to_, tokenId);
    }

    function _growUpById(address to_, uint256 tokenId_) internal returns(uint256) {
        

        // check to exist and owner address
        _requireMintedOf(to_, tokenId_);
        
        _tokenGrowths[tokenId_] += 1;

        uint256 tokenGrowth = _tokenGrowths[tokenId_];

        _totalGrowUpCount++;


        emit GrowUp(to_, tokenId_, tokenGrowth);

        return tokenGrowth;
    }

    function _increaseCompletion(address to_, uint256 tokenType_) internal returns(uint256) {
        // check to exist and owner address
        _requireMintedOf(to_, _ownedTokensByTypes[to_][tokenType_]);

        _questHistories[tokenType_][to_] += 1;

        _totalCompletionCount += 1;

        uint256 increasedCount = _questHistories[tokenType_][to_];

        emit IncreaseCompletion(to_, tokenType_,  increasedCount);

        return increasedCount;
    }

    /**
  * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _existsOwner(address to) internal view virtual returns (bool) {

        return balanceOf(to) != 0;
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId_) internal view virtual {
        if (!_exists(tokenId_)) {
            revert SoulSBTQuestNonexistentToken(tokenId_);
        }
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet and owner address is not equal "to" address
     */
    function _requireMintedOf(address to_, uint256 tokenId_) internal view virtual {
        if(_ownerOf(tokenId_) != to_) {
            revert SoulSBTQuestInvalidOwner(to_);
        }
    }

    function isContract(address addr_) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr_)
        }
        return (size > 0);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal  pure  override  returns (string memory)  {
        return "https://api.soulsociety.gg/quest/";
    }
//    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool)
//    {
//        if (!isContract(to)) {
//            return true;
//        }
//        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
//        return (retval == IERC721Receiver(to).onERC721Received.selector);
//    }

}