// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ImageLayerable} from "bound-layerable/metadata/ImageLayerable.sol";
import {LibString} from "solady/utils/LibString.sol";

contract SlimeShopImageLayerable is ImageLayerable {
    using LibString for uint256;
    string baseName;

    constructor(
        address _owner,
        string memory _defaultURI,
        uint256 _width,
        uint256 _height,
        string memory _externalLink,
        string memory _description
    ) ImageLayerable(_owner, _defaultURI, _width, _height, _externalLink, _description) {}

    function _getName(uint256 tokenId, uint256) internal pure override returns (string memory) {
        return string.concat("SLIMESHOP #", tokenId.toString());
    }
}
