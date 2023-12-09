// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPingGo {
    function addUser(uint8 id, address account) external;
    function removeUser(uint8 id) external;
    function setBalance(uint8 id, uint256 balance) external;
    function go(bytes32 requestId, bytes memory response, bytes memory err) external;
}
