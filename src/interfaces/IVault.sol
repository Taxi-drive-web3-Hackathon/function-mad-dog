// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IVault {
  function deposit(address _token, uint256 _amount) external;
  function pay(address _token, uint256 _amount, address _to) external;
  function withdraw(address _token, uint256 _amount) external;
  function getBalance(address _token) external view returns (uint256);
}