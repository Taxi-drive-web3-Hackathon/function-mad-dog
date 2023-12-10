// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Owned} from "../lib/solmate/src/auth/Owned.sol";
import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
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
    mapping(uint8 => address) public receivers;

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

        (uint8 id, uint8 receiverId, uint64 chainId, uint256 amount) = abi.decode(response,
            (uint8, uint8, uint64, uint256));

        address receiver = receivers[receiverId];
        IVault vaultContract = IVault(vaults[id].vault);
        ERC20 token = ERC20(vaults[id].token);

        require(vaults[id].active != true && address(vaults[id].vault) != address(0), "User not active");
        require(getBalance(id, vaults[id].token) > 0, "Insufficient balance");
        require(receiver != address(0), "Receiver not found");

        if (chainId == CCIP_CURRENT_CHAIN) {
            vaultContract.pay(vaults[id].token, amount, receiver);
            emit ExecuteTransfer(address(vaultContract), amount, receiver);
            return;
        }

        require(ICCIPAdapter(address(adapter)).allowlistedChains(chainId), "Destination chain is not allowlisted");
        vaultContract.pay(address(token), amount, address(this));
        token.approve(address(adapter), amount);
        bytes32 ccipRequest = ICCIPAdapter(address(adapter)).send(address(token), amount, receiver, chainId);

        emit ExecuteCCIP(ccipRequest, address(vaultContract), amount, receiver);
    }
}