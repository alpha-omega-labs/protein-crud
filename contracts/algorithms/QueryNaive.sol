pragma solidity ^0.8.12;
import '../../libraries/Strings.sol';
import '../../libraries/Structs.sol';
import '../indexers/IndexerProtein.sol';
import './QueryAbstract.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "NAIVE" APPROACH */
// The naive approach of querying. Works okay with smaller datasets, but takes a lot of time when it has to go through a bunch.
// Proteins are queried by going through every single one of them, step-by-step (it checks whether the query is contained using string comparison).
contract QueryNaive is QueryAbstract {
  using Strings for string;

  struct QueryInput {
    string id;
    string sequence;
  }

  struct QueryOptions {
    uint limit;
    bool caseSensitive;
    bool union; //union query, see: https://www.sqlshack.com/sql-union-overview-usage-and-examples/.
  }

  function queryNftIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputNftIds memory result) {
    return naiveAlgorithm(queryInput, queryOptions, indexerProteinAddress);
  }

  function queryProteins(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputProteinStructs memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryProteins(_result, indexerProteinAddress);
  }

  function queryIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIds memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIds(_result, indexerProteinAddress);
  }

  function querySequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputSequences memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _querySequences(_result, indexerProteinAddress);
  }

  function queryIpfsHashes(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIpfsHashes memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIpfsHashes(_result, indexerProteinAddress);
  }

  function naiveAlgorithm(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress) 
  internal view returns(Structs.QueryOutputNftIds memory result) {
    bool idIsEmpty = bytes(queryInput.id).length == 0;
    bool sequenceIsEmpty = bytes(queryInput.sequence).length == 0;

    require(!idIsEmpty || !sequenceIsEmpty, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    uint[] memory _nftIds = new uint[](proteinCount);

    if(!queryOptions.caseSensitive) {
      if(!idIsEmpty) queryInput.id = queryInput.id.toUpper();
      if(!sequenceIsEmpty) queryInput.sequence = queryInput.sequence.toUpper();
    }

    for(uint i = 0; i < proteinCount; i++) {
      Structs.ProteinStruct memory _protein = indexerProtein.getProteinStructAtIndex(i);

      bool idCondition = (!queryOptions.union && idIsEmpty) 
        || (!idIsEmpty && queryInput.id.contains(queryOptions.caseSensitive ? _protein.id : _protein.id.toUpper(), true));
      bool sequenceCondition = (!queryOptions.union && sequenceIsEmpty) 
        || (!sequenceIsEmpty && queryInput.sequence.contains(_protein.sequence, true));

      bool condition = queryOptions.union 
        ? idCondition || sequenceCondition
        : idCondition && sequenceCondition;

      if(condition) {
        _nftIds[result.proteinCount] = _protein.nftId;
        result.proteinCount++;

        if(result.proteinCount == queryOptions.limit) break;
      }
    }

    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = _nftIds[i];
  }
}