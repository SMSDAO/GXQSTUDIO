// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISwapRouter.sol";

/**
 * @title LeverageSwap
 * @dev Contract for executing leveraged swaps on DEXs
 */
contract LeverageSwap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    // Events
    event SwapExecuted(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event TokensRescued(address indexed token, uint256 amount);
    
    // Uniswap router interface
    ISwapRouter public swapRouter;
    
    // Fee configuration
    uint24 public constant poolFee = 3000; // 0.3%
    
    constructor() {}
    
    /**
     * @dev Sets the swap router address
     * @param _swapRouter Swap router address
     */
    function setSwapRouter(address _swapRouter) external onlyOwner {
        require(_swapRouter != address(0), "Invalid router address");
        swapRouter = ISwapRouter(_swapRouter);
    }
    
    /**
     * @dev Execute a leveraged swap
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Amount of input token
     * @param amountOutMinimum Minimum amount of output token
     * @param deadline Transaction deadline
     */
    function executeSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint256 deadline
    ) external onlyOwner nonReentrant returns (uint256 amountOut) {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token addresses");
        require(amountIn > 0, "Amount must be greater than 0");
        
        // Transfer tokens from sender to this contract
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        
        // Approve the router to spend the token
        IERC20(tokenIn).safeApprove(address(swapRouter), amountIn);
        
        // Execute the swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: poolFee,
            recipient: msg.sender,
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });
        
        amountOut = swapRouter.exactInputSingle(params);
        
        emit SwapExecuted(tokenIn, tokenOut, amountIn, amountOut);
        
        return amountOut;
    }
    
    /**
     * @dev Execute a multi-hop swap
     * @param path Encoded swap path
     * @param amountIn Amount of input token
     * @param amountOutMinimum Minimum amount of output token
     * @param deadline Transaction deadline
     */
    function executeMultiHopSwap(
        bytes memory path,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint256 deadline
    ) external onlyOwner nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        
        // Extract tokenIn from the path
        address tokenIn;
        assembly {
            tokenIn := mload(add(path, 20))
        }
        
        // Transfer tokens from sender to this contract
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        
        // Approve the router to spend the token
        IERC20(tokenIn).safeApprove(address(swapRouter), amountIn);
        
        // Execute the multi-hop swap
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: msg.sender,
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum
        });
        
        amountOut = swapRouter.exactInput(params);
        
        emit SwapExecuted(tokenIn, address(0), amountIn, amountOut);
        
        return amountOut;
    }
    
    /**
     * @dev Rescue tokens accidentally sent to the contract
     * @param token Token address (use address(0) for ETH)
     * @param amount Amount to rescue
     */
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            // Rescue ETH
            require(amount <= address(this).balance, "Insufficient ETH balance");
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Rescue ERC20 tokens
            uint256 balance = IERC20(token).balanceOf(address(this));
            require(amount <= balance, "Insufficient token balance");
            IERC20(token).safeTransfer(msg.sender, amount);
        }
        
        emit TokensRescued(token, amount);
    }
    
    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}
}