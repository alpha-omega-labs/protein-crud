pragma solidity ^0.8.12;
import '../cruds/CrudProtein.sol';
import '../../libraries/Structs.sol';
import './IndexerSeed.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract IndexerProtein is CrudProtein {
  Structs.IndexerStruct public indexer;
  mapping(uint => address) seedAddresses;

  constructor(string memory _indexerGroup, uint _indexerId) {
    setIndexer(_indexerGroup, _indexerId);
  }

  function setIndexer(string memory _indexerGroup, uint _indexerId) public onlyAdmin returns(Structs.IndexerStruct memory) {
    indexer = Structs.IndexerStruct(_indexerGroup, _indexerId);

    return indexer;
  }

  function createSeedLink(address indexerSeedAddress) public onlyAdmin returns(uint seedSize, address seedAddress){
    IndexerSeed indexerSeed = IndexerSeed(indexerSeedAddress);
    seedSize = indexerSeed.seedSize();

    require(seedAddresses[seedSize] == address(0), "Can't insert this seed address for an address with this seedSize has already been added. Try updating instead.");
    seedAddresses[seedSize] = indexerSeedAddress;

    return(seedSize, seedAddress);
  }

  function updateSeedLink(uint _seedSize, address newIndexerSeedAddress) public onlyAdmin {
    IndexerSeed indexerSeed = IndexerSeed(newIndexerSeedAddress);
    require(indexerSeed.seedSize() == _seedSize, "Can't update address at seed size because the seed address' seedSize differs from the given value.");
    require(seedAddresses[_seedSize] != address(0), "No address found at this seed size. Insert this seed address instead.");
    
    seedAddresses[_seedSize] = newIndexerSeedAddress;
  }

  function destroySeedLink(uint _seedSize) public onlyAdmin {
    seedAddresses[_seedSize] = address(0);
  }

  function getSeedLink(uint _seedSize) public view returns(address seedAddress) {
    return seedAddresses[_seedSize];
  }

  function getIndexerInfo() public view returns(string memory indexerGroup, uint indexerId, uint proteinCount) {
    return (indexer.group, indexer.id, getProteinCount());
  }
}