// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";

contract ScriptBase is Script {
    address deployer;
    address admin;

    function setUp() public virtual {
        Solenv.config();
        Solenv.config(".secret");
        bytes32 pkey = vm.envBytes32("ADMIN_PRIVATE_KEY");
        admin = vm.rememberKey(uint256(pkey));
        pkey = vm.envBytes32("DEPLOYER_PRIVATE_KEY");
        deployer = vm.rememberKey(uint256(pkey));
    }
}
