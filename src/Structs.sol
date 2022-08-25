// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

struct ConstructorArgs {
    string name;
    string symbol;
    address vrfCoordinatorAddress;
    uint240 maxNumSets;
    uint8 numTokensPerSet;
    uint64 subscriptionId;
    address metadataContractAddress;
    uint256 firstComposedCutoff;
    uint8 exclusiveLayerId;
    uint256 startTime;
    bytes32 merkleRoot;
    address feeRecipient;
    uint16 feeBps;
}
