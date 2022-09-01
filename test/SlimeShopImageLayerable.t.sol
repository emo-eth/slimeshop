// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SlimeShopImageLayerable} from "../src/SlimeShopImageLayerable.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract SlimeShopImageLayerableTestImpl is SlimeShopImageLayerable {
    constructor(
        address _owner,
        string memory _defaultURI,
        uint256 _width,
        uint256 _height,
        string memory _externalLink,
        string memory _description
    ) SlimeShopImageLayerable(_owner, _defaultURI, _width, _height, _externalLink, _description) {}

    function getName(uint256 tokenId, uint256 layerId) public pure returns (string memory) {
        return _getName(tokenId, layerId);
    }
}

contract SlimeShopImageLayerableTest is Test {
    using Strings for uint256;
    SlimeShopImageLayerableTestImpl public test;

    function setUp() public {
        test = new SlimeShopImageLayerableTestImpl(
            address(this),
            "https://slimeshop.com/metadata/",
            100,
            100,
            "https://slimeshop.com",
            "SlimeShop"
        );
    }

    function testGetName() public {
        assertEq(test.getName(1, 0), "SLIMESHOP #1");
        assertEq(test.getName(100, 0), "SLIMESHOP #100");
    }

    function testGetName(uint256 tokenId, uint256 layerId) public {
        assertEq(test.getName(tokenId, layerId), string.concat("SLIMESHOP #", tokenId.toString()));
    }
}
