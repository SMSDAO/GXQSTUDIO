// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IFlashLoanProvider {
    function flashLoanSimple(
        address receiver,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

interface IFlashLoanSimpleReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

/**
 * @title ArbitrageExecutorV2
 * @dev Flash-loan based arbitrage executor with profit-gated fees and pause control
 */
contract ArbitrageExecutorV2 is IFlashLoanSimpleReceiver, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint16 public constant DEV_FEE_BPS = 1; // 0.01%
    uint16 public constant MAX_ADMIN_FEE_BPS = 2000; // 20%

    struct FlashArbParams {
        uint8 strategyId; // 0 = dexToDex, 1 = triangular
        address initiator; // recipient of net profit
        address tokenIn; // should equal the flash-loan asset
        address tokenOut;
        address intermediate; // used for triangular strategies
        address routerA;
        address routerB;
        uint256 minProfit; // in tokenIn terms
        uint256 amountOutMinLegA;
        uint256 amountOutMinLegB;
        uint256 amountOutMinLegC;
    }

    address public flashLoanProvider;
    address payable public admin;
    address payable public dev;
    uint16 public adminFeeBps;
    bool public paused;
    bool public devLocked;

    event ProfitDistributed(address indexed user, uint256 profit, uint256 devFee, uint256 adminFee, uint256 userAmount);
    event FlashLoanExecuted(address indexed asset, uint256 amount, uint256 premium, bool success);
    event ArbitrageExecuted(uint8 indexed strategyId, address indexed tokenIn, address indexed tokenOut, uint256 profit);
    event AdminUpdated(address indexed newAdmin, uint16 feeBps);
    event DevUpdated(address indexed newDev, bool locked);
    event PauseToggled(bool paused);
    event FlashLoanProviderSet(address indexed provider);

    constructor(address _provider, address payable _admin, address payable _dev) {
        require(_provider != address(0), "invalid provider");
        require(_admin != address(0), "invalid admin");
        require(_dev != address(0), "invalid dev");
        flashLoanProvider = _provider;
        admin = _admin;
        dev = _dev;
    }

    // --- Admin configuration ---
    function setFlashLoanProvider(address _provider) external onlyOwner {
        require(_provider != address(0), "invalid provider");
        flashLoanProvider = _provider;
        emit FlashLoanProviderSet(_provider);
    }

    function setAdmin(address payable _admin) external onlyOwner {
        require(_admin != address(0), "invalid admin");
        admin = _admin;
        emit AdminUpdated(_admin, adminFeeBps);
    }

    function setAdminFeeBps(uint16 newBps) external onlyOwner {
        require(newBps <= MAX_ADMIN_FEE_BPS, "fee too high");
        adminFeeBps = newBps;
        emit AdminUpdated(admin, newBps);
    }

    function setDev(address payable _dev) external onlyOwner {
        require(!devLocked, "dev locked");
        require(_dev != address(0), "invalid dev");
        dev = _dev;
        emit DevUpdated(_dev, devLocked);
    }

    function lockDevAddress() external onlyOwner {
        require(dev != address(0), "dev not set");
        devLocked = true;
        emit DevUpdated(dev, true);
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit PauseToggled(_paused);
    }

    // --- External entrypoint ---
    function executeFlashArb(
        address asset,
        uint256 amount,
        FlashArbParams calldata params
    ) external nonReentrant {
        require(!paused, "paused");
        require(asset != address(0), "invalid asset");
        require(amount > 0, "amount zero");
        require(flashLoanProvider != address(0), "provider missing");
        require(params.tokenIn == asset, "tokenIn mismatch");

        bytes memory data = abi.encode(params);
        IFlashLoanProvider(flashLoanProvider).flashLoanSimple(address(this), asset, amount, data, 0);
    }

    // --- Flash loan callback ---
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override nonReentrant returns (bool) {
        require(msg.sender == flashLoanProvider, "unauthorized caller");
        require(!paused, "paused");

        FlashArbParams memory p = abi.decode(params, (FlashArbParams));
        require(p.tokenIn == asset, "asset mismatch");
        if (p.initiator != address(0)) {
            require(p.initiator == initiator, "initiator mismatch");
        }

        uint256 balanceBefore = IERC20(asset).balanceOf(address(this));

        if (p.strategyId == 0) {
            _execDexToDex(asset, p.tokenOut, p.routerA, p.routerB, amount, p.amountOutMinLegA, p.amountOutMinLegB);
        } else if (p.strategyId == 1) {
            _execTriangular(
                asset,
                p.intermediate,
                p.tokenOut,
                p.routerA,
                p.routerB,
                amount,
                p.amountOutMinLegA,
                p.amountOutMinLegB,
                p.amountOutMinLegC
            );
        } else {
            revert("unsupported strategy");
        }

        uint256 balanceAfter = IERC20(asset).balanceOf(address(this));
        require(balanceAfter >= balanceBefore + premium, "insufficient to repay");

        uint256 profit = balanceAfter - balanceBefore - premium;
        require(profit >= p.minProfit && profit > 0, "no profit");

        // Prepare repayment
        uint256 repayment = amount + premium;
        IERC20(asset).safeApprove(flashLoanProvider, 0);
        IERC20(asset).safeApprove(flashLoanProvider, repayment);

        _distributeProfit(asset, p.initiator == address(0) ? owner() : p.initiator, profit);

        emit ArbitrageExecuted(p.strategyId, asset, p.tokenOut, profit);
        emit FlashLoanExecuted(asset, amount, premium, true);
        return true;
    }

    // --- Internal execution helpers ---
    function _execDexToDex(
        address tokenIn,
        address tokenOut,
        address routerA,
        address routerB,
        uint256 amountIn,
        uint256 minOutA,
        uint256 minOutB
    ) internal {
        require(routerA != address(0) && routerB != address(0), "router missing");
        require(tokenOut != address(0), "tokenOut missing");

        address[] memory path1 = new address[](2);
        path1[0] = tokenIn;
        path1[1] = tokenOut;
        uint256 out1 = _swap(routerA, amountIn, minOutA, path1);

        address[] memory path2 = new address[](2);
        path2[0] = tokenOut;
        path2[1] = tokenIn;
        _swap(routerB, out1, minOutB, path2);
    }

    function _execTriangular(
        address tokenIn,
        address mid,
        address tokenOut,
        address routerA,
        address routerB,
        uint256 amountIn,
        uint256 minOutA,
        uint256 minOutB,
        uint256 minOutC
    ) internal {
        require(routerA != address(0) && routerB != address(0), "router missing");
        require(mid != address(0) && tokenOut != address(0), "path missing");

        address[] memory path1 = new address[](2);
        path1[0] = tokenIn;
        path1[1] = mid;
        uint256 midOut = _swap(routerA, amountIn, minOutA, path1);

        address[] memory path2 = new address[](2);
        path2[0] = mid;
        path2[1] = tokenOut;
        uint256 outToken = _swap(routerB, midOut, minOutB, path2);

        address[] memory path3 = new address[](2);
        path3[0] = tokenOut;
        path3[1] = tokenIn;
        _swap(routerA, outToken, minOutC, path3);
    }

    function _swap(
        address router,
        uint256 amountIn,
        uint256 minOut,
        address[] memory path
    ) internal returns (uint256 out) {
        IERC20(path[0]).safeApprove(router, 0);
        IERC20(path[0]).safeApprove(router, amountIn);
        uint256[] memory amounts = IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            minOut,
            path,
            address(this),
            block.timestamp
        );
        out = amounts[amounts.length - 1];
    }

    // --- Profit distribution ---
    function _distributeProfit(address asset, address recipient, uint256 profit) internal {
        uint256 devFee = (profit * DEV_FEE_BPS) / 10000;
        uint256 adminFee = (profit * adminFeeBps) / 10000;
        uint256 userAmount = profit - devFee - adminFee;

        if (devFee > 0) {
            IERC20(asset).safeTransfer(dev, devFee);
        }
        if (adminFee > 0) {
            IERC20(asset).safeTransfer(admin, adminFee);
        }
        IERC20(asset).safeTransfer(recipient, userAmount);

        emit ProfitDistributed(recipient, profit, devFee, adminFee, userAmount);
    }

    // --- Safety tools ---
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            (bool ok, ) = msg.sender.call{value: amount}("");
            require(ok, "eth send failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    receive() external payable {}
}
