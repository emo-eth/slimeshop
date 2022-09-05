// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Solenv} from "solenv/Solenv.sol";
import {SlimeShop} from "../src/SlimeShop.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {Merkle} from "murky/Merkle.sol";
import {PackedByteUtility} from "bound-layerable/lib/PackedByteUtility.sol";
import {SlimeShopImageLayerable} from "../src/SlimeShopImageLayerable.sol";

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

        SlimeShopImageLayerable meta = SlimeShopImageLayerable(
            vm.envAddress("METADATA_CONTRACT_ADDRESS")
        );
        vm.startBroadcast(deployer);
        meta.setBaseLayerURI(
            "https://ipfs.io/ipfs/bafybeihdhwqwskwwv3zdeousavfe5h4lbtxbqqz6yzrlgkzoui7h3smso4/"
        );
    }
}
