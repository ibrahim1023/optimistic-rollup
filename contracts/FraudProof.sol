// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OptimisticRollup.sol";

library MerkleProof {
    // Verifies a Merkle proof
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = (computedHash < proof[i])
                ? keccak256(abi.encodePacked(computedHash, proof[i]))
                : keccak256(abi.encodePacked(proof[i], computedHash));
        }

        return computedHash == root;
    }
}

contract FraudProof {
    OptimisticRollup public rollup;

    event FraudChallenge(bytes32, address);

    // Constructor
    constructor(OptimisticRollup _rollup) {
        rollup = _rollup;
    }

    // Function to submit a fraud proof
    function submitFraudProof(
        bytes32 challengedStateRoot,
        bytes32 leaf,
        bytes32[] calldata proof // Merkle proof
    ) external {
        // Check if the challenged state root is indeed the latest state root
        require(
            challengedStateRoot != rollup.latestStateRoot(),
            "Cannot challenge latest state root"
        );

        // Validate the Merkle proof against the challenged state root
        require(
            MerkleProof.verify(proof, challengedStateRoot, leaf),
            "Invalid proof"
        );

        // If proof is valid, take necessary actions (e.g., revert state)
        emit FraudChallenge(challengedStateRoot, msg.sender);
    }
}
