// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "v2/contracts/interfaces/ISoulSocietyLightweightEnumableSBT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title Implementation contract of Lightweight growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietyLightweightEnumableSTB, only the owner can modify growth.
contract SoulSocietyLightweightSBT is ISoulSocietyLightweightEnumableSBT, Ownable {

    // token Name
    string private _name;

    // token Symbol
    string private _symbol;

    // token Meta URI
    string private _uri;

    uint256 private _totalUser = 0;

    mapping(uint256 => mapping (address => uint)) private _growthMap;
    mapping(address => uint256) private _userGrowthMap;
    mapping(address => bool) private _userProtectMap;

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

    function setTokenURI(string memory uri_) public override returns (string memory) {
        _uri = uri_;
        return _uri;
    }

    function tokenURI() public view virtual override returns (string memory) {
        return _uri;
    }

    function growth(address to_) public view override returns (uint256) {
        _isProtected(to_);
        return _userGrowthMap[to_];
    }

    function growthDate(address to_, uint256 grwoth_) public view override returns(uint) {
        _isProtected(to_);
        return _growthMap[grwoth_][to_];
    }

    function totalUser() public view override returns (uint256) {
        return _totalUser;
    }

    // ------------------------------------------------------------------------
    // protected & unProtected
    // ------------------------------------------------------------------------

    function isProtected(address to_) public view override returns (bool) {
        return _userProtectMap[to_];
    }

    function protected(address to_) public override returns (bool){
        require(msg.sender == to_, "not permission");
        _userProtectMap[to_] = true;
        return isProtected(to_);
    }

    function unProtected(address to_) public override returns (bool){
        require(msg.sender == to_, "not permission");
        _userProtectMap[to_] = false;
        return isProtected(to_);
    }

    function _isProtected(address to_) internal view {
        if(_userProtectMap[to_]) {
            require(msg.sender == to_, "protected!!");
        }
    }


    // -------------------------------------------------------------------------
    // GrowthUp & GrowthDown
    // -------------------------------------------------------------------------

    // A function that grows the SBT you have
    function growthUp(address owner_) public override onlyOwner returns(uint256) {
        return _growthUp(owner_);
    }
    
    function _growthUp(address owner_) internal onlyOwner returns(uint256) {

        uint256 userLevel = _userGrowthMap[owner_] + 1;
        if(userLevel == 1) {
            _totalUser++;
        }

        _growthMap[userLevel][owner_] = block.timestamp;

        _userGrowthMap[owner_] = userLevel;

        emit GrowthUp(owner_, userLevel);

        return userLevel;
    }

    function growthDown(address owner_) public override onlyOwner returns(uint256) {
        return _growthDown(owner_);
    }

    function _growthDown(address owner_) internal onlyOwner returns(uint256) {

        uint256 userLevel = _userGrowthMap[owner_];

        require(userLevel != 0, "invalid growthDown");

        delete _growthMap[userLevel][owner_];

        if(userLevel == 1) {
            _totalUser--;
        } else {
            _growthMap[userLevel-1][owner_] = block.timestamp;
        }
        _userGrowthMap[owner_] = userLevel-1;

        emit GrowthDown(owner_, userLevel-1);

        return userLevel-1;
    }
}