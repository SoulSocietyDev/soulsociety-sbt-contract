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

    // token Meta URI
    string private _uri;

    // The number of users who own SBT.
    uint256 private _totalUser;

    // Total number of SBT issued
    uint256 private _totalCount;


    // questId(SBT ID), address, processCount
    mapping(uint256 => mapping(address => uint256)) _questHistories;

    constructor() ERC721("Token SBT Quest", "SBTQ") {
        emit ContractCreated(msg.sender,  block.timestamp, name, symbol);
    }

    // -------------------------------------------------------------------------
    // Mint & Grow Up
    // -------------------------------------------------------------------------
    function mint(address to_, uint256 tokenId_) external virtual onlyOwner returns(uint256) {

        return _mint(to_, tokenId_);

        // return _safeMint(to_, tokenId_);
    }

    /**
     *  Does not provide a transfer feature.
     */
    function safeTransferFrom(address , address , uint256 , bytes calldata) external pure {
        revert SoulSBTQuestNotSupported("safeTransferFrom");
    }

    function safeTransferFrom(address , address , uint256 ) external pure {
        revert SoulSBTQuestNotSupported("safeTransferFrom");
    }

    function transferFrom(address , address , uint256 ) external pure {
        revert SoulSBTQuestNotSupported("transferFrom");
    }

    function approve(address , uint256 ) external pure{
        revert SoulSBTQuestNotSupported("approve");
    }

    function setApprovalForAll(address , bool ) external pure {
        revert SoulSBTQuestNotSupported("setApprovalForAll");
    }

    function getApproved(uint256 ) external pure returns (address )  {
        revert SoulSBTQuestNotSupported("getApproved");
    }

    function isApprovedForAll(address , address ) external pure returns (bool) {
        revert SoulSBTQuestNotSupported("isApprovedForAll");
    }

    function _mint(address to_, uint256 tokenId_) internal virtual returns(uint256) {
        if (to_ == address(0)) {
            revert SoulSBTQuestInvalidReceiver(address(0));
        }

        if (_exists(tokenId_)) {
            revert SoulSBTQuestExistToken(tokenId);
        }

        // if to is false , to address is new user
        if(!_existsOwner(to_)) {
            _totalUser += 1;
        }

        _totalCount += 1;

        _safeMint(to_, tokenId_);

        emit Mint(address(0), to_, tokenId, tokenType_);

        return tokenId;
    }

    function _increase(address to_, uint256 tokenId_) internal returns(uint256) {
        
        // check to exist and owner address
        _requireMintedOf(to_, tokenId_);

        _tokenGrowths[tokenId_] += 1;

        uint256 tokenGrowth = _tokenGrowths[tokenId_];

        emit GrowUp(to_, tokenId_, tokenGrowth);

        return tokenGrowth;
    }


    /**
  * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _existsOwner(address to) internal view virtual returns (bool) {
        return _balances[to] != 0;
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        if (!_exists(tokenId)) {
            revert SoulSocietySBTNonexistentToken(tokenId);
        }
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet and owner address is not equal "to" address
     */
    function _requireMintedOf(address to, uint256 tokenId) internal view virtual {
        if(_ownerOf(tokenId) != to) {
            revert SoulSocietySBTInvalidOwner(to);
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }


}