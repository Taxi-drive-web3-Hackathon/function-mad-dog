// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PinGo.sol";
import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
import {ApiConsumer} from "../src/APIConsumer.sol";
import {Vault} from "../src/Vault.sol";
import {CCIPAdapter} from "../src/CCIPAdapter.sol";

contract PinGoScript is Script {

    address token = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
		address router = 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

				CCIPAdapter adapter = new CCIPAdapter();
        PinGo pin = new PinGo(address(adapter));
				Vault vault = new Vault();

				vault.initialize(address(pin));
				ERC20(token).approve(address(vault), 4000000000000000000);
				vault.deposit(token, 4000000000000000000);

				adapter.initialize(token, address(pin), router);

				adapter.allowlistDestinationChain(12532609583862916517, true);
				adapter.allowlistDestinationChain(14767482510784806043, true);

				ERC20(token).approve(address(adapter), 4000000000000000000);
				ERC20(token).transfer(address(adapter), 4000000000000000000);

				ApiConsumer consumer = new ApiConsumer(router);
				consumer.setPing(address(pin));

        pin.addReceiver(1, 0x6aC4DB972e2c94343b7Dc14c1AEaCc2cC1a3e05d);
        pin.addReceiver(2, 0x66cDc21b5db131E3f8E8af0CDB4E455a8393604a);

        pin.addVault(1, token, address(vault));

        vm.stopBroadcast();
    }
}
