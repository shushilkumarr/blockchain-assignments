// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {InfinityStones} from "../src/InfinityStones.sol";

contract DeployInfinityStones is Script {
    function run() external returns (InfinityStones token) {

        vm.startBroadcast();

        token = new InfinityStones();

        token.transferOwnership(msg.sender);

        vm.stopBroadcast();

        return token;
    }
}