<<<<<<< HEAD
# GXQSTUDIO
=======
# FXSOLBOT - NEON Aurora Dashboard

<p align="center">
  <img src="dashboard/public/images/neon-logo.svg" alt="FXSOLBOT Logo" width="200" height="200">
</p>

## Overview

FXSOLBOT is a powerful DeFi automation platform with a modern 3D dashboard for managing smart contracts, flash loans, and trading bots. The application is built with Electron, React, Next.js, and Web3 technologies, providing a seamless experience for interacting with blockchain networks.

## Features

- **Modern 3D Dashboard**: Interactive 3D interface built with Three.js and React Three Fiber
- **Smart Contract Integration**: Seamlessly interact with Ethereum and other EVM-compatible blockchains
- **Flash Loan Automation**: Execute flash loan strategies with a few clicks
- **Trading Bot Management**: Configure and monitor automated trading strategies
- **Cross-Platform Support**: Available for Windows, macOS, and Linux

## Multi-Chain Arbitrage Setup

- Configure networks and RPC rotation in [dashboard/src/config/networks.ts](dashboard/src/config/networks.ts); Ethereum, Polygon, and Base are enabled via `.env` flags.
- Register plug-and-play strategies (DEX→DEX and triangular) in [dashboard/src/config/strategies.ts](dashboard/src/config/strategies.ts) and map deployed executor addresses per chain.
- Flash loans: the dashboard/bot calls `executeFlashArb` on [contracts/ArbitrageExecutorV2.sol](contracts/ArbitrageExecutorV2.sol), which borrows from the configured pool, executes swaps, repays, and reverts if profit cannot cover principal + premium.
- Fees from profit only: 0.01% to the dev address (gxqstudio.eth, set via `setDev`), and configurable admin fees capped at 20%; no profit means no fee, and transactions revert if repayment or `minProfit` is missed.
- Off-chain discovery: price scanners pull router quotes, estimate gas/premium, and only submit on-chain when expected profit clears the safety margin; see [dashboard/src/lib/arbitrageScanner.ts](dashboard/src/lib/arbitrageScanner.ts) and [dashboard/src/lib/executionClient.ts](dashboard/src/lib/executionClient.ts).
- Add a new chain by extending `NETWORKS` in [dashboard/src/config/networks.ts](dashboard/src/config/networks.ts) and providing router + flash-loan provider addresses; add a new strategy by appending to [dashboard/src/config/strategies.ts](dashboard/src/config/strategies.ts).
- Testnets: point RPCs to test endpoints, lower `MAX_CAPITAL_PER_TRADE`, and deploy `ArbitrageExecutorV2` to the testnet before wiring executor addresses in the strategy registry.

## Quick Start

### Prerequisites

- Node.js (v14 or higher)
- npm (v6 or higher)
- Java Runtime Environment (JRE 8 or higher)

### Installation

#### Windows

1. Download the latest installer from the releases page
2. Run the installer and follow the prompts
3. Launch the application from the Start menu

#### Development Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/fxsolbot.git
   cd fxsolbot
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Compile smart contracts:
   ```
   npx hardhat compile
   ```

4. Navigate to the dashboard directory and install dependencies:
   ```
   cd dashboard
   npm install
   ```

5. Start the development server:
   ```
   npm run electron:dev
   ```

### Building the Application

#### Using the Fast Build Script (Recommended)

```powershell
powershell -ExecutionPolicy Bypass -File .\fast-build.ps1
```

This script optimizes the build process for faster completion.

#### Manual Build

```powershell
powershell -ExecutionPolicy Bypass -File .\build-windows-app.ps1
```

## Deployment

### VPS Deployment with Plesk

For detailed instructions on deploying to a VPS with Plesk, see the [VPS Deployment Guide](VPS_DEPLOYMENT_GUIDE.md).

### Docker Deployment

The application can be deployed using Docker:

```bash
docker-compose up -d --build
```

## Troubleshooting

### Java-related Errors

If you encounter Java-related errors when launching the application, run the Java error fix script:

```powershell
powershell -ExecutionPolicy Bypass -File .\fix-java-error.ps1
```

### Slow Build Process

If the build process is taking too long, use the optimized fast build script:

```powershell
powershell -ExecutionPolicy Bypass -File .\fast-build.ps1
```

## Customization

### Generating Custom Icons

To generate custom icons and images for different devices and platforms:

```powershell
powershell -ExecutionPolicy Bypass -File .\generate-images.ps1
```

This script requires ImageMagick to be installed on your system.

## Project Structure

```
├── contracts/            # Smart contract source files
├── dashboard/            # Electron + Next.js application
│   ├── electron/         # Electron main process files
│   ├── public/           # Static assets
│   └── src/              # Application source code
│       ├── components/   # React components
│       ├── contexts/     # React context providers
│       ├── hooks/        # Custom React hooks
│       ├── pages/        # Next.js pages
│       └── styles/       # CSS and SCSS files
├── scripts/              # Deployment and utility scripts
└── test/                 # Test files
```

## Technologies Used

- **Frontend**: React, Next.js, Three.js, Framer Motion
- **Backend**: Electron, Node.js
- **Blockchain**: Web3.js, Ethers.js, Hardhat
- **Styling**: SCSS, Bootstrap
- **Packaging**: Electron Builder

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
>>>>>>> b514f0c (Initial commit: FXSOLBOT - Complete arbitrage trading bot with dashboard and smart contracts)
