## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

1 Relative Stability :Anchored or Pegged -> 1$
    1. Chainlink Price feed
    2. Set a function to exchange ETH&BTC ->$$$
2 Stability Mechanissm(Minting): Algorithmic (Decentralized) 1. People can only Mint the stabecoin with enough collateral(coded)
3 Collateral: Exogenous(Crypto)
1 ETH
2 BTC

- calculate health factor function
- set health factor if debt is 0
- Added a bunch of view function

1.  What are our invariants/properties?

1.  some proper oracle use
1.  Wwrite more tests
1.  Smart Contract Audit Preparation
