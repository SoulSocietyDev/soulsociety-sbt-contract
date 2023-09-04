// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "v2/contracts/interfaces/ISoulSocietyEnumerableSBT.sol";
import "v2/contracts/interfaces/ISoulSocietySBTMetadata.sol";
import "v2/contracts/interfaces/ISoulSocietySBTErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Implementation contract of Lightweight growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietyLightweightEnumableSTB, only the owner can modify growth.
contract SoulSocietySBT is ISoulSocietySBT, ISoulSocietySBTMetadata, ISoulSocietySBTErrors, Ownable {

    // token Name
    string private _name;

    // token Symbol
    string private _symbol;

    // token Meta URI
    string private _uri;

    // SBT를 소유한 유저 수
    uint256 private _totalUser = 0;

    // 발행된 SBT 총 갯수
    uint256 private _totalCount = 0;

    // 발행되는 SBT ID, 오너 Address
    mapping(uint256 => address) private _owners;

    // SBT ID, 타입
    mapping(uint256 => uint) private _tokenTypes;

    // SBT ID, 현재 레벨
    mapping(uint256 => uint) private _tokenGrowths;

    // 오너 Address, 몇개의 로그 SBT를 가졌는지 기록
    mapping(address => uint256) private _balances;

    // 지갑 주소에 해당하는 token 정보 오픈 여부
    mapping(address => bool) private _userProtects;

    constructor(string memory name_, string memory symbol_, string memory uri_) {
        _name = name_;
        _symbol = symbol_;
        _uri = uri_;
    }

    // ------------------------------------------------------------
    // Functions related to basic contract information
    // Public Interface Implementation
    // ------------------------------------------------------------
    
    // Token Name
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Token Symbol
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI() public view virtual  returns (string memory) {
        return _uri;
    }


    function totalUser() public view  returns (uint256) {
        return _totalUser;
    }

    function totalSupply() public view  returns (uint256) {
        return _totalCount;
    }
 
    function getTokenType(uint256 tokenId_) public view returns (uint256) {
        if (!_exists(tokenId_)) {
            revert SoulSocietySBTNonexistentToken(tokenId_);
        }

        return _tokenTypes[tokenId_];
    }

    // ------------------------------------------------------------------------
    // Permission settings to check the view information of a token
    // ------------------------------------------------------------------------
    function setProtected(address to_, bool isProtected_) public  returns (bool) {
        if (msg.sender != to_) {
            revert SoulSocietySBTInvalidOwner(to_);
        }

        _userProtects[to_] = isProtected_;

        return getProtected(to_);
    }

    function getProtected(address to_) public view returns(bool) {
        return _getProtected(to_);
    }

    function _getProtected(address to_) internal  view returns(bool) {
        // If owner doesn't exist, return value is false
        return _userProtects[to_];
    }

    function isProtected(address to_) external view returns (bool) {
        return _isProtected(to_);
    }

    function _isProtected(address to_) internal view returns (bool) {        
        if (_userProtects[to_] == true)
            revert SoulSocietySBTProtectedOwner(to_);
        
        return false;

    }

    function _isProtectedTokenId(uint256 tokenId_) internal view {
        // If tokenId doesn't exist,  don't need to check "protected status"
        if (!_exists(tokenId_)) {
            revert SoulSocietySBTNonexistentToken(tokenId_);
        }

        _isProtected(_owners[tokenId_]);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function ownerOf(uint256 tokenId_) public view returns (address) {
        return _owners[tokenId_];
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId_) internal view virtual returns (address) {
        return _owners[tokenId_];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    // -------------------------------------------------------------------------
    // Mint & Level Up
    // -------------------------------------------------------------------------
    
    function mint(address to_, uint256 tokenType_) public virtual onlyOwner returns(uint256) {
        return _safeMint(to_, tokenType_);
    }

    function _safeMint(address to_, uint256 tokenType_) internal virtual onlyOwner returns(uint256) {

        uint256 tokenId = _totalCount + 1;

        if (to_ == address(0)) {
            revert SoulSocietySBTInvalidReceiver(address(0));
        }

        if (_exists(tokenId)) {
            revert SoulSocietySBTExistToken(tokenId);
        }

        // if to is false , to address is new user
        if(!_existsOwner(to_)) {
            _totalUser += 1;
        }

        unchecked {
        // Will not overflow unless all 2**256 token ids are minted to the same owner.
        // Given that tokens are minted one by one, it is impossible in practice that
        // this ever happens. Might change if we allow batch minting.
        // The ERC fails to describe this case.
            _balances[to_] += 1;
            _totalCount += 1;
        }

        _owners[tokenId] = to_;
        _tokenTypes[tokenId] = tokenType_;
        _tokenGrowths[tokenId] = 1;
        _userProtects[to_] = false;

        emit Mint(address(0), to_, tokenId, tokenType_);

        return tokenId;
    }


    // ---------------------------------------------------------------
    // Metadata-related functions of SoulSociety's growth type SBT
    // ---------------------------------------------------------------
    function getGrowth(uint256 tokenId_) public view  returns (uint256) {
        // Check whether the token exists and if its status is 'protected'.
        _isProtectedTokenId(tokenId_);

        return _tokenGrowths[tokenId_];
    }


    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _existsOwner(address to) internal view virtual returns (bool) {
        return _balances[to] != 0;
    }

    // -------------------------------------------------------------------------
    // GrowthUp & GrowthDown
    // -------------------------------------------------------------------------

    // A function that grows the SBT you have
    function growUp(address to_, uint256 tokenId_) public  onlyOwner returns(uint256) {
        return _growUp(to_, tokenId_);
    }
    
    function _growUp(address to_, uint256 tokenId_) internal onlyOwner returns(uint256) {

        // check to exist and owner address
        _requireMintedOf(to_, tokenId_);

        uint256 tokenGrowth = _tokenGrowths[tokenId_] += 1;

        emit GrowUp(to_, tokenId_, tokenGrowth);

        return tokenGrowth;
    }

//    function growthDown(address owner_) public override onlyOwner returns(uint256) {
//        return _growthDown(owner_);
//    }
//
//    function _growthDown(address owner_) internal onlyOwner returns(uint256) {
//
//        uint256 userLevel = _userGrowthMap[owner_];
//
//        require(userLevel != 0, "invalid growthDown");
//
//        delete _growthMap[userLevel][owner_];
//
//        if(userLevel == 1) {
//            _totalUser--;
//        } else {
//            _growthMap[userLevel-1][owner_] = block.timestamp;
//        }
//        _userGrowthMap[owner_] = userLevel-1;
//
//        emit GrowthDown(owner_, userLevel-1);
//
//        return userLevel-1;
//    }

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
}