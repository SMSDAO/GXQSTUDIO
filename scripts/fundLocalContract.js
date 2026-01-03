// Script to fund the locally deployed contracts with ETH
const { ethers } = require("hardhat");

async function main() {
  // Get signers
  const [deployer] = await ethers.getSigners();
  console.log(`🔑 Using wallet: ${deployer.address}`);
  
  // Get contract addresses from the most recent deployment
  const flashLoanArbitrageAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
  const aggressiveArbitrageAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
  const flashLoanExecutorAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
  const leverageSwapAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
  
  const amount = "0.01"; // ETH amount to send
  
  // Fund FlashLoanArbitrage
  console.log(`💸 Funding FlashLoanArbitrage (${flashLoanArbitrageAddress}) with ${amount} ETH...`);
  const tx1 = await deployer.sendTransaction({
    to: flashLoanArbitrageAddress,
    value: ethers.parseEther(amount),
  });
  console.log(`✅ Transaction sent: ${tx1.hash}`);
  await tx1.wait();
  console.log("✅ Transaction confirmed!");
  
  // Fund AggressiveArbitrage
  console.log(`💸 Funding AggressiveArbitrage (${aggressiveArbitrageAddress}) with ${amount} ETH...`);
  const tx2 = await deployer.sendTransaction({
    to: aggressiveArbitrageAddress,
    value: ethers.parseEther(amount),
  });
  console.log(`✅ Transaction sent: ${tx2.hash}`);
  await tx2.wait();
  console.log("✅ Transaction confirmed!");
  
  // Fund FlashLoanExecutor
  console.log(`💸 Funding FlashLoanExecutor (${flashLoanExecutorAddress}) with ${amount} ETH...`);
  const tx3 = await deployer.sendTransaction({
    to: flashLoanExecutorAddress,
    value: ethers.parseEther(amount),
  });
  console.log(`✅ Transaction sent: ${tx3.hash}`);
  await tx3.wait();
  console.log("✅ Transaction confirmed!");
  
  // Fund LeverageSwap
  console.log(`💸 Funding LeverageSwap (${leverageSwapAddress}) with ${amount} ETH...`);
  const tx4 = await deployer.sendTransaction({
    to: leverageSwapAddress,
    value: ethers.parseEther(amount),
  });
  console.log(`✅ Transaction sent: ${tx4.hash}`);
  await tx4.wait();
  console.log("✅ Transaction confirmed!");
  
  console.log("✅ All contracts funded successfully!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});