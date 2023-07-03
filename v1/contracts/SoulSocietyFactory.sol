// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "v1/contracts/interfaces/SoulSocietyFactory/ISoulSocietyFactoryEnumable.sol";


/// @title Factory for managing growth type SBT developed by SoulSociety
/// @notice As a factory to manage the growth type SBT developed by SoulSociety, the factory was developed so that only onwers can change it.
contract SoulFactroy is ISoulSocietyFactoryEnumable, Ownable {

    string private _name;

    string private _symbol;
    
    mapping(string => SBTData) private _sbtMap;

    address[] private _contractList;

    mapping(address => string[]) private _contractBySbtList;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // ------------------------------------------------------------
    // Basic information function related to contract
    // ------------------------------------------------------------
    
    // Token Name
    function name() public view virtual returns (string memory) {
        return _name;
    }

    // Token Symbol
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    // -----------------------------------------------------------
    // ISoulSocietyFactoryEnumable
    // -----------------------------------------------------------
    
    function contractList() public override view returns (address[] memory) {
        return _contractList;
    }

    function sbtList(address contract_) public override view returns (string[] memory) {
        return _contractBySbtList[contract_];
    }

    function sbtData(string calldata sbt_) public override view returns (SBTData memory) {
        return _sbtMap[sbt_];
    }

    function contractCount() public override view returns (uint256) {
        return _contractList.length;
    }

    function sbtCount(address contract_) public override view returns (uint256) {
        return _contractBySbtList[contract_].length;
    }

    // -------------------------------------------------------------
    // ISoulSocietyFactory
    // -------------------------------------------------------------


    function addContract(address contract_) public override  onlyOwner {
        require(!_existContract(contract_), "duplicate Soul!!");
        _contractList.push(contract_);
    }

    // Check if the contract is already registered
    function _existContract(address contract_) private view returns (bool) {

        for(uint i = 0; i< _contractList.length; i++) {
            if(contract_ == _contractList[i]) {
                return true;
            }
        }
        return false;
    }

    function delContract(address contract_) public override onlyOwner {

        uint index;
        for (uint i = 0; i<_contractList.length; i++){
            if(contract_ == _contractList[i]) {
                index = i;
                break;
            }
        }
        _contractList[index] = _contractList[_contractList.length-1];
        _contractList.pop();

        // When deleting a contract, it needs to be modified so that the soul included in the contract is also deleted.
        delete _contractBySbtList[contract_];
    }

    function addSBT(address contract_, string calldata sbt_, string calldata uri_) public override onlyOwner {

        require(_existContract(contract_), "not exist soul!!");

        require(bytes(_sbtMap[sbt_].sbt).length == 0, "duplicate code!!");

        SBTData memory _meta = SBTData(sbt_, uri_);

        _sbtMap[sbt_] = _meta;

        _contractBySbtList[contract_].push(sbt_);
    }

    function delSBT(address contract_, string calldata sbt_) public override onlyOwner {

        require(bytes(_sbtMap[sbt_].sbt).length != 0, "not exist code!!");


        string[] memory _sbtList = _contractBySbtList[contract_];
        uint index;

        for(uint i = 0 ; i< _sbtList.length; i++) {
            index = i;
            if(keccak256(abi.encodePacked(_sbtList[i])) == keccak256(abi.encodePacked(sbt_))) {
                break;
            }
        }

        if(index > _sbtList.length) {
            revert("invaild soul and code!!");
        } else {
            _contractBySbtList[contract_][index] = _contractBySbtList[contract_][_sbtList.length-1];
            _contractBySbtList[contract_].pop();
            
            delete _sbtMap[sbt_];
        }
    }

    // -----------------------------------------------------------
    // validation against sbt
    // -----------------------------------------------------------

    function validSBT(string calldata sbt_) public view returns (bool) {
        
        require(!_existContract(msg.sender), "not exist soul!!");

        string[] memory _sbtList = _contractBySbtList[msg.sender];

        for(uint i = 0 ; i< _sbtList.length; i++) {
            if(keccak256(abi.encodePacked(_sbtList[i])) == keccak256(abi.encodePacked(sbt_))) {
                return true;
            }
        }

        revert("not exist sbt");
    }

}
