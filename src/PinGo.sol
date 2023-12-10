// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Owned} from "./auth/Owned.sol";

contract PinGo is Owned {

    struct UserData {
        address account;
        uint256 balance;
        bool active;
    }

    mapping(uint8 => UserData) public users;
    mapping(bytes32 => bool) public requests;

    constructor(address _vault) Owned(_vault) {}

    function addUser(uint8 id, address account) public onlyOwner {
        users[id] = UserData(account, 0, true);
    }

    function removeUser(uint8 id) public onlyOwner {
        delete users[id];
    }

    function setBalance(uint8 id, uint256 balance) public onlyOwner {
        users[id].balance = balance;
    }

    function setOwner(address newOwner) public override onlyOwner {
        super.setOwner(newOwner);
    }

    // TODO
    function pay(
        bytes32 requestId,
		bytes memory response,
		bytes memory err
    ) public {
        require(requests[requestId] == false, "Request already processed");
        requests[requestId] = true;

        // TODO
    }
}