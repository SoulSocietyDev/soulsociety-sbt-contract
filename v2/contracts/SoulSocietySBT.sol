// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "v2/contracts/interfaces/ISoulSocietyEnumerableSBT.sol";
import "v2/contracts/interfaces/ISoulSocietySBTMetadata.sol";
import "v2/contracts/interfaces/ISoulSocietySBTErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";


/// @title Implementation contract of Lightweight growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietyLightweightEnumableSTB, only the owner can modify growth.
contract SoulSocietySBT is ISoulSocietySBT, ISoulSocietySBTMetadata, ISoulSocietySBTErrors , IERC721, ERC165, Ownable {

    using Strings for uint256;

    // token Name
    string private _name;

    // token Symbol
    string private _symbol;

    // token Meta URI
    string private _uri;

    // The number of users who own SBT.
    uint256 private _totalUser = 0;

    // Total number of SBT issued
    uint256 private _totalCount = 0;

    // Mapping from SBT ID to owned address
    mapping(uint256 => address) private _owners;

    // Mapping from SBT ID to token Type
    mapping(uint256 => uint256) private _tokenTypes;

    // Mapping from SBT ID to current Growth
    mapping(uint256 => uint256) private _tokenGrowths;

    // Mapping from owner to count of SBT 
    mapping(address => uint256) private _balances;

    // Mapping from owner to information open flag
    mapping(address => bool) private _userProtects;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from owner to list of owned token Types, address , tokenType, tokenId
    // mapping(address => mapping(uint256 => uint)) private _ownedTokenTypes;

    constructor(string memory name_, string memory symbol_, string memory uri_) {
        _name = name_;
        _symbol = symbol_;
        _uri = uri_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return 
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // ------------------------------------------------------------
    // Functions related to basic contract information
    // Public Interface Implementation
    // ------------------------------------------------------------
    
    // Token Name
    function name() external view virtual returns (string memory) {
        return _name;
    }

    // Token Symbol
    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId_) external view virtual  returns (string memory) {

        // check minted 
        _requireMinted(tokenId_);
        
        // check protected status 
        _isProtectedTokenId(tokenId_);

        uint256 tokenType = _tokenTypes[tokenId_];

        return string(abi.encodePacked(_uri,tokenId_.toString(),"?tokenType=", tokenType.toString()));
        // return string.concat(_uri, tokenId_.toString());
    }


    function setTokenURI(string memory tokenURI_) external onlyOwner returns(string memory) {
        _uri = tokenURI_;
        return _uri;

    }

    function totalUser() public view  returns (uint256) {
        return _totalUser;
    }

    function totalSupply() public view  returns (uint256) {
        return _totalCount;
    }
 
    function getTokenType(uint256 tokenId_) public view returns (uint256) {

        _isProtectedTokenId(tokenId_);

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


    // ERC721 Interface 
    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function ownerOf(uint256 tokenId_) external  view  override  returns (address) {
         // Check whether the token exists and if its status is 'protected'.
        _isProtectedTokenId(tokenId_);

        return _owners[tokenId_];
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId_) internal view  returns (address) {
        return _owners[tokenId_];
    }

    function balanceOf(address owner_) external  view  returns (uint256) {
         // Check whether the token exists and if its status is 'protected'.
        _isProtected(owner_);
        
        return _balanceOf(owner_);
    }

    function _balanceOf(address owner_) internal view returns (uint256) {
            return _balances[owner_];
    }


    /**
     *  Does not provide a transfer feature.
     */
    function safeTransferFrom(address , address , uint256 , bytes calldata) external pure {
        
        revert SoulSocietySBTNotSupported("safeTransferFrom");
    }

    function safeTransferFrom(address , address , uint256 ) external pure {
        revert SoulSocietySBTNotSupported("safeTransferFrom");
    }

    function transferFrom(address , address , uint256 ) external pure {
        revert SoulSocietySBTNotSupported("transferFrom");
    }

    function approve(address , uint256 ) external pure{
        revert SoulSocietySBTNotSupported("approve");
    }

    function setApprovalForAll(address , bool ) external pure {
        revert SoulSocietySBTNotSupported("setApprovalForAll");
    }

    function getApproved(uint256 ) external pure returns (address )  {
        revert SoulSocietySBTNotSupported("getApproved");


    }

    function isApprovedForAll(address , address ) public pure returns (bool) {
        revert SoulSocietySBTNotSupported("isApprovedForAll");
    }

    // -------------------------------------------------------------------------
    // Mint & Grow Up
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
        _ownedTokens[to_][_balances[to_]-1] = tokenId; // index from 0

        emit Mint(address(0), to_, tokenId, tokenType_);

        return tokenId;
    }

    function burn(address to_, uint256 tokenId_) public onlyOwner  {
        _setGrowthToZero(to_, tokenId_);
    }

    function _setGrowthToZero(address to_, uint tokenId_) private onlyOwner {
        // check to exist and owner address
        _requireMintedOf(to_, tokenId_);

        _tokenGrowths[tokenId_] = 0;

        emit Burn(to_, tokenId_);
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
    // Growth Control : GrowUp
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



    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner_, uint256 index_) public view returns (uint256) {
        // Check whether the token exists and if its status is 'protected'.
       _isProtected(owner_);

        require(index_ < _balanceOf(owner_), "Out of Index");

        if (owner_ == address(0)) {
            revert SoulSocietySBTInvalidReceiver(address(0));
        }

        uint256 tokenId = _ownedTokens[owner_][index_];

        return tokenId; 
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
}