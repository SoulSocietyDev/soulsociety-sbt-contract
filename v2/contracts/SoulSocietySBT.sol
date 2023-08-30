// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "v2/contracts/interfaces/ISoulSocietyEnumerableSBT.sol";
import "v2/contracts/interfaces/ISoulSocietySBTErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Implementation contract of Lightweight growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietyLightweightEnumableSTB, only the owner can modify growth.
contract SoulSocietySBT is ISoulSocietySBT, ISoulSocietyEnumableSBT, Ownable {

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
    mapping(uint256 => uint) private _tokenLevels;

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
    // ------------------------------------------------------------
    
    // Token Name
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Token Symbol
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function getTotalUser() public view override returns (uint256) {
        return _totalUser;
    }

    function getTotalCount() public view override returns (uint256) {
        return _totalCount;
    }

    function setTokenURI(string memory uri) public override onlyOwner returns (string memory)   {
        _uri = uri;
        return uri;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function getTokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return bytes(_uri).length > 0 ? string.concat(_uri, tokenId.toString()) : "";
    }

    // ------------------------------------------------------------------------
    // Permission settings to check the view information of a token
    // ------------------------------------------------------------------------
    function setProtected(address to, bool isProtected) public override returns (bool) {
        if (msg.sender != to) {
            revert ERC721IncorrectOwner(from, tokenId, owner);
        }

        _userProtects[msg.sender] = isProtected;
        return getProtected(msg.sender);
    }

    function getProtected(address to) public override returns(bool) {
        // If owner doesn't exist, return value is false
        return _userProtects[to];
    }

    function _isProtected(address to) internal view {
        require (_userProtectMap[owner] == true, SoulSocietySBTProtectedOwner({
            owner : to
        }).message());
    }

    function _isProtectedTokenId(uint256 tokenId) internal view {
        // If tokenId doesn't exist,  don't need to check "protected status"
        if (!_exists(tokenId)) {
            revert SoulSocietySBTNonexistentToken(tokenId);
        }

        _isProtected(_owners[tokenId]);
    }


    // -------------------------------------------------------------------------
    // Mint & Level Up
    // -------------------------------------------------------------------------
    function mint(address to, uint256 tokenId, uint256 tokenType) public virtual onlyOwner {
        _safeMint(to, tokenId, tokenType);
    }

    function _safeMint(address to, uint256 tokenId, uint256 tokenType) internal virtual onlyOwner {
        if (to == address(0)) {
            revert SoulSocietySBTInvalidReceiver(address(0));
        }

        if (_exists(tokenId)) {
            revert SoulSocietySBTInvalidSender(address(0));
        }

        // if to is false , to address is new user
        if(!_existsOwner(to)) {
            _totalUser += 1;
        }

        unchecked {
        // Will not overflow unless all 2**256 token ids are minted to the same owner.
        // Given that tokens are minted one by one, it is impossible in practice that
        // this ever happens. Might change if we allow batch minting.
        // The ERC fails to describe this case.
            _balances[to] += 1;
            _totalCount += 1;
        }

        _owners[tokenId] = to;
        _tokenTypes[tokenId] = tokenType;
        _tokenLevels[tokenId] = 1;
        _userProtects[to] = false;

        emit Mint(address(0), to, tokenId);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    // ---------------------------------------------------------------
    // Metadata-related functions of SoulSociety's growth type SBT
    // ---------------------------------------------------------------
    function getGrowth(uint256 tokenId) public view override returns (uint256) {
        // Check whether the token exists and if its status is 'protected'.
        _isProtectedTokenId(tokenId);

        return _tokenLevels[tokenId];
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
    function growUp(address to, uint256 tokenId) public override onlyOwner returns(uint256) {
        return _growUp(to, tokenId);
    }
    
    function _growUp(address to, uint256 tokenId) internal onlyOwner returns(uint256) {

        // check to exist and owner address
        _requireMintedOf(to, tokenId);

        uint256 tokenLevel = _tokenLevels[tokenId] += 1;

        emit GrowthUp(owner, tokenLevel);

        return tokenLevel;
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