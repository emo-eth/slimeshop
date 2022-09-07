import * as allowList from '../allowlist/test_allowList.json'
import {MerkleTree} from 'merkletreejs';
import {BigNumber, ethers} from 'ethers'
import { keccak256 } from '@ethersproject/keccak256';
import * as lite from '../allowlist/allowlist_lite.json';

const ALLOWLIST_MINT_PRICE = BigNumber.from('95000000000000000');
const PUBLIC_MINT_PRICE =    BigNumber.from('150000000000000000')
// const RINKEBY_START_TIME = BigNumber.from(1662421847);
const MAINNET_START_TIME = BigNumber.from(1662660000);

const liteLeaves: string[] = lite;
let leaves: ILeaf[] = [];
for (let leaf of liteLeaves) {
    leaves.push({
        address: leaf.toLowerCase(),
        mintPrice: ALLOWLIST_MINT_PRICE,
        maxMintedSetsForWallet: BigNumber.from(5),
        startTime: BigNumber.from(MAINNET_START_TIME)
    })
    leaves.push({
        address: leaf.toLowerCase(),
        mintPrice: PUBLIC_MINT_PRICE,
        maxMintedSetsForWallet: BigNumber.from(10),
        startTime: BigNumber.from(MAINNET_START_TIME)
    })
}

interface ILeaf {
    address: string
    mintPrice: BigNumber
    maxMintedSetsForWallet: BigNumber
    startTime: BigNumber
}
 

function hashLeaf(leaf:ILeaf) {
    // equiv to keccak(abi.encodePacked(address,mintPrice,maxMintedSetsForWallet,startTime))
    return ethers.utils.solidityKeccak256(['address','uint256','uint256','uint256'],
    [leaf.address,leaf.mintPrice,leaf.maxMintedSetsForWallet,leaf.startTime]);
}


const hashedLeaves = leaves.map(hashLeaf)

const merkletree = new MerkleTree(hashedLeaves, keccak256, {
    sort: true,
    sortLeaves: true,
    hashLeaves: false,
  });


function getProof(leaf: ILeaf) {
    return merkletree.getHexProof(hashLeaf(leaf))
}

function getNumberMintedForAddress(address: string): BigNumber {
    return BigNumber.from(5);
    // return contractInstance.call.getNumberMintedForAddress(address)
}
function findBestLeafForAddress(address: string): ILeaf | null {
    const minterNumMinted = getNumberMintedForAddress(address)

    // filter out all inactive leaves
    const activeLeaves: ILeaf[] = leaves.filter((leaf) =>
        // js timestamps are in milliseconds
        leaf.startTime.lt(BigNumber.from(Date.now()).div(1000))
    )
    // lowercase all addresses
    const lowerAddress = address.toLowerCase()
    // filter for the address we are searching for
    const addressLeaves = activeLeaves.filter((leaf) => leaf.address.toLowerCase() === lowerAddress)

    // filter by max num minted quantity
    const eligibleAddressLeaves = addressLeaves.filter(leaf => leaf.maxMintedSetsForWallet.gt(minterNumMinted))

    // if no leaves are found, return null
    if (eligibleAddressLeaves.length === 0) {
        return null
    }

    // find the eligible leaf with the best mint price for the user
    let best: ILeaf | null = null;
    for (let leaf of eligibleAddressLeaves) {
        if (
            best == null ||
            leaf.mintPrice.lt(best.mintPrice)
        ) {
            best = leaf
        }
    }
    return best
}


console.log(merkletree.getHexRoot());

const allowListLeaf = findBestLeafForAddress(
    "0x124aefa2fa991c62c3a137369fa8cd076de27b80".toLowerCase()
  );
let proof;
if (allowListLeaf != null) {
proof = getProof(allowListLeaf);
}
console.log(proof);
console.log(allowListLeaf);

