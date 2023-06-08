// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/SoulSocietySBT/ISoulSocietySBTFactoryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Implementation contract of growth type SBT developed by SoulSociety
/// @notice The contract inherited ISoulSocietySBTFactoryable to be managed through the factory. In addition, the issuance of SBT is implemented so that only the contract onwer is possible.
contract SoulSocietySBT is ISoulSocietySBTFactoryable, Ownable {

    // token Name
    string private _name;

    // token Symbol
    string private _symbol;

    // Factory Address
    address private _factory;

    // List of issued sbt information
    SoulSocietyData[] private _sbtList;
    address[] private _ownerList;
    bool[] private _lockedList;
    bool[] private _protectedList;

    // List of SBT IDs possessed by a specific user
    mapping(address => uint256[]) private _userTokenIds;

    // List of SBT IDs issued for a specific sbt
    mapping(string => uint256[]) private _sbtTokenIds;

    constructor(string memory name_, string memory symbol_, address factory_) {
        _name = name_;
        _symbol = symbol_;
        _factory = factory_;
    }


    // ------------------------------------------------------------
    // Functions related to basic contract information
    // ------------------------------------------------------------
    
    // Token Name
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // Token Symbol
    function symbol() public view virtual override  returns (string memory) {
        return _symbol;
    }

    // -------------------------------------------------------------
    // Factory related functions
    // -------------------------------------------------------------

    // Factory Address
    function factory() public view override returns (address) {
        return _factory;
    }


    // Set Factory Address
    function setFactory(address factory_) public override onlyOwner{
        _factory = factory_;
    }

    // ---------------------------------------------------------------
    // Metadata-related functions of SoulSociety's growth type SBT
    // ---------------------------------------------------------------

    function sbt(uint256 tokenId_) public view virtual override returns (string memory) {
        require(msg.sender != _ownerList[tokenId_] && isProtected(tokenId_), "The SBT is private.");
        return _sbtList[tokenId_].sbt;
    }

    function levelData(uint256 tokenId_) public view virtual override returns (SoulSocietyDetail[] memory) {
        require(msg.sender != _ownerList[tokenId_] && isProtected(tokenId_), "The SBT is private.");
        return _sbtList[tokenId_].levelData;
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(msg.sender != _ownerList[tokenId_] && isProtected(tokenId_), "The SBT is private.");
        return _sbtList[tokenId_].uri;
    }

    function data(uint256 tokenId_) public view virtual returns (SoulSocietyData memory) {
        require((msg.sender != _ownerList[tokenId_] && isProtected(tokenId_)), "The SBT is private.");
        return _sbtList[tokenId_];
    }

    function isLocked(uint256 tokenId_) public view override returns (bool) {
        return _lockedList[tokenId_];
    }

    function lock(uint256 tokenId_) public override returns (bool) {
        require(msg.sender == _ownerList[tokenId_], "Not Permission");
        _lockedList[tokenId_] = true;
        return true;
    }

    function unlock(uint256 tokenId_) public override returns (bool) {
        require(msg.sender == _ownerList[tokenId_], "Not Permission");
        _lockedList[tokenId_] = false;
        return true;
    }
    
    function isProtected(uint256 tokenId_) public view override returns (bool) {
        return _protectedList[tokenId_];
    }

    function protected(uint256 tokenId_) public override returns (bool) {
        require(msg.sender == _ownerList[tokenId_], "Not Permission");
        _protectedList[tokenId_] = true;
        return true;
    }

    function unProtected(uint256 tokenId_) public override returns (bool) {
        require(msg.sender == _ownerList[tokenId_], "Not Permission");
        _protectedList[tokenId_] = false;
        return true;
    }

    // --------------------------------------------------------------------------
    // SoulSocietySBTEnumable Functions
    // --------------------------------------------------------------------------

    function ownerOf(uint256 tokenId_) public view virtual override returns (address) {
        return _ownerList[tokenId_];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _sbtList.length;
    }

    function tokenListByAddressOf(address owner_) public view virtual override returns (uint256[] memory) {
        return _userTokenIds[owner_];
    }

    function tokenCountByAddresOf(address owner_) public view virtual override returns (uint256) {
        return _userTokenIds[owner_].length;
    }

    function tokenListBySBTOf(string calldata sbt_) public view virtual override  returns (uint256[] memory) {
        return _sbtTokenIds[sbt_];
    }

    function tokenCountBySBTOf(string calldata sbt_) public view virtual override  returns (uint256) {
        return _sbtTokenIds[sbt_].length;
    }


    // -------------------------------------------------------------------------
    // Mint & Level Up
    // -------------------------------------------------------------------------

    function mint(address to_, string calldata sbt_, string calldata uri_) public virtual onlyOwner {
        _mint(to_, sbt_, uri_);
    } 

    function _mint(address to_, string calldata sbt_, string calldata uri_) internal virtual onlyOwner{
  
        _existSBT(sbt_, to_);

        // Generating SBT metadata
        SoulSocietyData storage sbt = _sbtList.push();
        sbt.sbt = sbt_;
        sbt.uri = uri_;
        sbt.levelData.push(SoulSocietyDetail(1, block.timestamp));

        uint256 tokenId = _sbtList.length;
        // Add to Owner List
        _ownerList.push(to_);
        // Add to sbt List
        _sbtList.push(sbt);
        // Set unLocked
        _protectedList.push(false);

        // Add token id to UserTokenList
        _userTokenIds[to_].push(tokenId);
        // Add token id to SbtTokenList
        _sbtTokenIds[sbt_].push(tokenId);

        emit Transfer(address(0), to_, 1);
    }

    // Check if you already have sbt
    function _existSBT(string calldata sbt_, address to_) internal view {
    
        uint256[] memory tokenIds = _userTokenIds[to_];
        for (uint i = 0; i < tokenIds.length ; i++) 
        {
            if(keccak256(abi.encodePacked(sbt_)) == keccak256(abi.encodePacked(_sbtList[i].sbt))) {
                revert("duplicate mint!!");
            }
        }
    }

    // A function that grows the SBT you have
    function levelUp(address owner_, uint256 tokenId_, string calldata sbt_, uint256 level_) public override  virtual onlyOwner {
        _levelUp(owner_, tokenId_, sbt_, level_);
    }
    
    function _levelUp(address owner_, uint256 tokenId_, string calldata sbt_, uint256 level_) internal virtual onlyOwner {

        address user = _ownerList[tokenId_];
        require(user == owner_, "invalid Owner Token!!");

        SoulSocietyData memory sbtData = _sbtList[tokenId_];

        if(keccak256(abi.encodePacked(sbt_)) == keccak256(abi.encodePacked(sbtData.sbt))) {
            revert("invalid Code Token!!");
        }

        // Make sure your current level is reasonable for the level you want to raise
        uint256 lastLevel = sbtData.levelData[sbtData.levelData.length-1].level;
        require(lastLevel+1==level_, "invalid level up");

        _sbtList[tokenId_].levelData.push(SoulSocietyDetail(level_, block.timestamp));

        emit LevelUp(tokenId_, owner_);
    }


    function validSBT(string calldata sbt_) internal returns (bytes memory) {
    	(bool success, bytes memory result) = _factory.call(abi.encodeWithSignature("validSBT(string)", sbt_));
        require(success, "failed to call outer function");
        return result;
    }
}
