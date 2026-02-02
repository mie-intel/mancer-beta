// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SavingVault} from "../src/SavingVault.sol";

contract SavingVaultTest is Test {
    SavingVault public savingVault;
    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        savingVault = new SavingVault(block.timestamp + 5 minutes);
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);
    }

    function test_Deposit() public {
        vm.startPrank(owner);
        savingVault.deposit{value: 1 ether}();
        assertEq(address(savingVault).balance, 1 ether);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        vm.startPrank(owner);
        savingVault.deposit{value: 1 ether}();
        vm.warp(block.timestamp + 6 minutes);
        savingVault.withdraw();
        assertEq(address(savingVault).balance, 0);
        vm.stopPrank();
    }

    function test_WithdrawFailed() public {
        vm.startPrank(owner);
        savingVault.deposit{value: 1 ether}();
        vm.warp(block.timestamp + 4 minutes);
        vm.expectRevert(SavingVault.FundsLocked.selector);
        savingVault.withdraw();
        assertEq(address(savingVault).balance, 1 ether);
        vm.stopPrank();
    }

    function test_ExtendLock() public {
        vm.startPrank(owner);
        vm.warp(block.timestamp + 4 minutes);
        savingVault.extendLock(block.timestamp + 5 minutes);
        assertEq(savingVault.currentUnlockTime(), block.timestamp + 5 minutes);
        vm.stopPrank();
    }

    function test_ExtendLockFailed() public {
        vm.startPrank(user);
        vm.warp(block.timestamp + 4 minutes);
        vm.expectRevert(abi.encodeWithSelector(SavingVault.NotOwner.selector, user));
        savingVault.extendLock(block.timestamp + 5 minutes);
        vm.stopPrank();
    }

    function test_ExtendLockFailed2() public {
        uint256 currentTime = block.timestamp;
        vm.startPrank(owner);
        vm.warp(currentTime + 4 minutes);
        vm.expectRevert(abi.encodeWithSelector(SavingVault.InvalidUnlockTime.selector, currentTime + 3 minutes));
        savingVault.extendLock(currentTime + 3 minutes);
        vm.stopPrank();
    }
}
