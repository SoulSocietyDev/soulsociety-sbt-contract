// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/SoulSocietyFactory/ISoulSocietyFactory.sol";


/// @title An interface that adds functions that can be more easily retrieved to the factory that manages growth-type SBTs
/// @notice The interface has added a function to easily search for registered contracts and sbt.
interface ISoulSocietyFactoryEnumable is ISoulSocietyFactory {

    // @notice A function that provides a list of contract addresses registered in the current factory
    // @return List of registered contract addresses
    function contractList() view external returns (address[] memory);

    // @notice Function to query the registered sbt of the contract
    // @param Contract address to look up
    // @return List of sbt registered in the contract
    function sbtList(address) view external returns (string[] memory);

    // @notice Function to query specific sbt information
    // @param sbt you want to query
    // @return A structure containing the retrieved sbt and uri
    function sbtData(string calldata) view external returns (SBTData memory);

    // @notice A function to query the amount of contracts registered in the factory
    // @return Contract quantity registered in factory
    function contractCount() view external returns (uint256);

    // @notice A function that retrieves the amount of sbt registered in a specific contract
    // @param Contract address to look up
    // @return Amount of sbt registered in the contract
    function sbtCount(address) view external returns (uint256);
    
}
