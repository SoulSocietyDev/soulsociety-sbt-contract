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

    // @notice Emitted when user grows
    // @param to Address that user Address
    // @param growth User growth
    event GrowUp(address indexed to, uint256 tokenId, uint256 indexed growth);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address);



    // @notice This function contains user growth information.
    // @param Know current growth User's address
    function getGrowth(uint256 tokenId) external view returns (uint256);

    // @notice Function to grow users
    // @param Address of the user you want to grow
    // function growUp(address) external returns (uint256);
    function growUp(address to, uint256 tokenId) external returns (uint256);


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

    // @notice Function to change SBT to public
    // @param user address
    // @return true if successfully made public, false if already public or failed
    // function unProtected(address) external returns (bool);
}