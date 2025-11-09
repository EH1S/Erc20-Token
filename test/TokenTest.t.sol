// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {DeployToken} from "../script/DeployToken.s.sol";

contract TokenTest is Test {
    Token public token;
    DeployToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");
    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployToken();
        token = deployer.run();

        vm.prank(msg.sender);
        token.transfer(bob, STARTING_BALANCE);
    }

    //test
    function testBobBalance() public {
        vm.prank(bob);
        assertEq(STARTING_BALANCE, token.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend on his behalf
        vm.prank(bob);
        token.approve(alice, initialAllowance);
        uint256 transferamount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferamount);
        assertEq(token.balanceOf(alice), transferamount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferamount);
    }

    function testTransferRevertsIfInsufficientBalance() public {
        uint256 amount = 1 ether;

        vm.prank(alice); // Alice has 0 tokens initially
        vm.expectRevert();
        token.transfer(bob, amount);
    }

    function testApproveAndTransferFrom() public {
        uint256 allowanceAmount = 50 ether;
        uint256 transferAmount = 20 ether;

        vm.prank(bob);
        token.approve(alice, allowanceAmount);

        vm.prank(alice);
        token.transferFrom(bob, carol, transferAmount);

        assertEq(token.balanceOf(carol), transferAmount);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(token.allowance(bob, alice), allowanceAmount - transferAmount);
    }

    /// @notice Reverts if spender tries transferFrom without approval
    function testTransferFromRevertsIfNotApproved() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transferFrom(bob, alice, 10 ether);
    }

    /// @notice Allowance should update correctly after approval
    function testAllowanceUpdatesCorrectly() public {
        uint256 approvalAmount = 30 ether;

        vm.prank(bob);
        token.approve(alice, approvalAmount);

        assertEq(token.allowance(bob, alice), approvalAmount);
    }
}
