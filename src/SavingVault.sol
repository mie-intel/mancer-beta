// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/// @title SavingVault
/// @author [Your Name/Project]
/// @notice A simple vault contract that locks funds until a specified time
/// @dev Implements ReentrancyGuard for security
contract SavingVault is ReentrancyGuard {
    /// @notice The address of the vault owner
    address public owner;

    /// @notice The timestamp when the funds will be unlocked
    uint256 public currentUnlockTime;

    /// @notice Emitted when funds are deposited
    /// @param sender The address of the depositor
    /// @param amount The amount of ether deposited
    event Deposit(address sender, uint256 amount);

    /// @notice Emitted when funds are withdrawn
    /// @param amount The amount of ether withdrawn
    /// @param timestamp The block timestamp of the withdrawal
    event Withdrawal(uint256 amount, uint256 timestamp);

    /// @notice Error thrown when a non-owner attempts a restricted action
    /// @param sender The address of the caller
    error NotOwner(address sender);

    /// @notice Error thrown when withdrawal is attempted before unlock time
    error FundsLocked();

    /// @notice Error thrown when the ether transfer fails
    error WithdrawalFailed();

    /// @notice Error thrown when an invalid unlock time is provided
    /// @param unlockTime The invalid timestamp provided
    error InvalidUnlockTime(uint256 unlockTime);

    /// @notice Initializes the vault with a lock time
    /// @param unlockTime The timestamp until which funds are locked
    constructor(uint256 unlockTime) {
        if (unlockTime < block.timestamp) {
            revert InvalidUnlockTime(unlockTime);
        }
        owner = msg.sender;
        currentUnlockTime = unlockTime;
    }

    /// @notice Restricts access to the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }
        _;
    }

    /// @notice Extends the lock time
    /// @dev Can only be called by the owner. New time must be in the future relative to current lock.
    /// @param newTime The new unlock timestamp
    function extendLock(uint256 newTime) public onlyOwner {
        if (newTime <= currentUnlockTime) {
            revert InvalidUnlockTime(newTime);
        } else {
            currentUnlockTime = newTime;
        }
    }

    /// @notice Deposits ether into the vault
    /// @dev Public function, anyone can deposit
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraws all ether from the vault to the owner
    /// @dev Can only be called by the owner after the unlock time passed. Protected against reentrancy.
    function withdraw() public onlyOwner nonReentrant {
        if (block.timestamp <= currentUnlockTime) {
            revert FundsLocked();
        }
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        emit Withdrawal(address(this).balance, block.timestamp);
    }
}
