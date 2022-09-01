// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SlimeShop.sol";
import {Merkle} from "murky/Merkle.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";

contract SlimeShoptTest is Test {
    SlimeShop public test;

    ConstructorArgs constructorArgs;

    bytes32[] proof;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    function setUp() public {
        bytes32[] memory leaves = new bytes32[](101);
        // address[] memory addresses = new address[](100);
        for (uint160 i; i < 100; i++) {
            leaves[i] = keccak256(abi.encode(address(i), 0.2 ether, 5, 1));
        }
        leaves[100] = keccak256(abi.encode(address(this), 0.2 ether, 5, 1));
        Merkle m = new Merkle();
        proof = m.getProof(leaves, 100);

        constructorArgs.name = "SlimeShop";
        constructorArgs.symbol = "SS";
        constructorArgs.vrfCoordinatorAddress = address(1);
        constructorArgs.maxNumSets = 5555;
        constructorArgs.numTokensPerSet = 7;
        constructorArgs.subscriptionId = 1;
        constructorArgs.metadataContractAddress = address(2);
        constructorArgs.firstComposedCutoff = 2**32;
        constructorArgs.exclusiveLayerId = 255;
        constructorArgs.merkleRoot = m.getRoot(leaves);
        constructorArgs.startTime = 0;
        constructorArgs.feeRecipient = address(3);
        constructorArgs.feeBps = 10;
        constructorArgs.royaltyInfo = RoyaltyInfo(address(1), 1);
        constructorArgs.publicMintPrice = 0.2 ether;
        constructorArgs.maxSetsPerWallet = 5;

        test = new SlimeShop(constructorArgs);
    }

    function _expectEmitId(
        address from,
        address to,
        uint256 id
    ) internal {
        vm.expectEmit(true, true, true, false, address(test));
        emit Transfer(from, to, id);
    }

    function testMint() public {
        for (uint256 i; i < 7; i++) {
            _expectEmitId(address(0), address(this), i);
        }
        test.mint{value: 0.2 ether}(1);
    }

    function testMint_notActive() public {
        test.setPublicSaleStartTime(block.timestamp + 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                SlimeShop.MintNotActive.selector,
                block.timestamp + 1
            )
        );
        test.mint{value: 0.2 ether}(1);
    }

    function testMint_incorrectPayment() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                SlimeShop.IncorrectPayment.selector,
                0.19 ether,
                0.2 ether
            )
        );
        test.mint{value: 0.19 ether}(1);
    }

    function testMint_maxMintsExceeded() public {
        test.mint{value: 0.2 ether}(1);
        vm.expectRevert(
            abi.encodeWithSelector(SlimeShop.MaxMintsExceeded.selector, 4)
        );
        test.mint{value: 1 ether}(5);
    }

    function testMintAllowList() public {
        for (uint256 i; i < 7; i++) {
            _expectEmitId(address(0), address(this), i);
        }
        test.mintAllowList{value: 0.2 ether}(1, 0.2 ether, 5, 1, proof);
    }

    function testMintAllowList_notActive() public {
        vm.warp(0);
        vm.expectRevert(
            abi.encodeWithSelector(
                SlimeShop.MintNotActive.selector,
                block.timestamp + 1
            )
        );
        test.mintAllowList{value: 0.2 ether}(1, 0.2 ether, 5, 1, proof);
    }

    function testMintAllowList_incorrectPayment() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                SlimeShop.IncorrectPayment.selector,
                0.19 ether,
                0.2 ether
            )
        );
        test.mintAllowList{value: 0.19 ether}(1, 0.2 ether, 5, 1, proof);
    }

    function testMintAllowList_maxMintsExceeded() public {
        test.mintAllowList{value: 0.2 ether}(1, 0.2 ether, 5, 1, proof);
        vm.expectRevert(
            abi.encodeWithSelector(SlimeShop.MaxMintsExceeded.selector, 4)
        );
        test.mintAllowList{value: 1 ether}(5, 0.2 ether, 5, 1, proof);
    }

    function testMintAllowList_invalidProof() public {
        vm.expectRevert(
            abi.encodeWithSelector(SlimeShop.InvalidProof.selector)
        );
        test.mintAllowList{value: 0.2 ether}(1, 0.2 ether, 5, 0, proof);
    }

    function testSetMerkleRoot() public {
        bytes32 root = bytes32(uint256(5));
        test.setMerkleRoot(root);
        assertEq(test.merkleRoot(), root);
    }

    function testSetPublicSaleStartTime() public {
        test.setPublicSaleStartTime(10);
        assertEq(test.publicSaleStartTime(), 10);
    }

    function testSetPublicSaleStartTime_onlyOwner() public {
        vm.startPrank(address(5));
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        test.setPublicSaleStartTime(10);
    }

    function testGetLayerType() public {
        assertEq(test.getLayerType(0), 0);
        assertEq(test.getLayerType(1), 1);
        assertEq(test.getLayerType(2), 2);
        assertEq(test.getLayerType(3), 3);
        assertEq(test.getLayerType(4), 4);
        assertEq(test.getLayerType(5), 5);
        assertEq(test.getLayerType(6), 5);
        assertEq(test.getLayerType(7), 0);
    }

    function testGetLayerType(uint256 number) public {
        uint256 mod = number % 7;
        uint256 expected = mod > 5 ? 5 : mod;
        assertEq(test.getLayerType(number), expected);
    }

    function testSetDefaultRoyaltyInfo() public {
        test.setDefaultRoyalty(address(5), 100);
        (address receiver, uint256 amount) = test.royaltyInfo(0, 10000);
        assertEq(receiver, address(5));
        assertEq(amount, 100);
    }

    function testSetDefaultRoyaltyInfo_onlyOwner(address addr) public {
        vm.assume(addr != address(this));
        vm.startPrank(addr);
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        test.setDefaultRoyalty(address(5), 100);
    }

    function testSupportsInterface() public {
        assertTrue(test.supportsInterface(type(IERC2981).interfaceId));
    }

    function testSetPublicMintPrice() public {
        test.setPublicMintPrice(0.1 ether);
        assertEq(test.publicMintPrice(), 0.1 ether);
    }

    function testSetPublicMintPric_onlyOwner() public {
        vm.startPrank(address(5));
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        test.setPublicMintPrice(0.1 ether);
    }
}
