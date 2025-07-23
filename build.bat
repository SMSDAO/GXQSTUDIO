@echo off
echo ===== FXSOLBOT Build Script =====
echo.

echo Installing dependencies...
npm install

echo.
echo Compiling contracts...
npx hardhat compile

echo.
echo Build completed successfully!
echo.
echo Available commands:
echo npm run compile    - Compile contracts
echo npm run deploy     - Deploy contracts to Base network
echo npm run fund       - Fund deployed contracts with ETH
echo npm test           - Run tests
echo.
echo Deployed contract addresses:
echo AggressiveArbitrage: 0x4d0f4AC57E05a8903209Fd3CcC4c9bb0Ec92650c
echo FlashLoanExecutor:  0x01AD0EFDFE9d6da3311ECc180058F135c84B217e
echo LeverageSwap:       0xC6aC6A60cDE2C968E3aee47F9450ddf9b53F70F4
echo.
echo Remember to add your private key to the .env file before running deploy or fund commands.
echo.
pause