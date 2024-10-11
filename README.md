# Optimistic Rollup with Fraud Proof in Solidity

This project implements a simplified version of an Optimistic Rollup system using Solidity smart contracts. The rollup includes basic functionality such as depositing, withdrawing, and state root updates, along with a fraud-proof mechanism that allows users to challenge invalid state roots.

## Overview 

An Optimistic Rollup is a scaling solution for blockchains that processes transactions off-chain and submits periodic state roots on-chain. This reduces the number of on-chain transactions while ensuring security through fraud proofs.

In this implementation, users can:

1. Deposit ERC20 tokens into the rollup.
2. Withdraw their tokens.
3. Challenge fraudulent state roots using a fraud-proof mechanism.
4. Use the challenge window to ensure the integrity of the off-chain state roots.

## Features

- **Deposits and Withdrawals**: Users can deposit ERC20 tokens into the rollup and later withdraw them.
- **State Root Updates**: The rollup's off-chain service can submit new state roots periodically.
- **Fraud Proofs**: Users can challenge old state roots they believe to be invalid.
- **Challenge Period**: A challenge window is enforced to allow fraud challenges before finalizing the state root.

## Contracts Overview

- **OptimisticRollup contract**: The core contract responsible for managing deposits, withdrawals, and state root updates. It stores previous state roots and allows users to challenge old state roots using the fraud-proof mechanism.
- **FraudProof contract**: A contract that facilitates fraud-proof submission, enabling users to prove that a previous state root is invalid.
- **Token.sol**: A simple ERC20 token used for interacting with the Optimistic Rollup. Users deposit and withdraw this token from the rollup.

## Usage

### Compile the contracts
```
npx hardhat compile
```

### Run the tests
```
npx hardhat test
```

## Tests 

```
 Optimistic Rollup Contract
    ✔ Should allow deposits
    ✔ Should allow withdrawals
    ✔ Should allow a valid state challenge and prevent invalid challenges
    ✔ Should reject invalid claim
```
