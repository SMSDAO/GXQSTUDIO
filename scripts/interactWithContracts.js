// Script to interact with the deployed contracts
require('dotenv').config();
const { ethers } = require("ethers");
const fs = require('fs');
const path = require('path');

// Load contract ABIs
const getContractABI = (contractName) => {
  try {
    const artifactPath = path.join(__dirname, '..', 'artifacts', 'contracts', `${contractName}.sol`, `${contractName}.json`);
    const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
    return artifact.abi;
  } catch (error) {
    console.error(`Error loading ABI for ${contractName}:`, error.message);
    return null;
  }
};

async function main() {
  // Load private key from .env file
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    console.error("❌ Error: PRIVATE_KEY not found in .env file");
    process.exit(1);
  }

  // Connect to Base network
  const rpcUrl = process.env.BASE_RPC_URL || "https://mainnet.base.org";
  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey, provider);
  
  console.log(`🔑 Connected with wallet: ${wallet.address}`);
  
  // Get contract addresses from .env
  const flashLoanExecutorAddress = process.env.FLASH_LOAN_EXECUTOR_ADDRESS;
  const aggressiveArbitrageAddress = process.env.AGGRESSIVE_ARBITRAGE_ADDRESS;
  const leverageSwapAddress = process.env.LEVERAGE_SWAP_ADDRESS;
  
  // Check contract balances
  console.log("\n📊 Checking contract balances...");
  
  const flashLoanBalance = await provider.getBalance(flashLoanExecutorAddress);
  console.log(`FlashLoanExecutor balance: ${ethers.formatEther(flashLoanBalance)} ETH`);
  
  const arbitrageBalance = await provider.getBalance(aggressiveArbitrageAddress);
  console.log(`AggressiveArbitrage balance: ${ethers.formatEther(arbitrageBalance)} ETH`);
  
  const leverageBalance = await provider.getBalance(leverageSwapAddress);
  console.log(`LeverageSwap balance: ${ethers.formatEther(leverageBalance)} ETH`);
  
  // Load contract ABIs
  const flashLoanABI = getContractABI("FlashLoanExecutor");
  const arbitrageABI = getContractABI("AggressiveArbitrage");
  const leverageSwapABI = getContractABI("LeverageSwap");
  
  if (!flashLoanABI || !arbitrageABI || !leverageSwapABI) {
    console.log("\n⚠️ ABIs not found. Please compile the contracts first with 'npm run compile'.");
    return;
  }
  
  // Create contract instances
  const flashLoanExecutor = new ethers.Contract(flashLoanExecutorAddress, flashLoanABI, wallet);
  const aggressiveArbitrage = new ethers.Contract(aggressiveArbitrageAddress, arbitrageABI, wallet);
  const leverageSwap = new ethers.Contract(leverageSwapAddress, leverageSwapABI, wallet);
  
  console.log("\n✅ Contract instances created successfully!");
  console.log("\n📝 You can now interact with the contracts using these instances.");
  console.log("Example: To withdraw ETH from AggressiveArbitrage contract:");
  console.log("await aggressiveArbitrage.withdrawETH(wallet.address, ethers.parseEther('0.0005'))");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});