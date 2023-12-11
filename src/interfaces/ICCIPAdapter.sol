// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface ICCIPAdapter {
  function send(
      address _token, 
      uint256 _amount, 
      address _to, 
      uint64 _destinationChainSelector
  ) external returns (bytes32);
  function getLinkBalance() external view returns (uint256);
  function allowlistedChains(uint64 _chainId) external view returns (bool);
}