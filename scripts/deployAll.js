// Script to deploy all contracts to Base network
require('dotenv').config();
const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Deploying AggressiveArbitrage...");
  const AggressiveArbitrage = await ethers.getContractFactory("AggressiveArbitrage");
  const aggressiveArbitrage = await AggressiveArbitrage.deploy();
  await aggressiveArbitrage.waitForDeployment();
  console.log("✅ AggressiveArbitrage deployed at:", await aggressiveArbitrage.getAddress());

  // Get the Balancer Vault address from env or use the default one
  const balancerVaultAddress = process.env.BALANCER_VAULT_ADDRESS || "0xBA12222222228d8Ba445958a75a0704d566BF2C8";
  
  console.log(`🚀 Deploying FlashLoanExecutor (using provider: ${balancerVaultAddress} )`);
  const FlashLoanExecutor = await ethers.getContractFactory("FlashLoanExecutor");
  const flashLoanExecutor = await FlashLoanExecutor.deploy(balancerVaultAddress);
  await flashLoanExecutor.waitForDeployment();
  console.log("✅ FlashLoanExecutor deployed at:", await flashLoanExecutor.getAddress());

  console.log("🚀 Deploying LeverageSwap...");
  const LeverageSwap = await ethers.getContractFactory("LeverageSwap");
  const leverageSwap = await LeverageSwap.deploy();
  await leverageSwap.waitForDeployment();
  console.log("✅ LeverageSwap deployed at:", await leverageSwap.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });