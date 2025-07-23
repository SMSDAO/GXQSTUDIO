@echo off
echo Installing dependencies...
npm install @openzeppelin/contracts @chainlink/contracts @uniswap/v3-core @uniswap/v3-periphery dotenv

echo.
echo Compiling contracts...
npx hardhat compile

echo.
echo Done!
pause