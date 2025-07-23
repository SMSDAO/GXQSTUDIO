# FXSOLBOT Windows Application Build Instructions

## Overview

This document provides instructions for building the FXSOLBOT Windows application, which includes a dashboard with Web3 integration for interacting with smart contracts.

## Prerequisites

- Node.js (v14 or higher)
- npm (v6 or higher)
- PowerShell
- Windows operating system

## Build Process

We've created a PowerShell script that automates the entire build process. This script handles:

1. Installing main project dependencies
2. Compiling smart contracts using Hardhat
3. Installing dashboard dependencies including Web3 polyfills
4. Building the Next.js application with static export
5. Building the Windows executable using Electron Builder

## How to Build

### Using the PowerShell Script (Recommended)

1. Open PowerShell with administrator privileges
2. Navigate to the project root directory
3. Run the following command:

```powershell
powershell -ExecutionPolicy Bypass -File .\build-windows-app.ps1
```

### Manual Build Process

If you prefer to build manually, follow these steps:

1. Install main project dependencies:
   ```
   npm install
   ```

2. Compile smart contracts:
   ```
   npx hardhat compile
   ```

3. Navigate to the dashboard directory:
   ```
   cd dashboard
   ```

4. Install dashboard dependencies including Web3 polyfills:
   ```
   npm install
   npm install --save-dev browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http
   ```

5. Build the Next.js application with static export:
   ```
   npm run electron:build
   ```

6. Build the Windows executable:
   ```
   npm run package-win
   ```

## Output

After a successful build, you'll find the following in the `dashboard/dist` directory:

- `NEON Aurora Dashboard Setup 1.0.0.exe` - Windows installer
- `win-unpacked` directory - Unpacked application files

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**
   
   If you encounter execution policy errors, run PowerShell as administrator and use:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```

2. **Missing Web3 Polyfills**
   
   If you encounter errors related to missing modules like `crypto-browserify`, ensure you've installed all the required polyfills:
   ```
   npm install --save-dev browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http
   ```

3. **Next.js Export Errors**
   
   If you see errors related to `next export`, ensure your `next.config.js` has `output: 'export'` configured and that the `electron:build` script in `package.json` is set to `next build`.

## Running the Application

After building, you can run the application in one of two ways:

1. Install using the setup executable: `NEON Aurora Dashboard Setup 1.0.0.exe`
2. Run directly from the unpacked directory: `dist\win-unpacked\NEON Aurora Dashboard.exe`