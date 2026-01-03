// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Balancer Vault interface
interface IBalancerVault {
    function flashLoan(
        address recipient,
        address[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

/**
 * @title FlashLoanExecutor
 * @dev Contract for executing flash loans from Balancer
 */
contract FlashLoanExecutor is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    // Events
    event FlashLoanExecuted(address[] tokens, uint256[] amounts);
    event TokensRescued(address indexed token, uint256 amount);
    
    // Balancer Vault address
    address public immutable balancerVault;
    
    constructor(address _balancerVault) {
        require(_balancerVault != address(0), "Invalid Balancer Vault address");
        balancerVault = _balancerVault;
    }
    
    /**
     * @dev Execute a flash loan
     * @param tokens Array of token addresses
     * @param amounts Array of amounts to borrow
     * @param userData Additional data for the flash loan
     */
    function executeFlashLoan(
        address[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata userData
    ) external onlyOwner nonReentrant {
        require(tokens.length == amounts.length, "Array length mismatch");
        
        IBalancerVault(balancerVault).flashLoan(
            address(this),
            tokens,
            amounts,
            userData
        );
        
        emit FlashLoanExecuted(tokens, amounts);
    }
    
    /**
     * @dev Callback function for Balancer flash loans
     * This function is called by the Balancer Vault after the flash loan is executed
     */
    function receiveFlashLoan(
        address[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external {
        require(msg.sender == balancerVault, "Only Balancer Vault can call");
        
        // Execute arbitrage or other logic here using the flash loaned tokens
        // This would typically involve swapping tokens on DEXs
        
        // Repay the flash loan with fees
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(balancerVault, amounts[i] + feeAmounts[i]);
        }
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