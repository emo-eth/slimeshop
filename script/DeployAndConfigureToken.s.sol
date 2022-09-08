// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";
import {ScriptBase} from "./ScriptBase.s.sol";

//104820+121987+8191965+904578+2716771+3660579+293558+77894
interface ConsumerAdder {
    function addConsumer(uint64 id, address consumer) external;
}

contract DeployAndConfigureToken is ScriptBase {
    uint8[] layerTypes;
    uint256[2][] typeDistributions;
    ConstructorArgs constructorArgs;
    ConsumerAdder subscription;

    struct AllowListLeaf {
        address addr;
        uint256 mintPrice;
        uint256 maxSetsForWallet;
        uint256 startTime;
    }

    function setUp() public virtual override {
        super.setUp();

        configureDistributions();

        address vrfCoordinatorAddress;
        bytes32 keyHash;
        if (block.chainid == 1) {
            vrfCoordinatorAddress = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
            keyHash = bytes32(
                0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef
            );
        } else if (block.chainid == 4) {
            vrfCoordinatorAddress = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
            subscription = ConsumerAdder(
                0x6168499c0cFfCaCD319c818142124B7A15E857ab
            );
            keyHash = bytes32(
                0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc
            );
        }

        constructorArgs.name = "SLIMESHOP";
        constructorArgs.symbol = "SS";
        constructorArgs.vrfCoordinatorAddress = vrfCoordinatorAddress;
        constructorArgs.maxNumSets = 5555;
        constructorArgs.numTokensPerSet = 7;
        constructorArgs.subscriptionId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        constructorArgs.metadataContractAddress = vm.envAddress(
            "METADATA_PROXY"
        );
        constructorArgs.firstComposedCutoff = vm.envUint(
            "FIRST_COMPOSED_CUTOFF_TIMESTAMP"
        );
        constructorArgs.exclusiveLayerId = 255;
        constructorArgs.merkleRoot = vm.envBytes32("MERKLE_ROOT");
        constructorArgs.startTime = uint64(vm.envUint("START_TIME"));
        if (block.chainid != 1) {
            constructorArgs.startTime = 0;
        }
        constructorArgs.feeRecipient = vm.envAddress("FEE_RECIPIENT");
        constructorArgs.feeBps = 250;
        constructorArgs.royaltyInfo = RoyaltyInfo(
            vm.envAddress("ROYALTY_RECIPIENT"),
            uint96(vm.envUint("ROYALTY_FEE_BPS"))
        );
        constructorArgs.publicMintPrice = .15 ether;
        constructorArgs.maxSetsPerWallet = 5;
        constructorArgs.keyHash = keyHash;
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
        // address deployer = vm.envAddress("DEPLOYER");

        vm.startBroadcast(deployer);
        SlimeShop slimeShop = new SlimeShop(constructorArgs);
        vm.makePersistent(address(slimeShop));
        slimeShop.setLayerTypeDistributions(layerTypes, typeDistributions);
        // subscription.addConsumer(
        //     constructorArgs.subscriptionId,
        //     address(slimeShop)
        // );
    }
}
