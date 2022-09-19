// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ImageLayerable} from "bound-layerable/metadata/ImageLayerable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Attribute} from "bound-layerable/interface/Structs.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract SlimeShopImageLayerable is ImageLayerable {
  using LibString for uint256;
  string baseName;
  error URIQueryForNonexistentToken();

  constructor(
    address _owner,
    string memory _defaultURI,
    uint256 _width,
    uint256 _height,
    string memory _externalLink,
    string memory _description
  )
    ImageLayerable(
      _owner,
      _defaultURI,
      _width,
      _height,
      _externalLink,
      _description
    )
  {}

  function _getName(
    uint256 tokenId,
    uint256 layerId,
    uint256 bindings
  ) internal view override returns (string memory) {
    uint256 adjustedTokenId = tokenId + 1;
    if (layerId == 0 || bindings != 0) {
      return string.concat("SLIMESHOP - #", adjustedTokenId.toString());
    }
    Attribute memory layerAttribute = traitAttributes[layerId];
    return
      string.concat(
        "SLIMESHOP - ",
        layerAttribute.value,
        " - #",
        adjustedTokenId.toString()
      );
  }

  /**
   * @notice get the complete URI of a set of token traits, encoded as a data-uri
   * @param layerId the layerId of the base token
   * @param bindings the bitmap of bound traits
   * @param activeLayers packed array of active layerIds as bytes
   * @param layerSeed the random seed for random generation of traits, used to determine if layers have been revealed
   * @return the complete data URI of the token, including image and all attributes
   */
  function getTokenURI(
    uint256 tokenId,
    uint256 layerId,
    uint256 bindings,
    uint256[] calldata activeLayers,
    bytes32 layerSeed
  ) public view virtual override returns (string memory) {
    ERC721 token = ERC721(0x3ae7FA3Ea5635B3b727C042FECfA9b818B9d8ea3);
    try token.ownerOf(tokenId) returns (address) {} catch {
      revert URIQueryForNonexistentToken();
    }
    return
      super.getTokenURI(tokenId, layerId, bindings, activeLayers, layerSeed);
  }
}
