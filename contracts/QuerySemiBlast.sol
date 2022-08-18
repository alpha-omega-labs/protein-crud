pragma solidity ^0.8.12;
import '../libraries/Strings.sol';
import '../libraries/Structs.sol';
import './IndexerProtein.sol';
import './IndexerSeed.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "SEMI-BLAST" APPROACH */
// Inspired by the first couple steps of the Blast algorithm; leaning mostly on the lookup table.
// Rather than having 'probable' outcomes using scoring matrices and E-values we search for 'exact' matches.
contract QuerySemiBlast {
  using Strings for string;
  string[20] aminoAcids;

  struct QueryInput {
    string sequence; //sequences only for now
  }

  struct QueryOptions {
    uint seedSize;
    uint limit;
    bool caseSensitive;
  }

  struct PuzzleData {
    Structs.SeedPositionStruct[][] positions;
    uint proteinCount;
    uint seedSize;
    uint seedTailOverlap;
  }

  constructor() {
    aminoAcids = [
      "A", "R", "N", "D", 
      "C", "Q", "E", "G", 
      "H", "I", "L", "K", 
      "M", "F", "P", "S", 
      "T", "W", "Y", "V"];
  }

  function queryProteins(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputProteinStructs memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.proteins = IndexerProtein(indexerProteinAddress).getManyProteinStructs(_result.nftIds);
  }

  function queryNftIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputNftIds memory result) {
    return semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
  }

  function querySequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputSequences memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.sequences = IndexerProtein(indexerProteinAddress).getManyProteinSequences(_result.nftIds);
  }

  function queryIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIds memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.ids = IndexerProtein(indexerProteinAddress).getManyProteinIds(_result.nftIds);
  }

  function queryIpfsHashes(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIpfsHashes memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.ipfsHashes = IndexerProtein(indexerProteinAddress).getManyProteinIpfsHashes(_result.nftIds);
  }
  
  function semiBlastAlgorithm(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputNftIds memory result) {
    uint wordSize = bytes(queryInput.sequence).length;
    require(wordSize != 0, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    address indexerSeedAddress = indexerProtein.getSeedAddress(queryOptions.seedSize);
    require(indexerSeedAddress != address(0), "Can't query with this seed size.");

    IndexerSeed indexerSeed = IndexerSeed(indexerSeedAddress);
    require(indexerSeed.getSeedCount() > 0, "In order to query in this manner, seeds have to be inserted first.");
    
    if(!queryOptions.caseSensitive) queryInput.sequence = queryInput.sequence.toUpper();

    // TODO: If a query is smaller than the seedSize.
    if(wordSize < queryOptions.seedSize) {
      // _result = querySmallWords(sequenceQuery, proteinCount);
      return result;
    }

    // Split the query in short w-sized pieces.
    (string[] memory splittedQuery, uint seedTailSize) = queryInput.sequence.fragment(queryOptions.seedSize, queryOptions.seedSize, true);

    // Look where these w-sized pieces could be found in all of our sequences (using a precomputed lookup table, see: CrudSeed.sol or ./datasets/seeds/ on our GitHub.)
    (Structs.SeedPositionStruct[][] memory positions, bool emptyFound) = indexerSeed.getManySeedPositions(splittedQuery, true);

    // Puzzle the w-sized pieces back together and return only the proteins that successfully match our queried string (in this case the NFT IDs).
    if(!emptyFound) result = puzzleSeedPositions(PuzzleData(positions, proteinCount, queryOptions.seedSize, queryOptions.seedSize - seedTailSize), queryOptions.limit);
  }

  // Puzzling the puzzle pieces together. This is the final step of the "SEMI-BLAST" algorithm.
  function puzzleSeedPositions(PuzzleData memory puzzleData, uint limit)
  internal pure returns(Structs.QueryOutputNftIds memory result) {
    uint maxQueryAmount = puzzleData.positions[0].length;

    uint[] memory _nftIds = new uint[](maxQueryAmount);
    Structs.SeedPositionStruct[] memory possibleMatches = new Structs.SeedPositionStruct[](maxQueryAmount);
    
    possibleMatches = puzzleData.positions[0];

    int[] memory mismatchCounter = new int[](maxQueryAmount);
    bool[] memory addedProteins = new bool[](puzzleData.proteinCount);

    for (uint i = 0; i < maxQueryAmount; i++) {
      uint nftId = possibleMatches[i].nftId;

      // If the protein doesn't exist or has already been added, it's not necessary to include it in our calculations.
      if(nftId > addedProteins.length || addedProteins[nftId - 1]) continue; 

      for(uint j = 1; j < puzzleData.positions.length; j++) {
        for(uint k = 0; k < puzzleData.positions[j].length; k++) {
          Structs.SeedPositionStruct memory currentSeedPosition = puzzleData.positions[j][k];

          // Again, if the protein doesn't exist or was already added, skip.
          if(currentSeedPosition.nftId > addedProteins.length || addedProteins[currentSeedPosition.nftId - 1]) {
            // Also, treat this round as a mismatch.
            mismatchCounter[i]++;   
            continue;
          }

          // if nftId's match AND (previous position + seedSize) equals the current position, then we have a match.
          // However, there's an exception to this rule at the last seed, for this word may overlap with the second last word.
          // See fragment() in the Strings.sol library for more information. Particularly the 'forceSize' parameter.
          if(nftId == currentSeedPosition.nftId && 
          currentSeedPosition.position == (possibleMatches[i].position + puzzleData.seedSize - 
          (j == puzzleData.positions.length - 1 ? puzzleData.seedTailOverlap : 0))) {
            possibleMatches[i].position = puzzleData.positions[j][k].position;
            mismatchCounter[i] = -1;
            break;
          } else {
            mismatchCounter[i]++;
          }
        }

        // -1 means we found a match, anything higher indicates that we've only encountered mismatches
        if(mismatchCounter[i] > 0) break; 
        
        // Reset the counter (only happens if this round matched)
        mismatchCounter[i] = 0;
      }

      if(mismatchCounter[i] > 0) continue;

      // If we made it this far, it means a match was found
      _nftIds[result.proteinCount] = nftId;
      result.proteinCount++;
      addedProteins[nftId - 1] = true;

      // Stop looking for more if we found enough matching proteins.
      if(result.proteinCount == limit) break;
    }

    // Shrink the size of the resulting array
    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = _nftIds[i];
  }
  
    // function querySmallWords(string memory smallQuery, uint proteinCount) internal view returns(Structs.ProteinStruct[] memory proteins, uint proteinsFound) {
  //   require(bytes(smallQuery).length < seedSize, "The query must be smaller than the seed size for this to work.");

  //   uint seedDifference = seedSize - bytes(smallQuery).length;

  //   uint aminoCount = aminoAcids.length**seedDifference;
  //   uint firstAminoNumber = aminoStartNumber(seedDifference);
    
  //   Structs.SeedPositionStruct[][] memory positions = new Structs.SeedPositionStruct[][](aminoCount * 2);
  //   uint positionsPointer;

  //   Structs.ProteinStruct[] memory _proteins = new Structs.ProteinStruct[](proteinCount);
  //   bool[] memory addedProteins = new bool[](proteinCount);

  //   for(uint i = firstAminoNumber; i < aminoCount + firstAminoNumber; i++) {
  //     string memory seed;
  //     string memory amino = numberToAmino(i);

  //     seed = string.concat(amino, smallQuery);
  //     positions[positionsPointer] = getSeedPositions(seed);
  //     positionsPointer++;

  //     seed = string.concat(smallQuery, amino);
  //     positions[positionsPointer] = getSeedPositions(seed);
  //     positionsPointer++;

  //     for (uint j = positionsPointer - 2; j < positionsPointer; j++) {
  //       for(uint k = 0; k < positions[j].length; k++) {
  //         uint nftId = positions[j][k].nftId;
  //         if (addedProteins[nftId - 1]) continue;

  //         _proteins[proteinsFound] = proteinStructs[nftId];
  //         proteinsFound++;

  //         addedProteins[nftId - 1] = true;
  //       }
  //     }
  //   }

  //   proteins =  _proteins.resizeArray(proteins, proteinsFound);
  // }

  // function numberToAmino(uint number) public view returns(string memory amino) {
  //   while (number > 0) {
  //     uint t = (number - 1) % aminoAcids.length;
  //     amino = string.concat(aminoAcids[t], amino);
  //     number = (number - t) / aminoAcids.length;
  //   }
  // }

  // function aminoStartNumber(uint wordSize) internal view returns(uint start) {
  //   while(wordSize != 0) {
  //     wordSize--;
  //     start = start + (aminoAcids.length**wordSize);
  //   }
  // }
}