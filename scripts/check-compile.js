// Script to check if compilation works
const { execSync } = require('child_process');

try {
  console.log('Attempting to compile contracts...');
  const output = execSync('npx hardhat compile', { encoding: 'utf8' });
  console.log('Compilation successful!');
  console.log(output);
} catch (error) {
  console.error('Compilation failed with error:');
  console.error(error.message);
}