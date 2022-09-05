// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";
import {PackedByteUtility} from "bound-layerable/lib/PackedByteUtility.sol";

contract Misc is Script {
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
    }

    function run() public {
        setUp();
        address deployer = vm.envAddress("DEPLOYER");
        address token = vm.envAddress("TOKEN");
        SlimeShop slimeShop = SlimeShop(token);
        bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
        vm.startBroadcast(deployer);
        // slimeShop.setForceUnsafeReveal(true);
        // slimeShop.requestRandomWords(keyHash);
        slimeShop.mint(100);
        slimeShop.mint(100);
        slimeShop.mint(100);
        slimeShop.mint(100);

        // uint256[] memory tokenIds = new uint256[](6);
        // tokenIds[0] = 1;
        // tokenIds[1] = 2;
        // tokenIds[2] = 3;
        // tokenIds[3] = 4;
        // tokenIds[4] = 5;
        // tokenIds[5] = 6;

        // uint256[] memory layerIds = new uint256[](8);
        // layerIds[0] = slimeShop.getLayerId(1);
        // layerIds[1] = slimeShop.getLayerId(0);
        // layerIds[2] = slimeShop.getLayerId(2);
        // layerIds[3] = slimeShop.getLayerId(3);
        // layerIds[4] = slimeShop.getLayerId(4);
        // layerIds[5] = slimeShop.getLayerId(5);
        // layerIds[6] = slimeShop.getLayerId(6);
        // layerIds[7] = 255;

        // uint256 packedLayers = PackedByteUtility.packArrayOfBytes(layerIds);

        // slimeShop.setActiveLayers(0, packedLayers);

        // tokenIds = new uint256[](6);
        // tokenIds[0] = 8;
        // tokenIds[1] = 9;
        // tokenIds[2] = 10;
        // tokenIds[3] = 11;
        // tokenIds[4] = 12;
        // tokenIds[5] = 13;

        // layerIds = new uint256[](7);
        // layerIds[0] = slimeShop.getLayerId(8);
        // layerIds[1] = slimeShop.getLayerId(7);
        // layerIds[2] = slimeShop.getLayerId(9);
        // layerIds[3] = slimeShop.getLayerId(10);
        // layerIds[4] = slimeShop.getLayerId(11);
        // layerIds[5] = slimeShop.getLayerId(12);
        // layerIds[6] = slimeShop.getLayerId(13);

        // packedLayers = PackedByteUtility.packArrayOfBytes(layerIds);

        // slimeShop.burnAndBindMultipleAndSetActiveLayers(
        //     7,
        //     tokenIds,
        //     packedLayers
        // );
    }
}
