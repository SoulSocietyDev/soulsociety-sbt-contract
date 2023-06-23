// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/IERC5192transform.sol";

/// @title Growth type SBT interface developed by SoulSociety
/// @notice SoulSociety's growing SBT was written to disable the transfer of NFTs and raise the level of certain attributes to turn off.
interface ISoulSocietySBT is IERC5192transform {

    // @notice Emitted when SBT grows
    // @param tokenId SBT's unique ID
    // @param to Address that owns the SBT
    event LevelUp(uint256 indexed tokenId, address indexed to);

    // @notice Emitted when SBT is first issued
    // @param from Address to issue SBT, but issuance is possible only by the owner of the contract.
    // @param to Address to receive SBT
    // @param tokenId SBT's unique ID
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // @notice This is a structure that gives SBT properties. It has a similar function to NFT meta data.
    // @var sbt It is a variable for differentiating SBTs by assigning specific properties.
    struct SoulSocietyData {
        SoulSocietyDetail[] levelData;
        string uri;
    }

    struct SoulSocietyDetail{
        uint256 level;
        uint date;
    }

    // @notice This function finds the owner of a specific SBT.
    // @param tokenId SBT's unique ID
    // @return owner Address of the owner of the SBT
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // @notice This is a function that allows you to know the total number of issued SBT.
    // @return Total number of issued SBT
    function totalSupply() external view returns (uint256);

    // @notice This is a function to know the growth information of a specific SBT.
    // @param SBT's unique ID
    // @return This is a list containing growth information. It contains data about the level and when the level was achieved.
    function levelData(uint256) external view returns (SoulSocietyDetail[] memory);

    // @notice This function allows you to know about the URI that provides additional information of SBT.
    // @param SBT's unique ID
    // @return URI containing additional information of SBT
    function tokenURI(uint256) external view returns (string memory);

    // @notice It is a function that grows SBT.
    // @dev Parameters have been added to check the validity of most of them.
    // @param owner Address of the owner of the SBT
    // @param SBT's unique ID
    // @param level to grow
    function levelUp(address, uint256, uint256) external;

    // @notice Function to check whether a specific SBT is public
    // @param SBT's unique ID
    // @return true when public, false when private
    function isProtected(uint256 tokenId) external view returns (bool);

    // @notice A function that makes the SBT you hold private
    // @param SBT's unique ID
    // @return true when normally private, false when already locked or failed
    function protected(uint256 tokenId) external returns (bool);

    // @notice Function to change SBT to public
    // @param SBT's unique ID
    // @return true if successfully made public, false if already public or failed
    function unProtected(uint256 tokendId) external returns (bool);

}