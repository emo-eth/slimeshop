// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ImageLayerable} from "bound-layerable/metadata/ImageLayerable.sol";

import {LibString} from "solady/utils/LibString.sol";
import {InvalidInitialization} from "bound-layerable/interface/Errors.sol";

contract SlimeShopImageLayerable is ImageLayerable {
    string baseName;

    constructor(
        address _owner,
        string memory _defaultURI,
        uint256 _width,
        uint256 _height,
        string memory _externalLink,
        string memory _description,
        string memory _baseName
    ) ImageLayerable(_owner, _defaultURI, _width, _height, _externalLink, _description) {
        _initialize(_baseName);
    }

    function initialize(
        address _owner,
        string memory _defaultURI,
        uint256 _width,
        uint256 _height,
        string memory _externalLink,
        string memory _description,
        string memory _baseName
    ) public virtual {
        super._initialize(_owner);
        super._initialize(_defaultURI, _width, _height, _externalLink, _description);
        _initialize(_baseName);
    }

    function _initialize(string memory _baseName) internal virtual {
        if (address(this).code.length > 0) {
            revert InvalidInitialization();
        }
        baseName = _baseName;
    }
}
