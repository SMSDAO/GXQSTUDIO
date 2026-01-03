# Running FXSOLBOT on Localhost

This guide explains how to run the FXSOLBOT contracts on a local Hardhat network for development and testing.

## Prerequisites

- Node.js (v16+)
- npm or yarn
- All dependencies installed (`npm install`)

## Starting a Local Hardhat Node

You can start a local Hardhat node in two ways:

### Option 1: Using the convenience script

Run the following command to start a local node and automatically deploy all contracts:

```
npm run local
```

This will:
1. Start a local Hardhat node
2. Deploy all contracts to the local network
3. Display the contract addresses

### Option 2: Manual setup

Start a local Hardhat node in one terminal:

```
npm run node
```

Then, in a separate terminal, deploy the contracts:

```
npm run deploy:local
```

## Testing the Contracts

Run the test suite to verify the contracts are working correctly:

```
npm test
```

## Interacting with Deployed Contracts

After deploying the contracts to the local network, you can interact with them using the provided script:

```
node scripts/interactWithContracts.js
```

Or using Hardhat console:

```
npx hardhat console --network localhost
```

Then you can interact with the contracts using JavaScript:

```javascript
// Example: Get contract instances
const FlashLoanArbitrage = await ethers.getContractFactory("FlashLoanArbitrage");
const flashLoanArbitrage = await FlashLoanArbitrage.attach("CONTRACT_ADDRESS");

// Example: Call a contract method
const feePercentage = await flashLoanArbitrage.feePercentage();
console.log("Fee percentage:", feePercentage.toString());
```

## Local Accounts

Hardhat provides 20 test accounts with 10000 ETH each. The first account is used as the contract deployer and owner.

You can access these accounts in your scripts:

```javascript
const [owner, user1, user2] = await ethers.getSigners();
```

## Troubleshooting

### Reset Local Network

If you encounter issues with the local network, you can reset it by stopping the node (Ctrl+C) and restarting it.

### Contract Verification

Contract verification is not needed on local networks, but if you want to practice the verification process, you can use:

```
npx hardhat verify --network localhost CONTRACT_ADDRESS [CONSTRUCTOR_ARGS]
```

## Next Steps

After testing on localhost, you can deploy to Base testnet or mainnet using:

```
npm run deploy -- --network base
```

Make sure to fund your account with ETH on the target network before deploying.