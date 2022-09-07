// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SlimeShop.sol";
import {Merkle} from "murky/Merkle.sol";
import {ConstructorArgs, RoyaltyInfo} from "../src/Structs.sol";
import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";
import {SlimeShopImageLayerable} from "../src/SlimeShopImageLayerable.sol";
import {Attribute} from "bound-layerable/interface/Structs.sol";
import {DisplayType} from "bound-layerable/interface/Enums.sol";

contract SlimeShoptTest is Test {
    SlimeShop public test;

    ConstructorArgs constructorArgs;

    bytes32[] proof;
    uint256[] traitIds;
    Attribute[] attributes;
    SlimeShopImageLayerable imageLayerable;

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

        constructorArgs.name = "SLIMESHOP";
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

        configureImageLayerable();
    }

    struct AttributeTuple {
        uint256 traitId;
        string name;
    }

    function configureAttributes() internal {
        AttributeTuple[164] memory attributeTuples = [
            AttributeTuple(3, "Portrait A3"),
            AttributeTuple(9, "Portrait C1"),
            AttributeTuple(1, "Portrait A4"),
            AttributeTuple(4, "Portrait B2"),
            AttributeTuple(8, "Portrait C2"),
            AttributeTuple(5, "Portrait A2"),
            AttributeTuple(6, "Portrait A1"),
            AttributeTuple(2, "Portrait B3"),
            AttributeTuple(7, "Portrait B1"),
            AttributeTuple(41, "Cranium"),
            AttributeTuple(60, "Dirty Grid Paper"),
            AttributeTuple(42, "Disassembled"),
            AttributeTuple(44, "Postal Worker"),
            AttributeTuple(56, "Angled Gradient"),
            AttributeTuple(36, "Haze"),
            AttributeTuple(35, "Upside Down"),
            AttributeTuple(50, "Shoebox"),
            AttributeTuple(62, "Blue"),
            AttributeTuple(40, "100 Dollars"),
            AttributeTuple(45, "Close-up"),
            AttributeTuple(37, "Sticky Fingers"),
            AttributeTuple(38, "Top Secret"),
            AttributeTuple(64, "Off White"),
            AttributeTuple(34, "Censorship Can!"),
            AttributeTuple(49, "13 Years Old"),
            AttributeTuple(53, "Washed Out"),
            AttributeTuple(61, "Grunge Paper"),
            AttributeTuple(54, "Marbled Paper"),
            AttributeTuple(46, "Gene Sequencing"),
            AttributeTuple(51, "Geological Study"),
            AttributeTuple(48, "Refractory Factory"),
            AttributeTuple(43, "Day Trader"),
            AttributeTuple(58, "Linear Gradient"),
            AttributeTuple(63, "Red"),
            AttributeTuple(47, "Seedphrase"),
            AttributeTuple(33, "Split"),
            AttributeTuple(52, "Clouds"),
            AttributeTuple(55, "Warped Gradient"),
            AttributeTuple(39, "Fractals"),
            AttributeTuple(59, "Spheres"),
            AttributeTuple(57, "Radial Gradient"),
            AttributeTuple(192, "Subtle Dust"),
            AttributeTuple(167, "Rips Bottom"),
            AttributeTuple(171, "Restricted"),
            AttributeTuple(186, "Dirty"),
            AttributeTuple(168, "Crusty Journal"),
            AttributeTuple(181, "Plastic & Sticker"),
            AttributeTuple(174, "Folded Paper Stack"),
            AttributeTuple(177, "Extreme Dust & Grime"),
            AttributeTuple(179, "Folded Paper"),
            AttributeTuple(165, "Rips Top"),
            AttributeTuple(180, "Midline Destroyed"),
            AttributeTuple(184, "Wax Paper"),
            AttributeTuple(182, "Wrinkled"),
            AttributeTuple(163, "Crinkled & Torn"),
            AttributeTuple(169, "Burn It"),
            AttributeTuple(185, "Wheatpasted"),
            AttributeTuple(162, "Perfect Tear"),
            AttributeTuple(161, "Puzzle"),
            AttributeTuple(176, "Old Document"),
            AttributeTuple(172, "Destroyed Edges"),
            AttributeTuple(187, "Magazine Glare"),
            AttributeTuple(178, "Water Damage"),
            AttributeTuple(189, "Inked"),
            AttributeTuple(166, "Rips Mid"),
            AttributeTuple(173, "Grainy Cover"),
            AttributeTuple(175, "Single Fold"),
            AttributeTuple(188, "Scanner"),
            AttributeTuple(190, "Heavy Dust & Scratches"),
            AttributeTuple(191, "Dust & Scratches"),
            AttributeTuple(183, "Slightly Wrinkled"),
            AttributeTuple(170, "Scuffed Up"),
            AttributeTuple(164, "Torn & Taped"),
            AttributeTuple(148, "TSA Sticker"),
            AttributeTuple(118, "Postage Sticker"),
            AttributeTuple(157, "Scribble 2"),
            AttributeTuple(121, "Barcode Sticker"),
            AttributeTuple(113, "Time Flies"),
            AttributeTuple(117, "Clearance Sticker"),
            AttributeTuple(120, "Item Label"),
            AttributeTuple(151, "Record Sticker"),
            AttributeTuple(144, "Monday"),
            AttributeTuple(149, "Used Sticker"),
            AttributeTuple(112, "Cutouts 2"),
            AttributeTuple(114, "There"),
            AttributeTuple(116, "Dossier Cut Outs"),
            AttributeTuple(153, "Abstract Lines"),
            AttributeTuple(119, "Special Sticker"),
            AttributeTuple(150, "Bora Bora"),
            AttributeTuple(123, "Alphabet"),
            AttributeTuple(124, "Scribble 3"),
            AttributeTuple(155, "Border Accents"),
            AttributeTuple(154, "Sphynx"),
            AttributeTuple(125, "Scribble 1"),
            AttributeTuple(115, "SQR"),
            AttributeTuple(111, "Cutouts 1"),
            AttributeTuple(145, "Here"),
            AttributeTuple(146, "Pointless Wayfinder"),
            AttributeTuple(122, "Yellow Sticker"),
            AttributeTuple(156, "Incomplete Infographic"),
            AttributeTuple(152, "Shredded Paper"),
            AttributeTuple(147, "Merch Sticker"),
            AttributeTuple(107, "Chain-Links"),
            AttributeTuple(104, "Weird Fruits"),
            AttributeTuple(143, "Cutouts 3"),
            AttributeTuple(135, "Floating Cactus"),
            AttributeTuple(140, "Favorite Number"),
            AttributeTuple(109, "Botany"),
            AttributeTuple(98, "Puddles"),
            AttributeTuple(100, "Game Theory"),
            AttributeTuple(137, "Zeros"),
            AttributeTuple(130, "Title Page"),
            AttributeTuple(136, "Warning Labels"),
            AttributeTuple(131, "Musical Chairs"),
            AttributeTuple(108, "Windows"),
            AttributeTuple(102, "Catz"),
            AttributeTuple(110, "Facial Features"),
            AttributeTuple(105, "Mindless Machines"),
            AttributeTuple(99, "Asymmetry"),
            AttributeTuple(134, "Meat Sweats"),
            AttributeTuple(142, "Factory"),
            AttributeTuple(139, "I C U"),
            AttributeTuple(132, "Too Many Eyes"),
            AttributeTuple(101, "Floriculture"),
            AttributeTuple(141, "Anatomy Class"),
            AttributeTuple(129, "Rubber"),
            AttributeTuple(133, "Marked"),
            AttributeTuple(97, "Split"),
            AttributeTuple(103, "Some Birds"),
            AttributeTuple(106, "Unhinged"),
            AttributeTuple(138, "Mediocre Painter"),
            AttributeTuple(95, "Simple Curved Border"),
            AttributeTuple(92, "Taped Edge"),
            AttributeTuple(94, "Simple Border With Square"),
            AttributeTuple(65, "Dossier"),
            AttributeTuple(79, "Sunday"),
            AttributeTuple(93, "Cyber Frame"),
            AttributeTuple(75, "Sigmund Freud"),
            AttributeTuple(70, "EyeCU"),
            AttributeTuple(80, "Expo 86"),
            AttributeTuple(76, "Form"),
            AttributeTuple(86, "Collectors General Warning"),
            AttributeTuple(71, "Slime Magazine"),
            AttributeTuple(88, "S"),
            AttributeTuple(72, "Incomplete"),
            AttributeTuple(81, "Shopp'd"),
            AttributeTuple(66, "Ephemera"),
            AttributeTuple(74, "Animal Pictures"),
            AttributeTuple(85, "Sundaze"),
            AttributeTuple(67, "ScamAbro"),
            AttributeTuple(96, "Simple White Border"),
            AttributeTuple(89, "Maps"),
            AttributeTuple(83, "1977"),
            AttributeTuple(87, "Dissection Kit"),
            AttributeTuple(90, "Photo Album"),
            AttributeTuple(73, "CNSRD"),
            AttributeTuple(69, "CULT"),
            AttributeTuple(82, "Area"),
            AttributeTuple(91, "Baked Beans"),
            AttributeTuple(68, "Masterpiece"),
            AttributeTuple(84, "Half Banner"),
            AttributeTuple(78, "Mushroom Farm"),
            AttributeTuple(77, "Razor Blade"),
            AttributeTuple(255, "Slimesunday 1 of 1")
        ];

        for (uint256 i; i < attributeTuples.length; i++) {
            traitIds.push(attributeTuples[i].traitId);
            attributes.push(
                Attribute(
                    getLayerTypeStr(attributeTuples[i].traitId),
                    attributeTuples[i].name,
                    DisplayType.String
                )
            );
        }
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
            result = "Border";
        } else if (layerType == 5) {
            result = "Texture";
        } else if (layerType == 3 || layerType == 4) {
            result = "Element";
        } else {
            result = "Special";
        }
    }

    function configureImageLayerable() public {
        configureAttributes();
        imageLayerable = new SlimeShopImageLayerable(
            address(this),
            "",
            0,
            0,
            "",
            ""
        );

        imageLayerable.setAttributes(traitIds, attributes);
        imageLayerable.setBaseLayerURI("base");
        imageLayerable.setDefaultURI("default");
    }

    function testThing() public {
        test.mint{value: .2 ether}(1);
        test.setMetadataContract(imageLayerable);
        string memory uri = test.tokenURI(1);
        emit log_string(uri);
    }
}
