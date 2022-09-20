// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SlimeShopImageLayerable} from "./SlimeShopImageLayerable.sol";
import {BitMapUtility} from "bound-layerable/lib/BitMapUtility.sol";

contract SlimeShopBatchOverride is SlimeShopImageLayerable {
  struct PortraitOverride {
    uint16 batchStart;
    uint16 batchEnd;
    uint8 portraitId;
    uint8 replacementId;
  }

  PortraitOverride[] public portraitOverrides;

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

  function addPortraitOverride(
    uint16 batchStart,
    uint16 batchEnd,
    uint8 portraitId,
    uint8 replacementId
  ) external onlyOwner {
    portraitOverrides.push(
      PortraitOverride(batchStart, batchEnd, portraitId, replacementId)
    );
  }

  function replacePortraitOverrides(PortraitOverride[] calldata overrides)
    external
    onlyOwner
  {
    for (uint256 i = 0; i < portraitOverrides.length; ) {
      portraitOverrides.pop();
      unchecked {
        ++i;
      }
    }
    for (uint256 i = 0; i < overrides.length; ++i) {
      portraitOverrides.push(overrides[i]);
    }
  }

  function overrideBindings(
    uint256 originalLayerId,
    uint256 overrideId,
    uint256 bindings
  ) internal pure returns (uint256) {
    uint256 originalComplement = ~BitMapUtility.toBitMap(originalLayerId);
    bindings &= originalComplement;
    bindings |= BitMapUtility.toBitMap(overrideId);
    return bindings;
  }

  function overrideActiveLayers(
    uint256 originalLayerId,
    uint256 overrideId,
    uint256[] memory activeLayers
  ) internal pure returns (uint256[] memory) {
    for (uint256 i = 0; i < activeLayers.length; ++i) {
      if (activeLayers[i] == originalLayerId) {
        activeLayers[i] = overrideId;
        break;
      }
    }
    return activeLayers;
  }

  function getTokenURI(
    uint256 tokenId,
    uint256 layerId,
    uint256 bindings,
    uint256[] calldata activeLayers,
    bytes32 layerSeed
  ) public view override returns (string memory) {
    // calldata hack: bindings and activeLayers have already been updated if self-calling
    if (msg.sender == address(this)) {
      super.getTokenURI(tokenId, layerId, bindings, activeLayers, layerSeed);
    }
    bool isPortrait = tokenId % 7 == 0;
    uint256[] memory newActiveLayers = activeLayers;
    uint256 newBindings = bindings;
    if (isPortrait) {
      for (uint256 i = 0; i < portraitOverrides.length; ++i) {
        PortraitOverride memory override_ = portraitOverrides[i];
        // batches should be sorted so we can break if tokenId is less than the start
        // since if it matched a different batch it would have been caught in a previous iteration
        if (tokenId < override_.batchStart) {
          break;
        } else if (
          layerId == override_.portraitId &&
          tokenId >= override_.batchStart &&
          tokenId < override_.batchEnd
        ) {
          layerId = override_.replacementId;
          // don't process bindings if there are none (ie unbound portrait layer)
          newBindings = bindings > 0
            ? overrideBindings(layerId, override_.replacementId, bindings)
            : bindings;
          // don't process active layers if there are none
          newActiveLayers = activeLayers.length > 0
            ? overrideActiveLayers(
              override_.portraitId,
              override_.replacementId,
              activeLayers
            )
            : activeLayers;
          break;
        }
      }
    }
    // calldata hack: can't pass memory array as calldata unless external call is made
    return
      this.getTokenURI(
        tokenId,
        layerId,
        newBindings,
        newActiveLayers,
        layerSeed
      );
  }
}
