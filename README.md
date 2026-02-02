# SavingVault

**SavingVault is a secure, time-locked savings contract built on Ethereum.** It allows users to deposit funds that are locked until a specified release time, ensuring disciplined saving.

## Overview

The `SavingVault` smart contract is designed to hold Ether and prevent withdrawal until a pre-determined timestamp. 
- **Owner**: The deployer of the contract is the owner.
- **Locking**: Funds are locked until `currentUnlockTime`.
- **Deposits**: Anyone can deposit Ether into the vault at any time.
- **Withdrawals**: Only the owner can withdraw, and only after the unlock time has passed.
- **Extensions**: The owner can extend the lock period, but cannot shorten it.

## Contract Details

### State Variables

- **`owner`** (`address`): The address of the vault owner.
- **`currentUnlockTime`** (`uint256`): The Unix timestamp indicating when funds can be withdrawn.

### Events

- **`Deposit(address sender, uint256 amount)`**: Emitted when Ether is deposited into the vault.
- **`Withdrawal(uint256 amount, uint256 timestamp)`**: Emitted when the owner withdraws funds.

### Custom Errors

- **`NotOwner(address sender)`**: Reverted when a non-owner attempts an owner-only action.
- **`FundsLocked()`**: Reverted when a withdrawal is attempted before the unlock time.
- **`WithdrawalFailed()`**: Reverted if the Ether transfer to the owner fails.
- **`InvalidUnlockTime(uint256 unlockTime)`**: Reverted when setting an invalid unlock time (e.g., in the past).

### Functions

#### `constructor(uint256 unlockTime)`
Initializes the contract, setting the `owner` to the deployer and the `currentUnlockTime`.
- **Reverts**: `InvalidUnlockTime` if `unlockTime` is in the past.

#### `deposit()`
Allows anyone to deposit Ether into the contract.
- **Access**: Public
- **Emits**: `Deposit`

#### `extendLock(uint256 newTime)`
Extends the lock period.
- **Access**: `onlyOwner`
- **Reverts**: `InvalidUnlockTime` if `newTime` is explicitly not greater than the current lock time.
- **Note**: The lock time can only be increased, never decreased.

#### `withdraw()`
Withdraws the entire balance to the owner's address.
- **Access**: `onlyOwner`
- **Modifiers**: `nonReentrant`
- **Reverts**: `FundsLocked` if called before `currentUnlockTime`. `WithdrawalFailed` if transfer fails.
- **Emits**: `Withdrawal`

## Development

This project represents a Foundry project.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
$ forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/SavingVault.sol:SavingVault --constructor-args <unlock_time>
```
