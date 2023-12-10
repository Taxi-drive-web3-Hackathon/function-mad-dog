// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Owned} from "solmate/src/auth/Owned.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {ICCIPAdapter} from "./interfaces/ICCIPAdapter.sol";
import {IVault} from "./interfaces/IVault.sol";

contract PinGo is Owned {
    struct VaultData {
        bool active;
        address token;
        address vault;
    }

    uint64 public constant CCIP_CURRENT_CHAIN = 12532609583862916517;
    ICCIPAdapter public adapter;
    mapping(uint8 => VaultData) public vaults;
    mapping(bytes32 => bool) public requests;
    mapping(uint8 => uint256) public receivers;

    event ExecuteTransfer(address indexed vault, uint256 amount, address receiver);
    event ExecuteCCIP(bytes32 requestId, address indexed vault, uint256 amount, address receiver);

    constructor(address _adapter) Owned(msg.sender) {
        adapter = ICCIPAdapter(_adapter);
    }

    function addReceiver(uint8 id, address receiver) public onlyOwner {
        receivers[id] = receiver;
    }

    function removeReceiver(uint8 id) public onlyOwner {
        delete receivers[id];
    }

    function addVault(uint8 id, address token, address vault) public onlyOwner {
        vaults[id] = VaultData(true, token, vault);
    }

    function removeVault(uint8 id) public onlyOwner {
        delete vaults[id];
    }

    function getBalance(uint8 id, address token) public view returns (uint256) {
        return ERC20(token).balanceOf(vaults[id].vault);
    }

    function execute(
        bytes32 requestId,
		bytes memory response,
		bytes memory err
    ) public {
        require(requests[requestId] == false, "Request already processed");
        requests[requestId] = true;

        (uint8 id, uint8 receiver, uint64 chainId, uint256 amount) = abi.decode(response, (uint8, uint8, uint64, uint256));
        require(vaults[id].active != true && address(vaults[id].vault) != address(0), "User not active");
        require(getBalance(id, vaults[id].token) > 0, "Insufficient balance");
        require(receivers[receiver] != address(0), "Receiver not found");

        IVault vault = IVault(vaults[id].vault);
        if (chainId == CCIP_CURRENT_CHAIN) {
            vault.pay(vaults[id].token, amount, receivers[receiver]);
            emit ExecuteTransfer(vaults[id].vault, amount, receivers[receiver]);
            return;
        }

        require(adapter.allowlistedChains(chainId), "Destination chain is not allowlisted");
        vault.pay(_token,_amount, address(this));
        IERC20(_token).approve(address(adapter), _amount);
        bytest32 ccipRequest = CCIPAdapter(address(adapter)).send(_token, _amount, _to, _destinationChainSelector);

        emit ExecuteCCIP(ccipRequest, vaults[id].vault, amount, receivers[receiver]);
    }
}