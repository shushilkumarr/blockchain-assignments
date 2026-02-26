// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {InfinityStones} from "../src/InfinityStones.sol";

contract InfinityStonesTest is Test {
    InfinityStones token;

    address deployer = address(this);
    address saumay = address(1);
    address abhiroop = address(2);
    address pritish = address(3);

    function setUp() public {
        token = new InfinityStones();
    }

    function testOwnerHasFullSupply() public {
        // Owner should have all 5 tokens (max supply)
        assertEq(token.balanceOf(deployer), 5 ether);
        assertEq(token.totalSupply(), 5 ether);
    }

    function testCannotTransferToNonFriend() public {
        vm.expectRevert(bytes("Receiver is not your friend"));
        token.transfer(saumay, 1 ether);
    }

    function testCanTransferToFriend() public {
        token.addFriend(saumay);
        token.transfer(saumay, 1 ether);

        assertEq(token.balanceOf(saumay), 1 ether);
        assertEq(token.balanceOf(deployer), 4 ether);
    }

    function testRemoveFriendPreventsTransferAndRevokesAllowance() public {

        token.addFriend(abhiroop);
        token.transfer(abhiroop, 1 ether);

        token.approve(abhiroop, 2 ether);
        assertEq(token.allowance(deployer, abhiroop), 2 ether);

        token.removeFriend(abhiroop);

        vm.expectRevert(bytes("Receiver is not your friend"));
        token.transfer(abhiroop, 1 ether);

        assertEq(token.allowance(deployer, abhiroop), 0);

        vm.expectRevert(bytes("Spender is not your friend"));
        token.approve(abhiroop, 1 ether);
    }

    function testIsFriendViewFunction() public {
        token.addFriend(pritish);
        assertTrue(token.isFriend(deployer, pritish));

        token.removeFriend(pritish);
        assertFalse(token.isFriend(deployer, pritish));
    }

    function testCannotApproveNonFriend() public {
        vm.expectRevert(bytes("Spender is not your friend"));
        token.approve(abhiroop, 1 ether);
    }

    function testCanApproveFriendAndTransferFrom() public {
        token.addFriend(saumay);

        // Approve saumay
        token.approve(saumay, 1 ether);
        assertEq(token.allowance(deployer, saumay), 1 ether);

        // saumay transfers from deployer to themselves
        vm.prank(saumay);
        token.transferFrom(deployer, saumay, 1 ether);

        assertEq(token.balanceOf(saumay), 1 ether);
        assertEq(token.balanceOf(deployer), 4 ether);
        assertEq(token.allowance(deployer, saumay), 0);
    }

    function testTransferFromRevertsToNonFriend() public {
        // Approve pritish without friendship
        vm.expectRevert(bytes("Spender is not your friend"));
        token.approve(pritish, 1 ether);
    }

    function testBurnTokens() public {
        token.burn(2 ether);
        assertEq(token.balanceOf(deployer), 3 ether);
        assertEq(token.totalSupply(), 3 ether);
    }

    function testPausePreventsTransfer() public {
        token.addFriend(saumay);
        token.pause();

        vm.expectRevert();
        token.transfer(saumay, 1 ether);
    }

    function testUnpauseAllowsTransfer() public {
        token.addFriend(saumay);
        token.pause();
        token.unpause();

        token.transfer(saumay, 1 ether);
        assertEq(token.balanceOf(saumay), 1 ether);
    }
}
