// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IPinGo {
    function execute(bytes32 requestId, bytes memory response, bytes memory err) external;
}
