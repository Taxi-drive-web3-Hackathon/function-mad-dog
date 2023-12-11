// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PinGo} from "../src/PinGo.sol";
import {ApiConsumer} from "../src/APIConsumer.sol";

contract Execute is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        PinGo(address(0x11b30ABc5E04Dd1Fac8D726c6EDBd58F428195E4)).execute();

        vm.stopBroadcast();
    }
}