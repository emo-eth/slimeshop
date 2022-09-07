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
        vm.startBroadcast(deployer);
        uint256[] memory layerIds = new uint256[](7);
        // uint256 packedBytes
        for (uint256 i; i < 7; i++) {
            layerIds[i] = slimeShop.getLayerId(i);
        }
        uint256 temp = layerIds[0];
        layerIds[0] = layerIds[1];
        layerIds[1] = temp;
        uint256 packedLayers = PackedByteUtility.packArrayOfBytes(layerIds);
        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i; i < 6; i++) {
            tokenIds[i] = i + 1;
        }
        slimeShop.burnAndBindMultipleAndSetActiveLayers(
            0,
            tokenIds,
            packedLayers
        );
    }
}
