# FXSOLBOT Fast Build Script
Write-Host "===== FXSOLBOT Fast Build Script =====" -ForegroundColor Cyan
Write-Host ""

# Set environment variables for faster builds
$env:NODE_ENV = "production"
$env:NEXT_TELEMETRY_DISABLED = "1"

# Use parallel processing where possible
$MaxParallelJobs = [int]$env:NUMBER_OF_PROCESSORS
if ($MaxParallelJobs -gt 1) {
    $MaxParallelJobs = $MaxParallelJobs - 1  # Leave one core free
}
Write-Host "Using $MaxParallelJobs parallel processes for build" -ForegroundColor Yellow

# Install main project dependencies
Write-Host "Installing main project dependencies..." -ForegroundColor Yellow
npm install --no-audit
if ($LASTEXITCODE -ne 0) { Write-Host "Error installing main dependencies. Aborting."; exit 1 }

# Compile smart contracts
Write-Host "Compiling smart contracts..." -ForegroundColor Yellow
npx hardhat compile
if ($LASTEXITCODE -ne 0) { Write-Host "Error compiling contracts. Aborting."; exit 1 }

# Navigate to dashboard directory
Set-Location -Path "dashboard"

# Install dashboard dependencies
Write-Host "Installing dashboard dependencies..." -ForegroundColor Yellow
npm install --no-audit
if ($LASTEXITCODE -ne 0) { Write-Host "Error installing dashboard dependencies. Aborting."; exit 1 }

# Install Web3 polyfills if not already in node_modules
if (-not (Test-Path "node_modules/crypto-browserify")) {
    Write-Host "Installing Web3 polyfills..." -ForegroundColor Yellow
    npm install --save-dev --no-audit browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http
}

# Build Next.js application with optimizations
Write-Host "Building Next.js application with static export..." -ForegroundColor Yellow
$env:NEXT_OPTIMIZE_FONTS = "true"
$env:NEXT_OPTIMIZE_IMAGES = "true"
npm run electron:build
if ($LASTEXITCODE -ne 0) { Write-Host "Error building Next.js application. Aborting."; exit 1 }

# Build Windows executable with optimized settings
Write-Host "Building Windows executable..." -ForegroundColor Yellow
npm run package-win
if ($LASTEXITCODE -ne 0) { Write-Host "Error building Windows executable. Aborting."; exit 1 }

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "The executable can be found in the dashboard/dist folder." -ForegroundColor Green
Write-Host ""

# Check for Java installation
$javaVersion = $null
try {
    $javaVersion = & java -version 2>&1
    Write-Host "Java is installed:" -ForegroundColor Green
    Write-Host $javaVersion -ForegroundColor Green
} catch {
    Write-Host "WARNING: Java is not installed or not in PATH. This may cause issues when running the application." -ForegroundColor Red
    Write-Host "Please install Java Runtime Environment (JRE) version 8 or higher." -ForegroundColor Yellow
}

Pause