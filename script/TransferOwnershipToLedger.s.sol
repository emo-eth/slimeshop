// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {ScriptBase} from "./ScriptBase.s.sol";
import {SlimeShop} from "../src/SlimeShop.sol";

contract TransferOwnershipToLedger is ScriptBase {
    SlimeShop slimeShop;

    function setUp() public virtual override {
        super.setUp();
        slimeShop = SlimeShop(vm.envAddress("TOKEN"));
    }

    function run() public {
        address ledger = vm.envAddress("LEDGER_ADDRESS");

        vm.startBroadcast(deployer);
        slimeShop.transferOwnership(ledger);

        vm.stopBroadcast();
        vm.startBroadcast(ledger);
        slimeShop.acceptOwnership();
    }
}
