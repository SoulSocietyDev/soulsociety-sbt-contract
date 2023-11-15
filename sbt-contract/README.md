# Development Environment Configuration

## Token Specification
### SBTHON Token Overview
* Name : HONSBT
* Symbol : HONSBT
* Total Supply : virtually unlimited (The token issuance is capped at the maximum value uint256 can represent )
* Decimals : 0

### Contract Details
* Network : Ethereum Mainnet
* Solidity Version : 0.8.20
* Compiler Settings: Optimization enabled with 200 runs

### Dev Tools
* Build with Foundry Framework 

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
forge init sbt-contract
````
#### 3. Navigate to the Project Directory: 
````
cd sbt-contract/src
````

#### 4. Install Dependencies
````
npm install @openzeppelin/contracts
forge install OpenZeppelin/openzeppelin-contracts
````

#### 5. Build & Test the Solidity File (SoulSocietySBT.sol) in the sbt-contract/src Directory:
````
forge build
forge test
````

#### 6. Deploy
````
forge create --rpc-url NODE_HTTP_URL \
--private-key YOUR_PRIVATE_KEY \
src/MySoulSociety.sol:MySoulSociety 
````

### Source
#### HON SBT
* [SoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/SoulSocietySBT.sol)

### Interface
* [ISoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/interfaces/ISoulSocietySBT.sol)
