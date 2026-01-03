@echo off
echo ===== FXSOLBOT Windows App Build Script =====
echo.

:: Install main project dependencies first
echo Installing main project dependencies...
npm install

:: Compile smart contracts
echo Compiling smart contracts...
npx hardhat compile

:: Navigate to dashboard directory
cd dashboard

:: Install dashboard dependencies including Web3 polyfills
echo Installing dashboard dependencies...
npm install
npm install --save-dev browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http

echo.
echo Building Next.js application with static export...
npm run electron:build

echo.
echo Building Windows executable...
npm run package-win

echo.
echo Build completed successfully!
echo The executable can be found in the dashboard/dist folder.
echo.
pause