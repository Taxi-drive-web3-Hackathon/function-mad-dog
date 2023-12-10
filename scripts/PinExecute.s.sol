// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {PinGo} from '../src/PinGo.sol';

contract Execute is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        bytes32 requestId = vm.envBytes32("REQUEST_ID");
        bytes memory response = vm.envBytes("RESPONSE");
        bytes memory err = vm.envBytes("ERR");

        PinGo ping = PinGo(0x822f37e7092F019de0C1BB9c427D9E9Ad9Ce8E0f);
        ping.execute(requestId, response, err);

        vm.stopBroadcast();
    }
}