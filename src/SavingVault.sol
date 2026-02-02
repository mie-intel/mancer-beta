// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract SavingVault {
    uint256 public balance;
    address public owner;
    uint256 public currentUnlockTime;

    event Deposit(address sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);

    error NotOwner(address sender);
    error FundsLocked();
    error WithdrawalFailed();
    error InvalidUnlockTime(uint256 unlockTime);

    constructor(uint256 unlockTime) {
        if (unlockTime < block.timestamp) {
            revert InvalidUnlockTime(unlockTime);
        }
        owner = msg.sender;
        currentUnlockTime = unlockTime;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }
        _;
    }

    function extendLock(uint256 newTime) public onlyOwner {
        if (newTime < currentUnlockTime) {
            revert InvalidUnlockTime(newTime);
        } else {
            currentUnlockTime = newTime;
        }
    }

    function deposit() public payable {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        if (block.timestamp <= currentUnlockTime) {
            revert FundsLocked();
        }
        (bool success,) = payable(owner).call{value: balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        emit Withdrawal(balance, block.timestamp);
        balance = 0;
    }
}
