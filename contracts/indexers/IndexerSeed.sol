pragma solidity ^0.8.12;
import '../cruds/CrudSeed.sol';
import '../cruds/CrudWildcard.sol';
import '../../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract IndexerSeed is CrudSeed, CrudWildcard {
  Structs.IndexerStruct public indexer;

  // What is the length for each seed contained in this contract?
  uint public seedSize;

  constructor(string memory _indexerGroup, uint _indexerId, uint _seedSize) {
    setIndexer(_indexerGroup, _indexerId);
    setSeedSize(_seedSize);
  }

  function setIndexer(string memory _indexerGroup, uint _indexerId) public onlyAdmin returns(Structs.IndexerStruct memory) {
    indexer = Structs.IndexerStruct(_indexerGroup, _indexerId);

    return indexer;
  }

  function setSeedSize(uint _seedSize) public onlyAdmin returns(uint) {
    seedSize = _seedSize;
    
    return seedSize;
  }

  function getIndexerInfo() public view returns(string memory indexerGroup, uint indexerId, uint wildcardCount, uint seedCount, uint _seedSize, uint _actualPositionCount, uint _positionCount) {
    return (indexer.group, indexer.id, getWildcardCount(), getSeedCount(), seedSize, actualPositionCount, positionCount);
  }
}