// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Implemented a factory to manage and validate multiple growth-type SBT contracts.
/// @notice After distributing the growth type SBT contract, register it in the factory to check management and validity.
interface ISoulSocietyFactory {

    // @notice In growth-type SBT, there is a concept called sbt that points to a specific field or attribute. 
    // Structure for URI containing sbt and additional information of sbt.
    struct SBTData {
        string sbt;
        string uri;
    }

    // @notice This function adds the growth type SBT contract that the factory wants to manage.
    // @param The contract address you want to manage
    function addContract(address) external;

    // @notice This function removes growth type SBTs that are excluded from management or are no longer used.
    // @param The contract address you want to remove
    function delContract(address) external;

    // @notice In order to separate and manage a specific field for each growth type SBT contract, set the sbt (field) that can be issued in the contract.
    // @param Contract address to which you want to add sbt (field)
    // @param sbt you want to add
    // @param uri containing the information of the sbt to be added
    function addSBT(address, string calldata, string calldata) external ;

    // @notice This function removes sbts that are no longer issued or managed in the growing SBT contract.
    // @param Contract address to remove sbt
    // @param sbt you want to remove
    function delSBT(address, string calldata) external;
}
