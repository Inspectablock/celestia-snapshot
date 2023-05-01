// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {Polling} from "src/Polling.sol";

contract PollingScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Polling();
        vm.stopBroadcast();
    }
}