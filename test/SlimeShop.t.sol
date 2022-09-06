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
            0x34f5d73d194b6fba70855b32365dfb06807a9113c81f7ca28e261fc05a00ea67
        );
        bytes32[13] memory _proof = [
            bytes32(
                0xfaba3211a659a50115f80392f5471f7dee9097650d02e808669638eb7b896ead
            ),
            bytes32(
                0x7af6b72f2a9ec1038fa03c97bae33f9ec919273517448cc167c84b870e227000
            ),
            bytes32(
                0xb64b0ebd1826ea8f493faa4512f33fd60297027c320777d773974adb09c492d8
            ),
            bytes32(
                0xcc1cbe64595829503e6a0cb62a9cc3a530ffb6fef07f0e0449fcd59f2e15bb06
            ),
            bytes32(
                0x4abcbf51c57168e3d5de7dac66c024350016969dbcb99eaf60cc0761fb6cdeb8
            ),
            bytes32(
                0x2369660fff3e4226450ea7ba4108e14e5546750b0d6c8b91c0ff3cf35acbf44f
            ),
            bytes32(
                0x6c669b36eb4e77b4f82bba75751fd7a6ae05c6abb2654badfe947b3c07e45200
            ),
            bytes32(
                0x46dbed7c71375dcde762832306f3bb8d645c265b12f4d4ec7fd69fe49d5d89db
            ),
            bytes32(
                0x2a17bdcc2545633b62d5a3a80ea337836cdac149c2e6c03f3cab57c38d7f6b44
            ),
            bytes32(
                0x5be8de11e7523caeb1a1a2bd407f356fe37d752ed5a8a3319fb9cf3f9fbb6884
            ),
            bytes32(
                0xc6ec3794b32748ffe28463de6ca6ff5191f6069c7283f75f1b2a9175beec6164
            ),
            bytes32(
                0xf1837fcc1bd629d46a05adbf3c93b5f12c873afe43fabf6a570debfbf28d5e4e
            ),
            bytes32(
                0x6df245d0af423e10c93cc091e76031c014ab71e8dda9f28aa046f7c38004b60e
            )
        ];
        bytes32[] memory newProof = new bytes32[](13);
        for (uint256 i = 0; i < 13; i++) {
            newProof[i] = _proof[i];
        }
        vm.warp(1662421847);

        startHoax(0x124AEfa2Fa991c62c3A137369fA8cd076dE27B80, 100 ether);
        test.mintAllowList{value: 95000000000000000}(
            1,
            95000000000000000,
            5,
            1662421847,
            newProof
        );

        _proof = [
            bytes32(
                0x1b3e2c153591a89bd1aaeea1ca5b64a7ebc9cf9f66d402eee0193673733d25d3
            ),
            bytes32(
                0xdcc8be27e506e2b4a789d61864b07e8a320f057a6be5ae4eb72bb3e7fed3746a
            ),
            bytes32(
                0x2dabf96b488d5d59075fa75b065a8f41c00b1d8a0dcde3b0fb3fafdef283b6b3
            ),
            bytes32(
                0xd737e80138c8535c4c2f5c342612753d5e135f6eebeaf4db16ec8fa8b1e0cf39
            ),
            bytes32(
                0x1aa9bdaf2b56ecff7881df98f3e449dc43534434cd403cc9e1bfc557d3766f15
            ),
            bytes32(
                0x1314882e983335e2550741b9b02c4141b939f82d34e88ae71e37cf59afe0c023
            ),
            bytes32(
                0x53f7e2438b1ae1f4d287afbbf9c498f81b0f96736fc1e3d9676ce57bcae3a9a6
            ),
            bytes32(
                0x93f5c1b469d050c373747fb707ad62af8c7b68aee483d3b8437f9d05fec40eef
            ),
            bytes32(
                0xdd71a593bf8e34055ef570a6abb746976aa8609a869b97db985b9203dfef4f9c
            ),
            bytes32(
                0xb63fbea70bb45c7de6628cc1c70e7e824031f8ca7cdd63c1fac9a552b3fc5a19
            ),
            bytes32(
                0xdb6d70fd24ad44450565c696b26239ba73cd5d9de58cdc1ac0c9420ee171cdac
            ),
            bytes32(
                0x94c6d9a550d6e602354abcd7192fd8e013e26187fea1dfadb72a9c8419999856
            ),
            bytes32(
                0x5f30fd6ea8b4db5d0ff4df679e2040c581f410bea6885059d19774acb2b13ff0
            )
        ];

        newProof = new bytes32[](13);
        for (uint256 i = 0; i < 13; i++) {
            newProof[i] = _proof[i];
        }

        test.mintAllowList{value: 150000000000000000}(
            1,
            150000000000000000,
            10,
            1662421847,
            newProof
        );
    }
}
