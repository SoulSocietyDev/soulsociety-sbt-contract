# SBT Hon Token Technical Specification

## Technical Specification
### Overview
* Name : HONSBT
* Symbol : HONSBT
* Total Supply : virtually unlimited (The token issuance is capped at the maximum value uint256 can represent )
* Decimals : 0

### Contract Details
* Network : Ethereum Mainnet
* Solidity Version : 0.8.20
* Compiler Settings: Optimization enabled with 200 runs
* Contract Address : Scheduled to record after deployment

### Functions & Events
#### Events
* event ContractCreated(address indexed creator, uint256 creationTime, string name, string symbol, string uri);
* event SetTokenURI(address indexed sender, string uri);
* event Mint(address from, address indexed to, uint256 indexed tokenId, uint256 indexed tokenType);
* event Reset(address indexed to, uint indexed tokenId);
* event GrowUp(address indexed to, uint256 tokenId, uint256 indexed growth);
#### Functions
* function mint(address to, uint256 tokenType) external returns (uint256);
* function growUp(address to, uint256 tokenId) external returns (uint256);
* function reset(address to, uint256 tokenId) external ; 
* function setTokenURI(string memory tokenURI) external returns(string memory);
* function setProtected(bool isProtected) external returns (bool);
* function setApprovalGrowth(uint256 tokenId_, bool approved_) external;
* function totalSupply() external view returns (uint256);
* function totalUser() external view  returns (uint256);
* function isProtected(address) external view returns (bool);
* function getGrowth(uint256 tokenId) external view returns (uint256);
* function getTokenType(uint256 tokenId_) external view returns (uint256);
* function getApprovalGrowth(address owner_, uint256 tokenId_ ) external view returns(bool);
* function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

### Dependencies and Libraries
* OpenZeppelin's ERC20 , ERC721, ERC165 library: For standard ERC-721 functions and security checks.

### Additional Notes
* The contract adheres to the ERC-721 standard

## Environment Configuration 

### Network
* Ethereum Maninet
* Ropsten Testnet

### Dev Tools
* Solidity : 0.8.20
* Remix :  Remix Ethereum IDE using a web browser.
* Basic understanding of Ethereum and its smart contract functionalities.

### Source
* [SoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/SoulSocietySBT.sol)

### Interface
* [ISoulSocietySBT.sol](https://github.com/SoulSocietyDev/soulsociety-sbt-contract/blob/master/v2/contracts/interfaces/ISoulSocietySBT.sol)
