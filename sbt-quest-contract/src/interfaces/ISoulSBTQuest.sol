// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title Growth type Lightweight SBT interface developed by SoulSociety
/// @notice There is a part where the gas fee required by Ethereum is too expensive to contain various information. 
/// Therefore, by considering each contract as a piece of information, we tried to implement growth-type SBT through minimum information and minimum gas cost by managing growth in the contract.
interface ISoulSBTQuest {

    event ContractCreated(address indexed creator, uint256 creationTime, string name, string symbol);
    
    event SetTokenURI(address indexed sender, string uri);

    /**
     * @dev Emitted when `tokenId` token is minted from `from(Contract Owner)` to `to`.
     */
    event Mint(address from, address indexed to, uint256 indexed tokenId, uint256 indexed tokenType);

    event Reset(address indexed to, uint indexed tokenId);

    // @notice Emitted when user grows
    // @param to Address that user Address
    // @param tokenType SBT Quest Id
    // @param count processed Count
    event Increase(address indexed to, uint256 tokenType, uint256 indexed count);

    function mint(address to_, uint256 tokenType_) external returns (uint256);

    // @notice Function to increase user's history
    // @param Address of the user you want to increase
    // function increase(address, tokenTpe) external returns (uint256);
    function increase(address to, uint256 tokenType_) external returns (uint256);

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */

    function totalCompletionCount() external view returns (uint256);

    // @notice A function that provides the number of currently registered users
    // @return Number of currently registered users
    function totalUser() external view  returns (uint256);

    function getTokenId(address to_, uint256 tokenType_) external view returns(uint256); 

    // @notice This function contains user growth information.
    // @param tokem Id
    function getCompletionCount(address to_, uint256 tokenType_) external view returns (uint256);

    function getTokenType(uint256 tokenId_) external view returns (uint256);
}