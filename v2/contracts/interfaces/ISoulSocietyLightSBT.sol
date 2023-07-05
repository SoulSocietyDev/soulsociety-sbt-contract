// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Growth type Lightweight SBT interface developed by SoulSociety
/// @notice There is a part where the gas fee required by Ethereum is too expensive to contain various information. 
/// Therefore, by considering each contract as a piece of information, we tried to implement growth-type SBT through minimum information and minimum gas cost by managing growth in the contract.
interface ISoulSocietyLightSBT {

    // @notice Emitted when user grows
    // @param to Address that user Address
    // @param growth User growth
    event GrowthUp(address indexed to, uint256 indexed growth);

    // @notice Emitted When user down-grown
    // @param to Address that user Address
    // @param growth User growth
    event GrowthDown(address indexed to, uint256 indexed growth);

    // @notice This function contains user growth information.
    // @param Know current growth User's address
    function growth(address) external view returns (uint256);

    // @notice Function to grow users
    // @param Address of the user you want to grow
    function growthUp(address) external returns (uint256);

    // @notice Function to down-growth
    // @param Address of the user you want to down-grow
    function growthDown(address) external returns (uint256);

    // @notice Function to check whether a specific SBT is public
    // @param user address
    // @return true when public, false when private
    function isProtected(address) external view returns (bool);

    // @notice A function that makes the SBT you hold private
    // @param user address
    // @return true when normally private, false when already locked or failed
    function protected(address) external returns (bool);

    // @notice Function to change SBT to public
    // @param user address
    // @return true if successfully made public, false if already public or failed
    function unProtected(address) external returns (bool);
}