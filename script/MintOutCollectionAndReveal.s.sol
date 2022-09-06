// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";
import {PackedByteUtility} from "bound-layerable/lib/PackedByteUtility.sol";

contract MintOutCollectionAndReveal is Script {
    function setUp() public virtual {
        Solenv.config();
    }

    function run() public {
        setUp();
        address deployer = vm.envAddress("DEPLOYER");
        address token = vm.envAddress("MINT_OUT_TOKEN");
        SlimeShop slimeShop = SlimeShop(token);
        vm.startBroadcast(deployer);
        slimeShop.setMaxMintedSetsPerWallet(type(uint64).max);
        for (uint256 i; i < 16; ++i) {
            slimeShop.mint(347);
        }
        slimeShop.mint(3);
        slimeShop.requestRandomWords();
    }
}
