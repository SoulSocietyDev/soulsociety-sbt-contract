// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "v2/contracts/interfaces/ISoulSocietySBT.sol";

/// @title Lightweight Growth type SBT interface developed by SoulSociety
/// @notice There is a part where the gas fee required by Ethereum is too expensive to contain various information. 
/// Therefore, by considering each contract as a piece of information, we tried to implement growth-type SBT through minimum information and minimum gas cost by managing growth in the contract.
interface ISoulSocietyLightEnumableSBT is ISoulSocietySBT {

    // @notice A function that provides the number of currently registered users
    // @return Number of currently registered users
    function totalUser() external view returns(uint256);

    // @notice A function to view the URL providing details of the contract
    // @return URI containing contract information
    function tokenURI() external view returns (string memory);

    // @ntocie A function that registers the URI that holds contract information
    // @param URI to register
    // @return Registered URI
    function setTokenURI(string memory) external returns(string memory);

    // @notice A function to query the time at which a certain growth was achieved.
    // @param Address of the user you want to check
    // @param Growth you want to see
    // @return Time achieved, 0 means not achieved
    function growthDate(address, uint256) external view returns (uint);
}
