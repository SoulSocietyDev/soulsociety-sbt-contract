// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/SoulSocietySBT/ISoulSocietySBT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Implementation contract of growth type SBT developed by SoulSociety
/// @notice The contract inherited ISoulSocietySBT to be managed through the factory. In addition, the issuance of SBT is implemented so that only the contract onwer is possible.
contract SoulSocietySBT is ISoulSocietySBT, Ownable {

    // token Name
    string private _name;

    // token Symbol
    string private _symbol;

    // List of issued sbt information
    SoulSocietyData[] private _sbtList;
    address[] private _ownerList;
    bool[] private _lockedList;
    bool[] private _protectedList;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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


    // ---------------------------------------------------------------
    // Metadata-related functions of SoulSociety's growth type SBT
    // ---------------------------------------------------------------

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


    function ownerOf(uint256 tokenId_) public view virtual override returns (address) {
        return _ownerList[tokenId_];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _sbtList.length;
    }


    // -------------------------------------------------------------------------
    // Mint & Level Up
    // -------------------------------------------------------------------------

    function mint(address to_, string calldata uri_) public virtual onlyOwner {
        _mint(to_, uri_);
    }

    function _mint(address to_, string calldata uri_) internal virtual onlyOwner returns (uint256) {

        SoulSocietyData storage sbt = _sbtList.push();
        sbt.uri = uri_;
        sbt.levelData.push(SoulSocietyDetail(1, block.timestamp));

        // Add to Owner List
        _ownerList.push(to_);
        // Add to sbt List
        _sbtList.push(sbt);
        // Set unLocked
        _lockedList.push(false);

        emit Transfer(address(0), to_, 1);

        return _sbtList.length-1;
    }


    // A function that grows the SBT you have
    function levelUp(address owner_, uint256 tokenId_, uint256 level_) public override  virtual onlyOwner {
        _levelUp(owner_, tokenId_, level_);
    }

    function _levelUp(address owner_, uint256 tokenId_, uint256 level_) internal virtual onlyOwner {

        address user = _ownerList[tokenId_];
        require(user == owner_, "invalid Owner Token!!");

        SoulSocietyData memory sbtData = _sbtList[tokenId_];

        // Make sure your current level is reasonable for the level you want to raise
        uint256 lastLevel = sbtData.levelData[sbtData.levelData.length-1].level;
        require(lastLevel+1==level_, "invalid level up");

        _sbtList[tokenId_].levelData.push(SoulSocietyDetail(level_, block.timestamp));

        emit LevelUp(tokenId_, owner_);
    }
}