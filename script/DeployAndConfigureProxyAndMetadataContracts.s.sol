// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {TestnetToken} from "bound-layerable/implementations/TestnetToken.sol";
import {Attribute} from "bound-layerable/interface/Structs.sol";
import {DisplayType} from "bound-layerable/interface/Enums.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Solenv} from "solenv/Solenv.sol";
import {ConfigureMetadataContract} from "./ConfigureMetadataContract.s.sol";
import {SlimeShopImageLayerable} from "../src/SlimeShopImageLayerable.sol";

contract DeployAndConfigureMetadataProxy is Script {
    struct AttributeTuple {
        uint256 traitId;
        string name;
    }

    function setUp() public virtual {
        Solenv.config();
    }

    function getLayerTypeStr(uint256 layerId)
        public
        pure
        returns (string memory result)
    {
        uint256 layerType = (layerId - 1) / 32;
        if (layerType == 0) {
            result = "Portrait";
        } else if (layerType == 1) {
            result = "Background";
        } else if (layerType == 2) {
            result = "Texture";
        } else if (layerType == 5 || layerType == 6) {
            result = "Border";
        } else {
            result = "Object";
        }
    }

    function run() public {
        address deployer = vm.envAddress("DEPLOYER");
        address admin = vm.envAddress("ADMIN");

        // use a separate admin account to deploy the proxy
        vm.startBroadcast(admin);
        // deploy this to have a copy of implementation logic
        SlimeShopImageLayerable logic = new SlimeShopImageLayerable(
            deployer,
            "",
            0,
            0,
            "",
            ""
        );
        // deploy proxy using the logic contract, setting "deployer" addr as owner
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(logic),
            admin,
            abi.encodeWithSignature(
                "initialize(address,string,uint256,uint256,string,string)",
                deployer,
                "default",
                1000,
                1250,
                "https://slimeshop.slimesunday.com",
                "hello world"
            )
        );
        vm.stopBroadcast();

        ConfigureMetadataContract configure = new ConfigureMetadataContract();
        configure.run(address(proxy));
    }
}
