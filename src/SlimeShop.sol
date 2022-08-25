// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {MerkleProofLib} from "solady/utils/MerkleProofLib.sol";
import {BoundLayerableFirstComposedCutoff} from "bound-layerable/examples/BoundLayerableFirstComposedCutoff.sol";
import {CommissionWithdrawable} from "utility-contracts/withdrawable/CommissionWithdrawable.sol";
import {ConstructorArgs} from "./Structs.sol";

contract SlimeShop is
    BoundLayerableFirstComposedCutoff,
    CommissionWithdrawable
{
    uint256 immutable MINT_PRICE = 0.2 ether;
    uint256 immutable MAX_SETS_PER_WALLET = 5;
    bytes32 public merkleRoot;
    uint256 public publicSaleStartTime;

    error IncorrectPayment(uint256 got, uint256 want);
    error InvalidProof();
    error MaxMintsExceeded(uint256 numLeft);
    error MintNotActive(uint256 startTime);

    constructor(ConstructorArgs memory args)
        BoundLayerableFirstComposedCutoff(
            args.name,
            args.symbol,
            args.vrfCoordinatorAddress,
            args.maxNumSets,
            args.numTokensPerSet,
            args.subscriptionId,
            args.metadataContractAddress,
            args.firstComposedCutoff,
            args.exclusiveLayerId
        )
        CommissionWithdrawable(args.feeRecipient, args.feeBps)
    {
        merkleRoot = args.merkleRoot;
        publicSaleStartTime = args.startTime;
    }

    function mint(uint256 numSets) public payable {
        uint256 _publicSaleStartTime = publicSaleStartTime;
        if (block.timestamp < _publicSaleStartTime) {
            revert MintNotActive(_publicSaleStartTime);
        }
        uint256 price = MINT_PRICE * numSets;
        if (msg.value < price) {
            revert IncorrectPayment(msg.value, price);
        }
        uint256 numSetsMinted = _numberMinted(msg.sender) / NUM_TOKENS_PER_SET;
        if (MAX_SETS_PER_WALLET < numSetsMinted + numSets) {
            revert MaxMintsExceeded(MAX_SETS_PER_WALLET - numSetsMinted);
        }
        _mint(msg.sender, numSets * NUM_TOKENS_PER_SET);
    }

    function mintAllowList(
        uint256 numSets,
        uint256 mintPrice,
        uint256 maxForWallet,
        uint256 startTime,
        bytes32[] calldata proof
    ) public payable {
        if (block.timestamp < startTime) {
            revert MintNotActive(startTime);
        }
        if (msg.value < mintPrice) {
            revert IncorrectPayment(msg.value, mintPrice);
        }
        uint256 numberMinted = _numberMinted(msg.sender) / NUM_TOKENS_PER_SET;
        if (maxForWallet < numberMinted + numSets) {
            revert MaxMintsExceeded(maxForWallet - numberMinted);
        }
        bool isValid = MerkleProofLib.verify(
            proof,
            merkleRoot,
            keccak256(
                abi.encode(msg.sender, mintPrice, maxForWallet, startTime)
            )
        );
        if (!isValid) {
            revert InvalidProof();
        }

        _mint(msg.sender, numSets * NUM_TOKENS_PER_SET);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setPublicSaleStartTime(uint256 startTime) public onlyOwner {
        publicSaleStartTime = startTime;
    }

    /**
     * @notice Determine layer type by its token ID
     */
    function getLayerType(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint8 layerType)
    {
        uint256 numTokensPerSet = NUM_TOKENS_PER_SET;

        /// @solidity memory-safe-assembly
        assembly {
            layerType := mod(tokenId, numTokensPerSet)
            if gt(layerType, 5) {
                layerType := 5
            }
        }
    }
}
