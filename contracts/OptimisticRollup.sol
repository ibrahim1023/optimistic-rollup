// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OptimisticRollup {
    // State variables
    mapping(address => uint256) public balances;
    bytes32 public latestStateRoot;
    bytes32[] public previousStateRoots;
    IERC20 public token; // ERC20 token for deposits/withdrawals

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event StateUpdated(bytes32 newStateRoot);
    event FraudChallenge(bytes32 challengedStateRoot, address challenger);

    // Constructor
    constructor(IERC20 _token) {
        token = _token;
    }

    // Deposit funds into the rollup
    function deposit(uint256 amount) external {
        require(amount > 0, "Must deposit a positive amount");
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    // Withdraw funds from the rollup
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    // Update the state root (called by an off-chain service)
    function updateState(bytes32 newStateRoot) external {
        // Validate new state root
        require(newStateRoot != latestStateRoot, "State root must change");

        // Store previous state root
        previousStateRoots.push(latestStateRoot);
        latestStateRoot = newStateRoot;

        emit StateUpdated(newStateRoot);
    }

    // Function to challenge the latest state root
    function challengeState(bytes32 challengedStateRoot) external {
        require(
            challengedStateRoot != latestStateRoot,
            "Cannot challenge latest state root"
        );

        // Check if the challenged state root exists in previous roots
        bool found = false;
        for (uint256 i = 0; i < previousStateRoots.length; i++) {
            if (previousStateRoots[i] == challengedStateRoot) {
                found = true;
                break; // Exit the loop once the state root is found
            }
        }

        // If the challenged root is not found in previousStateRoots, revert
        require(found, "Challenged state root does not exist");

        // If the root is found, emit the fraud challenge event
        emit FraudChallenge(challengedStateRoot, msg.sender);
    }
}
