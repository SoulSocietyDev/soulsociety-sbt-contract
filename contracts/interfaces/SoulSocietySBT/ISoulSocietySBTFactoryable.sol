// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/SoulSocietySBT/ISoulSocietySBTEnumable.sol";

/// @title This is an interface that can be managed by adding a factory to manage more usefully when multiple growth-type SBT contracts are issued.
/// @notice An interface version that can use a factory that manages multiple growing SBT contracts
interface ISoulSocietySBTFactoryable is ISoulSocietySBTEnumable {

    // @notice This function specifies the Factory contract that manages contracts.
    // @param Factory address
    function setFactory(address) external ;

    // @notice This function searches the currently set factory address.
    // @return set factory address
    function factory() external view returns (address);
}
