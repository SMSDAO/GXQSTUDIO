// Script to fund the deployed contracts with ETH
require('dotenv').config();
const { ethers } = require("ethers");

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
  
  console.log(`🔑 Using wallet: ${wallet.address}`);
  
  // Get contract addresses from .env or use the deployed ones
  const flashLoanExecutorAddress = process.env.FLASH_LOAN_EXECUTOR_ADDRESS || "0x01AD0EFDFE9d6da3311ECc180058F135c84B217e";
  const aggressiveArbitrageAddress = process.env.AGGRESSIVE_ARBITRAGE_ADDRESS || "0x4d0f4AC57E05a8903209Fd3CcC4c9bb0Ec92650c";
  const leverageSwapAddress = process.env.LEVERAGE_SWAP_ADDRESS || "0xC6aC6A60cDE2C968E3aee47F9450ddf9b53F70F4";
  
  // Fund FlashLoanExecutor
  console.log(`💸 Funding FlashLoanExecutor (${flashLoanExecutorAddress}) with 0.001 ETH...`);
  const tx1 = await wallet.sendTransaction({
    to: flashLoanExecutorAddress,
    value: ethers.parseEther("0.001"),
    gasLimit: 100000,
  });
  console.log(`✅ Transaction sent: ${tx1.hash}`);
  await tx1.wait();
  console.log("✅ Transaction confirmed!");
  
  // Fund AggressiveArbitrage
  console.log(`💸 Funding AggressiveArbitrage (${aggressiveArbitrageAddress}) with 0.001 ETH...`);
  const tx2 = await wallet.sendTransaction({
    to: aggressiveArbitrageAddress,
    value: ethers.parseEther("0.001"),
    gasLimit: 100000,
  });
  console.log(`✅ Transaction sent: ${tx2.hash}`);
  await tx2.wait();
  console.log("✅ Transaction confirmed!");
  
  // Fund LeverageSwap
  console.log(`💸 Funding LeverageSwap (${leverageSwapAddress}) with 0.001 ETH...`);
  const tx3 = await wallet.sendTransaction({
    to: leverageSwapAddress,
    value: ethers.parseEther("0.001"),
    gasLimit: 100000,
  });
  console.log(`✅ Transaction sent: ${tx3.hash}`);
  await tx3.wait();
  console.log("✅ Transaction confirmed!");
  
  console.log("✅ All contracts funded successfully!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});