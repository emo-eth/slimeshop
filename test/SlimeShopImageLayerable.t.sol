// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SlimeShopImageLayerable} from "../src/SlimeShopImageLayerable.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Attribute} from "bound-layerable/interface/Structs.sol";
import {DisplayType} from "bound-layerable/interface/Enums.sol";

contract SlimeShopImageLayerableTestImpl is SlimeShopImageLayerable {
    constructor(
        address _owner,
        string memory _defaultURI,
        uint256 _width,
        uint256 _height,
        string memory _externalLink,
        string memory _description
    )
        SlimeShopImageLayerable(
            _owner,
            _defaultURI,
            _width,
            _height,
            _externalLink,
            _description
        )
    {}

    function getName(uint256 tokenId, uint256 layerId)
        public
        view
        returns (string memory)
    {
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
            "SLIMESHOP"
        );
    }

    function testGetName() public {
        assertEq(test.getName(1, 0), "SLIMESHOP - #2");
        assertEq(test.getName(100, 0), "SLIMESHOP - #101");
    }

    function testGetName(uint256 tokenId) public {
        tokenId = bound(tokenId, 0, type(uint256).max - 1);
        assertEq(
            test.getName(tokenId, 0),
            string.concat("SLIMESHOP - #", (tokenId + 1).toString())
        );
    }

    function testGetName_Layer(uint256 tokenId) public {
        test.setAttribute(1, Attribute("Type", "Name", DisplayType.String));
        tokenId = bound(tokenId, 0, type(uint256).max - 1);
        assertEq(
            test.getName(tokenId, 1),
            string.concat(
                "SLIMESHOP - Type - Name - #",
                (tokenId + 1).toString()
            )
        );
    }
}
