// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./SoulSocietySBT.sol";

contract MySoulContract is SoulSocietySBT {
    constructor() SoulSocietySBT("http://api.soulsociety.gg/") {

    }
}