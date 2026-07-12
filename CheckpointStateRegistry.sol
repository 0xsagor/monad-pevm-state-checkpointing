// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CheckpointStateRegistry
 * @dev On-chain tracking grid validating the integrity of off-chain node snapshot roots.
 */
contract CheckpointStateRegistry is Ownable {

    struct RootCheckpoint {
        bytes32 stateRootHash;
        uint256 confirmedBlockNumber;
        bool isValidated;
    }

    mapping(uint256 => RootCheckpoint) public globalCheckpointLogs;
    address public networkInfrastructureManager;

    event CheckpointCommitted(uint256 indexed checkpointId, bytes32 stateRootHash, uint256 blockNumber);

    constructor() Ownable(msg.sender) {
        networkInfrastructureManager = msg.sender;
    }

    /**
     * @notice Registers verified off-chain checkpoint roots to guarantee validation alignment.
     */
    function anchorStateCheckpoint(
        uint256 checkpointId, 
        bytes32 rootHash, 
        uint256 blockNumber
    ) external {
        require(msg.sender == networkInfrastructureManager, "AuthError: Caller identity matches no whitelisted node profiles");
        
        globalCheckpointLogs[checkpointId] = RootCheckpoint({
            stateRootHash: rootHash,
            confirmedBlockNumber: blockNumber,
            isValidated: true
        });

        emit CheckpointCommitted(checkpointId, rootHash, blockNumber);
    }
}
