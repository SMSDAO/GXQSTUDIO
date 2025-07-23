// Script to run a local Hardhat node and deploy contracts
const { spawn } = require('child_process');
const path = require('path');

// Start a local Hardhat node with a custom port (8546 instead of default 8545)
const nodeProcess = spawn('npx', ['hardhat', 'node', '--port', '8546'], {
  stdio: 'inherit',
  shell: true
});

// Wait for the node to start (adjust timeout as needed)
setTimeout(() => {
  console.log('\n🚀 Deploying contracts to local node...');
  
  // Deploy contracts to the local node
  const deployProcess = spawn('npx', ['hardhat', 'run', 'scripts/deploy.js', '--network', 'localhost'], {
    stdio: 'inherit',
    shell: true
  });
  
  deployProcess.on('close', (code) => {
    if (code !== 0) {
      console.error(`❌ Deployment process exited with code ${code}`);
    } else {
      console.log('\n✅ Contracts deployed successfully to local node!');
      console.log('\n📝 You can now interact with the contracts using:');
      console.log('npx hardhat run scripts/interactWithContracts.js --network localhost');
    }
  });
}, 5000); // Wait 5 seconds for the node to start

// Handle process termination
process.on('SIGINT', () => {
  nodeProcess.kill();
  process.exit();
});