// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPingGo {
    function pay(bytes32 requestId, bytes memory response, bytes memory err) external;
}
