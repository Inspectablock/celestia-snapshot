// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Polling.sol";

contract PollingTest is Test {
    Polling polling;

    function setUp() public {
        polling = new Polling();
    }

    function testCreatePoll() public {
        polling.createPoll("My first poll", "12345", 1682452938, 1682452938);
        Polling.Poll[] memory posts = polling.fetchPolls();
        assertEq(posts.length, 1);
    }

    function testUpdatePoll() public {
        polling.createPoll("My first post", "12345", 1682452938, 1682452938);
        polling.updatePoll(1, "My second post", "12345", true);
        Polling.Poll memory updatedPoll = polling.fetchPoll("12345");
        assertEq(updatedPoll.title, "My second post");
    }

    function testFetchPolls() public {
        Polling.Poll[] memory posts = polling.fetchPolls();
        assertEq(posts.length, 0);
        polling.createPoll("My first post", "12345", 1682452938, 1682452938);
        posts = polling.fetchPolls();
        assertEq(posts.length, 1);
    }

    function testOnlyOwner() public {
        polling.createPoll("My first post", "12345", 1682452938, 1682452938);
        address bob = address(0x1);
        vm.startPrank(bob);
        vm.expectRevert();
        polling.updatePoll(1, "My second post", "12345", true);
    }
}