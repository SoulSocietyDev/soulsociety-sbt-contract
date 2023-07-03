// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Modified ERC5192 interface that is the basis of growth type SBT developed by SoulSociety
/// @notice Since SBT does not require a transmission function, except for ERC721, ERC5192 has been modified to allow users who have SBT to set public or private information.
interface IERC5192transform {

  // @notice Emitted when locked from sending
  // @param SBT's unique ID
  event Locked(uint256 tokenId);

  // @notice Emitted when unlocking to allow transmission
  // @param SBT's unique ID
  event Unlocked(uint256 tokenId);

  // @notice Function to check whether there is a lock
  // @param SBT's unique ID
  // @return true when lock, false when unlock
  function isLocked(uint256 tokenId) external view returns (bool);

  // @notice A function that locks the transmission
  // @param SBT's unique ID
  // @return true when normally locked, false when already locked or failed
  function lock(uint256 tokenId) external returns (bool);

  // @notice A function that unlocks the transmittable
  // @param SBT's unique ID
  // @return true if successfully made unlocked, false if already unlocked or failed
  function unlock(uint256 tokendId) external returns (bool);
}
