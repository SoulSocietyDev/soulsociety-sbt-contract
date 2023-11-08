# Development Environment Configuration

## Token Specification
### HON Token Overview
* Name : HON
* Symbol : HON
* Total Supply : 1,000,000,000
* Decimals : 18

### SBTHON Token Overview
* Name : HONSBT
* Symbol : HONSBT
* Total Supply : virtually unlimited (The token issuance is capped at the maximum value uint256 can represent )
* Decimals : 0

### Contract Details
* Network : Ethereum Mainnet
* Solidity Version : 0.8.20
* Compiler Settings: Optimization enabled with 200 runs

### Dependencies and Libraries
* OpenZeppelin's ERC20 , ERC721, ERC165 library: For standard ERC-721 functions and security checks.

### Additional Notes
* The contract adheres to the ERC-721 standard

## Environment Configuration
### Network
* Ethereum Maninet
* Ropsten Testnet


### Setting up with Foundry:
Foundry is a Rust-based Ethereum development toolkit that includes forge for testing and deployment, 
and cast for blockchain state manipulation.

#### 1. Install Foundry
````
curl -L https://foundry.paradigm.xyz | bash
foundryup
````

#### 2. Create a New Project:
````
forge init SoulSocietySBT
````

#### 3. Navigate to the Project Directory:
````
cd sbt-contract
````

#### 4. Write the Solidity File (SoulSocietySBT.sol) in the v2/contracts Directory:
SoulSocietySBT.sol
````
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "v2/contracts/interfaces/ISoulSocietyEnumerableSBT.sol";
import "v2/contracts/interfaces/ISoulSocietySBTMetadata.sol";
import "v2/contracts/interfaces/ISoulSocietySBTErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";


/// @title Implementation contract of  growth type SBT developed by SoulSociety
/// @notice As an implementation of ISoulSocietySBT, only the owner can modify growth.
contract SoulSocietySBT is ISoulSocietySBT, ISoulSocietySBTMetadata, ISoulSocietySBTErrors , IERC721, ERC165, Ownable {

    using Strings for uint256;

    // token Name
    string private constant _name = "HONSBT";

    // token Symbol
    string private constant _symbol= "HONSBT";
    .......
    .......
    
````
Write the Solidity File (HonContract.sol) in the hon/contracts Directory:
HonContract.sol
````
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HONToken is ERC20, Ownable {

    uint256 private constant MAX_SUPPLY = 1000000000 * (10 ** 18);

    constructor() ERC20("HON Token", "HON") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting would exceed max supply");

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
````
#### 5. Compile & Test 
````
forge build
forge test
````


### Source
#### HON SBT
* [SoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/SoulSocietySBT.sol)

#### HON Token 
* [HonContract.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/hon/contracts/HonContract.sol)

### Interface
* [ISoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/interfaces/ISoulSocietySBT.sol)
