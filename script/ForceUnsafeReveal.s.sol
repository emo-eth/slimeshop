// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";
import {PackedByteUtility} from "bound-layerable/lib/PackedByteUtility.sol";
import {ScriptBase} from "./ScriptBase.s.sol";

contract ForceUnsafeReveal is ScriptBase {
    uint8[] layerTypes;
    uint256[2][] typeDistributions;

    function run() public {
        setUp();
        address token = vm.envAddress("TOKEN");
        SlimeShop slimeShop = SlimeShop(token);
        vm.startBroadcast(deployer);
        slimeShop.setForceUnsafeReveal(true);
        slimeShop.requestRandomWords();
    }
}
