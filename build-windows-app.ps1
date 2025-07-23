# FXSOLBOT Windows App Build Script
Write-Host "===== FXSOLBOT Windows App Build Script =====" -ForegroundColor Cyan
Write-Host ""

# Install main project dependencies first
Write-Host "Installing main project dependencies..." -ForegroundColor Yellow
npm install

# Compile smart contracts
Write-Host "Compiling smart contracts..." -ForegroundColor Yellow
npx hardhat compile

# Navigate to dashboard directory
Set-Location -Path "dashboard"

# Clean up previous build artifacts
Write-Host "Cleaning up previous build artifacts..." -ForegroundColor Yellow
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
if (Test-Path "node_modules") { Remove-Item -Recurse -Force "node_modules" }

# Install dashboard dependencies including Web3 polyfills
Write-Host "Installing dashboard dependencies..." -ForegroundColor Yellow
npm install
npm install --save-dev browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http

Write-Host ""
Write-Host "Building Next.js application with static export..." -ForegroundColor Yellow
npm run electron:build

Write-Host ""
Write-Host "Building Windows executable..." -ForegroundColor Yellow
npm run package-win

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "The executable can be found in the dashboard/dist folder." -ForegroundColor Green
Write-Host ""
Pause