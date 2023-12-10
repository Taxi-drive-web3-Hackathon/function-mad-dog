# Pingo Smart Contracts

NOTE: This is a work in progress.

## Overview

Pingo is a Protocol that allows clients recieve and execute seamless payments using API integrations (provided by [Chainlink Functions](https://docs.chain.link/chainlink-functions)) and bridges (provided by [Chainlink CCIP](https://dev.chain.link/products/ccip)).

## Table of Contents

- [Getting Started](#getting-started)
- [Smart Contracts](#smart-contracts)
- [Contributing](#contributing)
- [License](#license)
- ...

## Chains and Addresses

### Mumbai

#### Pingo Contracts

- [Pingo](https://mumbai.polygonscan.com/address/0x185e6B5505c313c166c6E28154090F8cb3ba02C9):`0x185e6B5505c313c166c6E28154090F8cb3ba02C9`;
- [APIConsumer](https://mumabi.polygonscan.com/address/0xd6a241Fa0055E68E15d68848CAE3717D9e0A498C):`0xd6a241Fa0055E68E15d68848CAE3717D9e0A498C`;
- [CCIPAdapter](https://mumbai.polygonscan.com/address/0xE85d9213C30e2162d339b23BE5744279bcB4B7F8): `0xE85d9213C30e2162d339b23BE5744279bcB4B7F8`;

#### Chainlink Contracts

- [Functions]():
- [CCIP Router]():

## Getting Started

To get started with Pingo, follow these steps:

If you haven't already, [install Node.js](https://nodejs.org/).
If you haven't already, [install Foundry](https://book.getfoundry.sh/).

After start, ensure you have Foundry installed:

```bash
$ forge --version
```

1. Clone the repository: `git clone https://github.com/your-username/defi-protocol.git`
2. Install dependencies: `npm install`
3. Compile contracts: `forge compile`
4. Run tests: `forge test`
5. Deploy contracts: ``. 

To deploy to a specific network, use `npm run deploy -- --network <network-name>`. 
For example, to deploy to the Mumbai testnet, use `npm run deploy -- --network mumbai`.

## Smart Contracts

The Pingo protocol is made up of several smart contracts. The following is a brief description of each contract:

- [Pingo](./src/Pingo.sol): The Core contract of Pingo protocol. It is used to execute the requests and validate sender and reciever.
- [APIConsumer](./src/APIConsumer.sol): Tha APIConsumer contract is used to recieve requets of Chainlink Functions and call Pingo to execute the requets.
- [CCIPAdapter](./src/CCIPAdapter.sol): The CCIPAdapter contract is used to send requests to Chainlink CCIP router.
- [Vault](./src/Vault.sol): The Vault contract is used to store the assets of users and Pingo and execute the expend of reserves when recieving requests.

## Contributing

We welcome improvements and contributions from the community! 

Lets fork the repo and make a PR!

## License

MIT License.