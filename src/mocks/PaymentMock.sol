/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "../../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IVault} from "../interfaces/IVault.sol";
import {ICCIPAdapter} from "../interfaces/ICCIPAdapter.sol";

contract PaymentMock is Ownable, Pausable, ReentrancyGuard {
    IVault public vault;
    ICCIPAdapter public adapter;

    /// Mumbai testnet chain selector
    uint64 public constant CURRENT_CHAIN = 12532609583862916517;

    constructor (address _vaultAddress, address _adapter) Ownable(msg.sender) {
        vault = IVault(_vaultAddress);
        adapter = ICCIPAdapter(_adapter);
    }

    function simulatePay(
        address _token, 
        address _to, 
        uint256 _amount, 
        uint64 _destinationChainSelector
    ) public whenNotPaused nonReentrant {
        require(_token != address(0), "PaymentMock: token address cannot be zero");
        require(_to != address(0), "PaymentMock: _to address cannot be zero");
        require(_amount > 0, "PaymentMock: _amount must be greater than zero");
        require(IERC20(_token).balanceOf(address(vault)) >= _amount, "PaymentMock: vault balance must be greater than or equal to _amount");

        // If the destination chain is the current chain, pay directly to the receiver
        if (_destinationChainSelector == CURRENT_CHAIN) {
            vault.pay(_token, _amount, _to);
            return;
        }

        // If the destination chain is not allowlisted, revert
        require(adapter.allowlistedChains(_destinationChainSelector), "PaymentMock: destination chain is not allowlisted");

        // Execute Vault pay to receive the tokens
        vault.pay(_token,_amount, address(this));

        // Approve the CCIP adapter to spend the tokens and send request to the adapter
        IERC20(_token).approve(address(adapter), _amount);
        CCIPAdapter(address(adapter)).send(_token, _amount, _to, _destinationChainSelector);
    }
}