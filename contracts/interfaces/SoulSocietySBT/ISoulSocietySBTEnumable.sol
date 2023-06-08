// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/SoulSocietySBT/ISoulSocietySBT.sol";

/// @title Interface with inquiry function added for growth type SBT
/// @notice A function has been added to search by user and by SBT.
interface ISoulSocietySBTEnumable is ISoulSocietySBT {

    // @notice This is a function for the name entered when deploying the contract.
    // @return contract's name
    function name() external view returns (string memory);
	
    // @notice This is a function for the symbol entered when deploying the contract.
    // @return contract's symbol
    function symbol() external view returns (string memory);

    // @notice This function provides a list of SBT information possessed by a specific address.
    // @param Address of the wallet you want to query
    // @return List of SBT IDs held by the wallet
    function tokenListByAddressOf(address) external view returns (uint256[] memory);

    // @notice This function retrieves the amount of SBT held by a specific wallet.
    // @param Address of the wallet you want to query
    // @return The amount of SBT held by the wallet
    function tokenCountByAddresOf(address) external view returns (uint256);

    // @notice This function can search SBTs issued with specific SBT properties.
    // @param sbt you want to query
    // @return List of SBT IDs with corresponding sbt attributes
    function tokenListBySBTOf(string calldata) external view returns (uint256[] memory);

    // @notice This function searches the quantity of SBT issued with a specific sbt attribute.
    // @param sbt you want to query
    // @return Quantity of SBT issued with the corresponding sbt attribute
    function tokenCountBySBTOf(string calldata) external view returns (uint256);
    
}
