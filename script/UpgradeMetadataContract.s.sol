// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Layerable} from "bound-layerable/metadata/Layerable.sol";
import {ImageLayerable} from "bound-layerable/metadata/ImageLayerable.sol";
import {Attribute} from "bound-layerable/interface/Structs.sol";
import {DisplayType} from "bound-layerable/interface/Enums.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Solenv} from "solenv/Solenv.sol";
import {TestnetToken} from "bound-layerable/implementations/TestnetToken.sol";

contract Deploy is Script {
  using Strings for uint256;

  struct AttributeTuple {
    uint256 traitId;
    string name;
  }

  function setUp() public virtual {
    Solenv.config();
  }

  function run() public {
    address deployer = vm.envAddress("DEPLOYER");
    address admin = vm.envAddress("ADMIN");
    // address proxyAddress = vm.envAddress("METADATA_PROXY");
    address tokenAddress = vm.envAddress("TOKEN");

    address proxyAddress = address(
      TestnetToken(tokenAddress).metadataContract()
    );

    vm.startBroadcast(admin);

    // deploy new logic contracts
    ImageLayerable logic = new ImageLayerable(deployer, "", 0, 0);
    TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(
      payable(proxyAddress)
    );

    // upgrade proxy to use the new logic contract
    proxy.upgradeTo(address(logic));
    // vm.stopBroadcast();

    vm.stopBroadcast();
    vm.startBroadcast(deployer);
    ImageLayerable impl = ImageLayerable(proxyAddress);
    impl.setWidth(1000);
    impl.setHeight(1250);
  }
}