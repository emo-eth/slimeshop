// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SlimeShop.sol";
import {Merkle} from "murky/Merkle.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";
import {BatchNotRevealed} from "bound-layerable/interface/Errors.sol";

contract SlimeShopRevealTest is Test {
    SlimeShop public test;
    uint8[] layerTypes;
    uint256[2][] typeDistributions;
    ConstructorArgs constructorArgs;

    bytes32[] proof;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    function setUp() public {
        bytes32[] memory leaves = new bytes32[](101);
        // address[] memory addresses = new address[](100);
        for (uint160 i; i < 100; i++) {
            leaves[i] = keccak256(
                abi.encodePacked(
                    address(i),
                    uint256(0.2 ether),
                    uint256(5),
                    uint256(1)
                )
            );
        }
        leaves[100] = keccak256(
            abi.encodePacked(
                address(this),
                uint256(0.2 ether),
                uint256(5),
                uint256(1)
            )
        );
        Merkle m = new Merkle();
        proof = m.getProof(leaves, 100);

        constructorArgs.name = "SlimeShop";
        constructorArgs.symbol = "SS";
        constructorArgs.vrfCoordinatorAddress = address(1);
        constructorArgs.maxNumSets = 5555;
        constructorArgs.numTokensPerSet = 7;
        constructorArgs.subscriptionId = 1;
        constructorArgs.metadataContractAddress = address(2);
        constructorArgs.firstComposedCutoff = 2**32;
        constructorArgs.exclusiveLayerId = 255;
        constructorArgs.merkleRoot = m.getRoot(leaves);
        constructorArgs.startTime = 0;
        constructorArgs.feeRecipient = address(3);
        constructorArgs.feeBps = 10;
        constructorArgs.royaltyInfo = RoyaltyInfo(address(1), 1);
        constructorArgs.publicMintPrice = 0.2 ether;
        constructorArgs.maxSetsPerWallet = 5555;

        test = new SlimeShop(constructorArgs);
        configureDistributions();
        test.setLayerTypeDistributions(layerTypes, typeDistributions);
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

    function testMintOutReveal() public {
        test.mint{value: 0.2 ether * 5555}(5555);

        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = type(uint256).max;
        vm.prank(address(1));
        test.rawFulfillRandomWords(1, randomWords);
        for (uint256 i; i < 5555 * 7; i++) {
            test.getLayerId(i);
        }
    }

    function testMintOutReveal_AllZeroStillWorks() public {
        test.mint{value: 0.2 ether * 5555}(5555);

        uint256 randomness = 0;
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = randomness;
        vm.prank(address(1));
        test.rawFulfillRandomWords(1, randomWords);
        for (uint256 i; i < 5555 * 7; i++) {
            test.getLayerId(i);
        }
    }

    function testMintOutReveal_lastBatchSeparate() public {
        test.mint{value: 0.2 ether * 5554}(5554);

        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = type(uint256).max;
        vm.prank(address(1));
        test.rawFulfillRandomWords(1, randomWords);
        for (uint256 i; i < 5220 * 7; i++) {
            test.getLayerId(i);
        }
        vm.expectRevert(BatchNotRevealed.selector);
        test.getLayerId(5220 * 7);

        test.mint{value: 0.2 ether}(1);
        vm.prank(address(1));
        test.rawFulfillRandomWords(1, randomWords);
        for (uint256 i = 5220 * 7; i < 5555 * 7; i++) {
            test.getLayerId(i);
        }
    }
}
