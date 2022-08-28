pragma solidity ^0.8.12;
import '../../libraries/Strings.sol';
import '../../libraries/Structs.sol';
import '../indexers/IndexerProtein.sol';
import '../indexers/IndexerSeed.sol';
import './QueryAbstract.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "SEMI-BLAST" APPROACH */
// Inspired by the first couple steps of the Blast algorithm; leaning mostly on the lookup table.
// Rather than having 'probable' outcomes using scoring matrices and E-values we search for 'exact' matches.
contract QuerySemiBlast is QueryAbstract {
  using Strings for string;
  using Strings for bytes1;
  using Structs for Structs.SeedPositionStruct[][];

  struct QueryInput {
    string sequence;
  }

  struct QueryOptions {
    uint seedSize;
    uint limit;
    bool caseSensitive;
  }

  struct PuzzleData {
    Structs.SeedPositionStruct[][] positions;
    uint[] pointers;
    uint proteinCount;
    uint seedSize;
    uint seedTailOverlap;
    uint limit;
  }

  function queryNftIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputNftIds memory result) {
    return semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
  }

  function queryProteins(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputProteinStructs memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryProteins(_result, indexerProteinAddress);
  }

  function querySequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputSequences memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _querySequences(_result, indexerProteinAddress);
  }

  function queryIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIds memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIds(_result, indexerProteinAddress);
  }

  function queryIpfsHashes(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIpfsHashes memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIpfsHashes(_result, indexerProteinAddress);
  }
  
  function semiBlastAlgorithm(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputNftIds memory result) {
    uint wordSize = bytes(queryInput.sequence).length;
    require(wordSize != 0, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    address indexerSeedAddress = indexerProtein.getSeedLink(queryOptions.seedSize);
    require(indexerSeedAddress != address(0), "Can't query with this seed size.");

    IndexerSeed indexerSeed = IndexerSeed(indexerSeedAddress);
    require(indexerSeed.getSeedCount() > 0, "In order to query in this manner, seeds have to be inserted first.");
    
    if(!queryOptions.caseSensitive) queryInput.sequence = queryInput.sequence.toUpper();

    Structs.QueryOutputPositions memory queryOutputPositions;
    string[] memory splittedQuery;
    uint[] memory pointers;
    uint seedTailSize;

    // Queries that are possible to separate in short seeds
    if(wordSize >= queryOptions.seedSize) {
      // Split the query in short w-sized pieces. (e.g. AAASREIIE => [AAA, SRE, IIE])
      (splittedQuery, seedTailSize) = queryInput.sequence.fragment(queryOptions.seedSize, queryOptions.seedSize, true);

      // Look where these w-sized pieces could be found in all of our sequences (using a precomputed lookup table, see: CrudSeed.sol or ./datasets/seeds/ on our GitHub.)
      // This will return data about all positions found, plus an array of pointers telling the position for every seed (e.g. [AAA, SRE, IIE] => [0, 1, 2]).
      (queryOutputPositions, pointers) = getSeedPositions(splittedQuery, indexerSeed);

      // Sort the w-sized pieces in an ascending order (based on the amount of positions each seed holds; e.g. positions: [SRE, IIE, AAA] => pointers: [1, 2, 0])
      (queryOutputPositions.positions, pointers) = queryOutputPositions.positions.sort(pointers);
    } else {
      // Create wildcards from the short query (e.g. SR => [*SR, SR*] or S => [**S, S**]). We always need to create a heads and tails variant of the query (the two edge cases).
      Structs.WildcardStruct[2] memory wildcards = createWildcards(queryInput.sequence, queryOptions.seedSize, indexerSeed);

      // The search for positions is slightly different for short queries (namely: all positions found are valid, so heap them all together in one giant list).
      queryOutputPositions = getWildcardPositions(wildcards, proteinCount, indexerSeed);
      
      // There is only one pointer in a short query, namely: [0].
      pointers = new uint[](1);
    }

    // if returnAll is true, which only happens if only *'s were found, we return all proteins.
    if(queryOutputPositions.returnAll) return Structs.QueryOutputNftIds(indexerProtein.getProteinIndex(), proteinCount);

    // Puzzle the w-sized pieces back together and return only the NFT IDs that successfully match our queried string.
    if(!queryOutputPositions.emptyFound) result = puzzleSeedPositions(
      PuzzleData(
        queryOutputPositions.positions,
        pointers,
        proteinCount, 
        queryOptions.seedSize, 
        queryOptions.seedSize - seedTailSize, 
        queryOptions.limit
      )
    );
  }

  // The first step of the semi-blast algorithm for short queries.
  function createWildcards(string memory shortQuery, uint _seedSize, IndexerSeed indexerSeed)
  internal view returns(Structs.WildcardStruct[2] memory _wildcardStructs){
    string memory wildcardPart = bytes1("*").repeatChar(_seedSize - bytes(shortQuery).length);
    string memory wildcardHead = string.concat(shortQuery, wildcardPart);
    string memory wildcardTail = string.concat(wildcardPart, shortQuery);

    return [indexerSeed.getWildcardStruct(wildcardHead), indexerSeed.getWildcardStruct(wildcardTail)];
  }

  // Get all the positions for every short w-sized seed we generated from the fragment() function. This is the second step of the "SEMI-BLAST" algorithm.
  function getSeedPositions(string[] memory seeds, IndexerSeed indexerSeed)
  internal view returns (Structs.QueryOutputPositions memory queryOutputPositions, uint[] memory pointers) {
    queryOutputPositions.positions = new Structs.SeedPositionStruct[][](seeds.length);
    pointers = new uint[](seeds.length);
    queryOutputPositions.returnAll = true;

    Structs.SeedPositionStruct[] memory _positions;
    
    for(uint i = 0; i < seeds.length; i++) {
      if(indexerSeed.isWildcard(seeds[i])) {
        Structs.WildcardStruct memory wildcardStruct = indexerSeed.getWildcardStruct(seeds[i]);
        _positions = new Structs.SeedPositionStruct[](wildcardStruct.count);

        uint wildcardPointer = 0;
        for (uint j = 0; j < wildcardStruct.seeds.length; j++) {
          // Not sure if this line will become problematic (it's an external function call inside a loop)
          Structs.SeedPositionStruct[] memory _wildcardPositions = indexerSeed.getSeedPositions(wildcardStruct.seeds[j]);

          for (uint k = 0; k < _wildcardPositions.length; k++) {
            _positions[wildcardPointer] = _wildcardPositions[k];
            wildcardPointer++;
          }
        }

        queryOutputPositions.returnAll = queryOutputPositions.returnAll && _positions.length == 0;
      } else {
        // This one is not so problematic as it only depends on the length of the queried word (the amount of seeds, e.g. [SRE, IIE, AAA] would translate to only 3 calls).
        _positions = indexerSeed.getSeedPositions(seeds[i]);
        queryOutputPositions.returnAll = false;

        if(_positions.length == 0) {
          queryOutputPositions.emptyFound = true;
          break;
        }
      }

      pointers[i] = i;
      queryOutputPositions.positions[i] = _positions;
    }
  }

  // Second step for semi-blast's short query variant.
  function getWildcardPositions(Structs.WildcardStruct[2] memory wildcards, uint _proteinCount, IndexerSeed indexerSeed)
  internal view returns (Structs.QueryOutputPositions memory queryOutputPositions) {
    if(!indexerSeed.isWildcard(wildcards[0].wildcard) 
    && !indexerSeed.isWildcard(wildcards[1].wildcard)) {
      queryOutputPositions.emptyFound = true;
      queryOutputPositions.returnAll = false;
      return queryOutputPositions;
    }

    queryOutputPositions.positions = new Structs.SeedPositionStruct[][](1);
    Structs.SeedPositionStruct[] memory _positions = new Structs.SeedPositionStruct[](wildcards[0].count + wildcards[1].count);
    bool[] memory addedProteins = new bool[](_proteinCount);

    uint wildcardPointer = 0;
    for (uint i = 0; i < wildcards.length; i++) {
      for (uint j = 0; j < wildcards[i].seeds.length; j++) {
        // Similar as before, I'm uncertain if an external function call inside a loop could eventually become a problem.
        Structs.SeedPositionStruct[] memory wildcardPositions = indexerSeed.getSeedPositions(wildcards[i].seeds[j]);

        for (uint k = 0; k < wildcardPositions.length; k++) {
          if(!addedProteins[wildcardPositions[k].nftId - 1]) {
            _positions[wildcardPointer] = wildcardPositions[k];
            wildcardPointer++;

            addedProteins[wildcardPositions[k].nftId - 1] = true;
          }
        }
      }
    }

    queryOutputPositions.emptyFound = false;
    queryOutputPositions.returnAll = _positions.length == 0;
    queryOutputPositions.positions[0] = new Structs.SeedPositionStruct[](wildcardPointer);

    // Copy the positions we found to a smaller-sized array
    for(uint i = 0; i < wildcardPointer; i++) queryOutputPositions.positions[0][i] = _positions[i];

    return queryOutputPositions;
  }

  // Third step: puzzling the pieces together. This is the biggest and final step of the "SEMI-BLAST" algorithm.
  function puzzleSeedPositions(PuzzleData memory puzzleData)
  internal pure returns(Structs.QueryOutputNftIds memory result) {
    // This makes sure that we are not taking *** as our reference point
    uint validPosition = getValidPositionIndex(puzzleData);

    // Limit our amount of queries to the smallest set
    uint maxQueryAmount = puzzleData.positions[validPosition].length;

    // These are all our candidates (potential matches)
    Structs.SeedPositionStruct[] memory candidates = puzzleData.positions[validPosition];

    // Our list of matches (NFT ID's)
    uint[] memory matches = new uint[](maxQueryAmount);
    
    // Our list of mismatches (the index equals the index of the candidate and the value is a counter).
    int[] memory mismatches = new int[](maxQueryAmount);

    // Keeps track of which proteins we've already added (index + 1 = NFT ID).
    bool[] memory addedProteins = new bool[](puzzleData.proteinCount);

    for (uint i = 0; i < maxQueryAmount; i++) {
      // If the protein doesn't exist or has already been added, it's not necessary to include it in our calculations.
      if(candidates[i].nftId > addedProteins.length || addedProteins[candidates[i].nftId - 1]) continue; 

      // If there were ***'s (validPosition > 0) and we're the only seed in the query.
      if(validPosition > 0 && validPosition == puzzleData.positions.length - 1) {
        // If the current position is smaller than the minimum expected value then skip.
        if(validPosition != 0 && candidates[i].position < getMinimumPosition(
          puzzleData,
          puzzleData.pointers[validPosition],
          puzzleData.pointers[validPosition])) continue;
      }

      for(uint j = validPosition + 1; j < puzzleData.positions.length; j++) {
        //empty arrays are "***"-wildcards, skip these.
        if(puzzleData.positions[j].length == 0) continue;

        for(uint k = 0; k < puzzleData.positions[j].length; k++) {
          Structs.SeedPositionStruct memory currentSeedPosition = puzzleData.positions[j][k];

          // Again, if the protein doesn't exist or was already added, skip.
          if(currentSeedPosition.nftId > addedProteins.length || addedProteins[currentSeedPosition.nftId - 1]) {
            // Also, treat this round as a mismatch.
            mismatches[i]++;   
            continue;
          }
          
          // Again, if the current position is smaller than the minimum expected value then skip.
          if(currentSeedPosition.position < getMinimumPosition(
            puzzleData, 
            puzzleData.pointers[validPosition],
            puzzleData.pointers[j])) {
            // Also, treat this round as a mismatch.
            mismatches[i]++;   
            continue;
          }

          // if NFT IDs match AND expected position equals the current position, then we have a match.
          if(candidates[i].nftId == currentSeedPosition.nftId && int(currentSeedPosition.position) == 
          int(candidates[i].position) + getPositionOffset(puzzleData.pointers[validPosition], puzzleData.pointers[j], puzzleData)) {
            mismatches[i] = -1;
            break;
          } else {
            mismatches[i]++;
          }
        }

        // -1 means we found a match, anything higher indicates that we've only encountered mismatches
        if(mismatches[i] > 0) break;
        
        // Reset the mismatch-counter
        mismatches[i] = 0;
      }

      if(mismatches[i] > 0) continue;

      // If we made it this far, it means a match was found
      matches[result.proteinCount] = candidates[i].nftId;
      addedProteins[candidates[i].nftId - 1] = true;
      result.proteinCount++;

      // Stop looking for more if we found enough matching proteins.
      if(result.proteinCount == puzzleData.limit) break;
    }

    // Shrink the size of the resulting array
    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = matches[i];
  }

  // Helper function for puzzleSeedPositions; this makes sure that we are not taking *** as our reference point.
  function getValidPositionIndex(PuzzleData memory puzzleData)
  internal pure returns(uint validIndex) {
    for(uint i = 0; i < puzzleData.positions.length; i++) {
      if(puzzleData.positions[i].length > 0) {
        validIndex = i;
        break;
      }
    }
  }

  // Helper function for puzzleSeedPositions; this will tell us what the minimum expected value for the current position is.
  function getMinimumPosition(PuzzleData memory puzzleData, uint refPointer, uint currentPointer)
  internal pure returns(uint minimumPosition) {
    bool isFirst = currentPointer == 0;
    bool oneIsLast = refPointer == puzzleData.positions.length - 1 || currentPointer == puzzleData.positions.length - 1;
    
    return currentPointer * puzzleData.seedSize - (!isFirst && oneIsLast ? puzzleData.seedTailOverlap : 0);
  }
  
  // Helper function for puzzleSeedPositions; this calculates the distance between the previous and the next position.
  function getPositionOffset(uint startPointer, uint currentPointer, PuzzleData memory puzzleData)
  internal pure returns(int positionOffset) {
    bool oneIsLast = startPointer == puzzleData.pointers.length - 1 || currentPointer == puzzleData.pointers.length - 1;
    int pointerDiff = int(currentPointer) - int(startPointer);
    
    // The last 3 letter word may overlap with the second last word, so we have to take this into consideration.
    // See fragment() in the Strings.sol library for more information. Particularly the 'forceSize' parameter.
    int seedTailOverlap = pointerDiff > 0 ? -1 * int(puzzleData.seedTailOverlap) : int(puzzleData.seedTailOverlap);
    
    positionOffset = pointerDiff * int(puzzleData.seedSize) + (oneIsLast ? seedTailOverlap : int(0));
    
    return positionOffset;
  }
}