// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";

contract DeployAndConfigureToken is Script {
    uint8[] layerTypes;
    uint256[2][] typeDistributions;
    ConstructorArgs constructorArgs;

    struct AllowListLeaf {
        address addr;
        uint256 mintPrice;
        uint256 maxSetsForWallet;
        uint256 startTime;
    }

    function setUp() public virtual {
        Solenv.config();
        configureDistributions();

        address vrfCoordinatorAddress;
        if (block.chainid == 1) {
            vrfCoordinatorAddress = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
        } else if (block.chainid == 4) {
            vrfCoordinatorAddress = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
        }
        uint64 subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        address metadataContractAddress = vm.envAddress(
            "METADATA_CONTRACT_ADDRESS"
        );
        uint256 firstComposedCutoff = vm.envUint(
            "FIRST_COMPOSED_CUTOFF_TIMESTAMP"
        );
        bytes32 merkleRoot = vm.envBytes32("MERKLE_ROOT");
        uint256 startTime = vm.envUint("START_TIME");
        startTime = startTime == 0 ? type(uint256).max : startTime;
        address commissionFeeRecipient = vm.envAddress("FEE_RECIPIENT");
        address royaltyRecipient = vm.envAddress("ROYALTY_RECIPIENT");
        uint96 royaltyFeeBps = uint96(vm.envUint("ROYALTY_FEE_BPS"));

        constructorArgs.name = "SlimeShop";
        constructorArgs.symbol = "SS";
        constructorArgs.vrfCoordinatorAddress = vrfCoordinatorAddress;
        constructorArgs.maxNumSets = 5555;
        constructorArgs.numTokensPerSet = 7;
        constructorArgs.subscriptionId = subscriptionId;
        constructorArgs.metadataContractAddress = metadataContractAddress;
        constructorArgs.firstComposedCutoff = firstComposedCutoff;
        constructorArgs.exclusiveLayerId = 255;
        constructorArgs.merkleRoot = getMerkleRoot();
        constructorArgs.startTime = startTime;
        constructorArgs.feeRecipient = commissionFeeRecipient;
        constructorArgs.feeBps = 250;
        constructorArgs.royaltyInfo = RoyaltyInfo(
            royaltyRecipient,
            royaltyFeeBps
        );
        constructorArgs.publicMintPrice = 0 ether;
        constructorArgs.maxSetsPerWallet = type(uint256).max;
    }

    function getMerkleRoot() internal returns (bytes32) {
        AllowListLeaf[3] memory leaves = [
            AllowListLeaf(
                0x92B381515bd4851Faf3d33A161f7967FD87B1227,
                0.01 ether,
                5,
                0
            ),
            AllowListLeaf(
                0x333601a803CAc32B7D17A38d32c9728A93b422f4,
                0.02 ether,
                6,
                0
            ),
            AllowListLeaf(
                0x700fe545742485732575A7245f558978aDcc1Ec4,
                0.03 ether,
                7,
                0
            )
        ];
        bytes32[] memory leafHashes = new bytes32[](leaves.length);
        for (uint256 i = 0; i < leaves.length; i++) {
            leafHashes[i] = keccak256(
                abi.encode(
                    leaves[i].addr,
                    leaves[i].mintPrice,
                    leaves[i].maxSetsForWallet,
                    leaves[i].startTime
                )
            );
        }

        Merkle m = new Merkle();
        return m.getRoot(leafHashes);
    }

    function configureDistributions() internal {
        // portraits
        layerTypes.push(0);
        typeDistributions.push(
            [
                1146764870214454572372005705909090749636797848474928263168784531573608284160,
                0
            ]
        );
        // backgrounds
        layerTypes.push(1);
        typeDistributions.push(
            [
                208495017330474343448251821138227314844148790927693544181577524367624117055,
                13887655288562992450142584124859346563539026245871512267904637837965152092160
            ]
        );
        // border
        layerTypes.push(2);
        typeDistributions.push(
            [
                208495017330474343448251821138227314844148790927693544181577524367624117055,
                13887655288562992450142584124859346563539026245871512267904637837965152092160
            ]
        );
        // elements1
        layerTypes.push(3);
        typeDistributions.push(
            [
                63610673285430322956485731253965941541180510085047160726691738586079376519,
                27204614499838256474260717365123542471569478288349006619692887323545239027712
            ]
        );
        // elements2
        layerTypes.push(4);
        typeDistributions.push(
            [
                206729949701985366284538115050928240701448356148137036205917058524621453368,
                28913182248320934860928402113556822636822626769031349315100029662104349835264
            ]
        );
        // texture
        layerTypes.push(5);
        typeDistributions.push(
            [
                208495017330474343448251821138227314844148790927693544181577524367624117055,
                13887655288562992450142584124859346563539026245871512267904637837965152092160
            ]
        );
    }

    function run() public {
        setUp();
        address deployer = vm.envAddress("DEPLOYER");

        vm.startBroadcast(deployer);
        SlimeShop slimeShop = new SlimeShop(constructorArgs);
        slimeShop.setLayerTypeDistributions(layerTypes, typeDistributions);
    }
}
