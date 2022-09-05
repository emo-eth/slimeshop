// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SlimeShop.sol";
import {Merkle} from "murky/Merkle.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";

contract SlimeShopTest is Test {
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
            leaves[i] = keccak256(
                abi.encodePacked(
                    address(i),
                    uint256(0.2 ether),
                    uint256(5),
                    uint256(1)
                )
            );
        }
        leaves[100] = keccak256(
            abi.encodePacked(
                address(this),
                uint256(0.2 ether),
                uint256(5),
                uint256(1)
            )
        );
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
        test.setPublicSaleStartTime(uint64(block.timestamp + 1));
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
        assertEq(test.getPublicSaleStartTime(), 10);
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
        assertEq(test.getPublicMintPrice(), 0.1 ether);
    }

    function testSetPublicMintPric_onlyOwner() public {
        vm.startPrank(address(5));
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        test.setPublicMintPrice(0.1 ether);
    }

    function testGeneratedAllowList() public {
        test.setMerkleRoot(
            0x96d2442fbaa5f27be7314d06132e36c424f6b7aff481166359f863b851f9c6d8
        );
        bytes32[13] memory _proof = [
            bytes32(
                0x1b8088c2dcb81d2977ecf16ce269a594aa6e7d9a15af52d1896e799d15f02e29
            ),
            bytes32(
                0xa1b6f0c4928cb49da26f9502b78b1eb4a7d6bc3ebcc2dcde671ce72d12e5323e
            ),
            bytes32(
                0xb14caa9fdfc1ce6619b3643171f0471af2da0df24d63a465bdf8ab684acc422e
            ),
            bytes32(
                0x2b13c1f4fb374f7412da611785a47ce9624f6747b617810c070a7cf36317cd0a
            ),
            bytes32(
                0xa4835cff014139f547664816f8a839f49d5bf20e74ac6d0e1c7eb64cedfe5480
            ),
            bytes32(
                0x4227e38144ef611a30eaf71a8c192f2b09342bb6963d7ac0a7d44a734b2a3ac1
            ),
            bytes32(
                0x522e17ff193ac25d7bf4b9642033eea700c8509e9ea8109982b55c0bab179f89
            ),
            bytes32(
                0x268f41439b9faa52bb34c0c57b47bf232dd5527319817edf5175467e5dc65776
            ),
            bytes32(
                0x29b206dd0d6b50f709a031ead70a9c741b8229aa322ebd69e3102f24c7a0c369
            ),
            bytes32(
                0x1ca0b8a24ef9728429ccc2dc9bb158012b8d9a679b8bb375acf262a77b78daf7
            ),
            bytes32(
                0x17b8a6f26bb8027eb19563edf34abea8ca8b0897fe00d9cd6d6ba58247d9ffd0
            ),
            bytes32(
                0x7ef2875b59a072bbd30073a1a2d7c2f0e8e5079463137c2cb2f1640bd0b6034d
            ),
            bytes32(
                0x1a26bdbc844c990481656e86e5f6b65bb430fb99cd48d0fe58be609ad5fc5df5
            )
        ];
        bytes32[] memory newProof = new bytes32[](13);
        for (uint256 i = 0; i < 13; i++) {
            newProof[i] = _proof[i];
        }
        vm.warp(1662652800);

        startHoax(0x0E2bc0b90B2C9a6B3C91016FF80de944B4d4D96e, 100 ether);
        test.mintAllowList{value: 95000000000000000}(
            1,
            95000000000000000,
            5,
            1662652800,
            newProof
        );

        _proof = [
            bytes32(
                0x18a552e32753bd2389843644bb1cf7fbf40261e6decf0f1020948cd040f70a68
            ),
            bytes32(
                0xa2efc27956632ae1d063bee79b2674ad2d3b0301406e4266bed75e0c8bad208c
            ),
            bytes32(
                0x2c3f50fd2742cf697fae8a0c57c0fe066d0ecf3c25f7253a68ee91d10d52b9d8
            ),
            bytes32(
                0x14c22e6d55f56f5a230e2089a913b4c564700040050a21779750445466796698
            ),
            bytes32(
                0xde1bbb9af7f3985ec0473dab63bc3e4a5367c0d0641f7f1c5f6a42707aee35ba
            ),
            bytes32(
                0xb313244061c48991b13b3c128e49a7a7609f1ccc8cbc94b789631180d664f71b
            ),
            bytes32(
                0x4551c2273a51ab6a2abef6a93d50cbffbeea4851aed9d6fa27ecf28b6183f1a2
            ),
            bytes32(
                0x453208dd67be54872334012aca376afa591a71b3f1a0858cc503beb1915146ee
            ),
            bytes32(
                0x29b206dd0d6b50f709a031ead70a9c741b8229aa322ebd69e3102f24c7a0c369
            ),
            bytes32(
                0x1ca0b8a24ef9728429ccc2dc9bb158012b8d9a679b8bb375acf262a77b78daf7
            ),
            bytes32(
                0x17b8a6f26bb8027eb19563edf34abea8ca8b0897fe00d9cd6d6ba58247d9ffd0
            ),
            bytes32(
                0x7ef2875b59a072bbd30073a1a2d7c2f0e8e5079463137c2cb2f1640bd0b6034d
            ),
            bytes32(
                0x1a26bdbc844c990481656e86e5f6b65bb430fb99cd48d0fe58be609ad5fc5df5
            )
        ];

        vm.warp(1662660000);
        newProof = new bytes32[](13);
        for (uint256 i = 0; i < 13; i++) {
            newProof[i] = _proof[i];
        }

        test.mintAllowList{value: 150000000000000000}(
            1,
            150000000000000000,
            10,
            1662660000,
            newProof
        );
    }
}
