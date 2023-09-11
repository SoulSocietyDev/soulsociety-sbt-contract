// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Growth type Lightweight SBT interface developed by SoulSociety
/// @notice There is a part where the gas fee required by Ethereum is too expensive to contain various information. 
/// Therefore, by considering each contract as a piece of information, we tried to implement growth-type SBT through minimum information and minimum gas cost by managing growth in the contract.
interface ISoulSocietySBT {

    /**
     * @dev Emitted when `tokenId` token is minted from `from(Contract Owner)` to `to`.
     */
    event Mint(address from, address indexed to, uint256 indexed tokenId, uint256 indexed tokenType);

    event Burn(address indexed to, uint indexed tokenId);

    // @notice Emitted when user grows
    // @param to Address that user Address
    // @param growth User growth
    event GrowUp(address indexed to, uint256 tokenId, uint256 indexed growth);


    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    // @notice A function that provides the number of currently registered users
    // @return Number of currently registered users
    function totalUser() external view  returns (uint256);

    function setTokenURI(string memory tokenURI) external returns(string memory);

    // @notice This function contains user growth information.
    // @param Know current growth User's address
    function getGrowth(uint256 tokenId) external view returns (uint256);

    // @notice Function to grow users
    // @param Address of the user you want to grow
    // function growUp(address) external returns (uint256);
    function growUp(address to, uint256 tokenId) external returns (uint256);

    function burn(address to, uint256 tokenId) external ; 

    function getTokenType(uint256 tokenId_) external view returns (uint256);

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, uint256 tokenType) external returns (uint256);


    // @notice Function to down-growth
    // @param Address of the user you want to down-grow
    // function growDown(address) external returns (uint256);

    // @notice Function to check whether a specific SBT is public
    // @param user address
    // @return true when public, false when private
    function isProtected(address) external view returns (bool);

    // @notice A function that makes the SBT you hold private
    // @param user address
    // @return true when normally private, false when already locked or failed
    function setProtected(address to, bool isProtected) external returns (bool);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}