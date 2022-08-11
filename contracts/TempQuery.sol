pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

import './CrudProtein.sol';
import './CrudSeed.sol';

contract TempQuery is CrudProtein, CrudSeed {
  using Strings for string;
  using Structs for Structs.ProteinStruct[];

  string[20] aminoAcids;
  uint constant public seedSize = 3;
  uint constant public seedStep = 3;

  constructor() {
    aminoAcids = [
        "A", "R", "N", "D", 
        "C", "Q", "E", "G", 
        "H", "I", "L", "K", 
        "M", "F", "P", "S", 
        "T", "W", "Y", "V"];
  }

  /* QUERYING (NAIVE APPROACH) */

  // The naive approach of querying. Works okay with smaller datasets, but takes a lot of time when it has to go through a bunch of sequences.
  // Proteins are queried by going through every single one of them, step-by-step (it checks whether the query is contained in the protein's sequence).
  function naiveQuery(string memory idQuery, string memory sequenceQuery, bool exclusive) public view returns(Structs.ProteinStruct[] memory proteins, uint proteinsFound) {
      //We'll create a temporary array with a length equal to all proteins stored in our database.
      Structs.ProteinStruct[] memory _proteins = new Structs.ProteinStruct[](proteinIndex.length);
      Structs.ProteinStruct memory _protein;

      bool idIsEmpty = bytes(idQuery).length == 0;
      bool sequenceIsEmpty = bytes(sequenceQuery).length == 0;

      for(uint i = 0; i < proteinIndex.length; i++) {
        _protein = proteinStructs[proteinIndex[i]];
        bool includeId = !idIsEmpty && idQuery.contains(_protein.id);
        bool includeSequence = !sequenceIsEmpty && sequenceQuery.contains(_protein.sequence);
      
        bool condition = !exclusive
            ? includeId || includeSequence
            : includeId && includeSequence;

        if(condition) {
            _proteins[proteinsFound] = _protein;
            proteinsFound++;
        }
      }

    // The problem with Solidity is that memory array's have a fixed size. So we can't work with dynamic arrays (unless we use storage, but this costs gas).
    // So after we discover how many proteins were found, we resize the returned array to the appropriate size.
    proteins = _proteins.resizeArray(proteins, proteinsFound);

    // The resizing is an extra step and impacts our query's performance, therefore, use the commented out section instead, if you'd like to speed things up.
    // Just know that you'll have to process the result in the front-end accordingly (filtering out all empty indices).
    // proteins = _proteins;
  }

  /* SEMI-BLAST */
  // Inspired by the first couple steps of the Blast algorithm, but leans mostly on the lookup table, 
  // rather than having probable outcomes using scoring matrices and E-values.
  
  // Basic principal for this algorithm:
  // 1. Split the query in short w-sized pieces.
  // 2. Look where these w-sized pieces could be found in all of our sequences (using a precomputed lookup table, see: SeedCrud.sol or ./datasets/seeds/ on our GitHub.)
  // 3. Puzzle the w-sized pieces back together and return only the proteins that successfully match our queried string.
  // TODO: Add the querying of id's and exclusive queries.
  function semiBlastQuery(string memory sequenceQuery) public view returns(Structs.ProteinStruct[] memory proteins, uint proteinsFound) {
    uint wordSize = bytes(sequenceQuery).length;
    require(wordSize != 0, "Query can't be empty.");
    require(seedIndex.length > 0, "In order to query in this manner, seeds have to be inserted first.");
    
    if(wordSize < seedSize) {
      (proteins, proteinsFound) = querySmallWords(sequenceQuery);
    } else {
      (string[] memory splittedQuery, uint seedTailSize) = sequenceQuery.fragment(seedSize, seedStep, true);
      (Structs.SeedPositionStruct[][] memory positions, bool emptyFound) = getManySeedPositions(splittedQuery, true);
      
      if(!emptyFound) 
        (proteins, proteinsFound) = puzzleSeedPositions(positions, seedSize - seedTailSize);
    }

    return (proteins, proteinsFound);
  }

  function querySmallWords(string memory smallQuery) internal view returns(Structs.ProteinStruct[] memory proteins, uint proteinsFound) {
    require(bytes(smallQuery).length < seedSize, "The query must be smaller than the seed size for this to work.");

    uint seedDifference = seedSize - bytes(smallQuery).length;

    uint aminoCount = aminoAcids.length**seedDifference;
    uint firstAminoNumber = aminoStartNumber(seedDifference);
    
    Structs.SeedPositionStruct[][] memory positions = new Structs.SeedPositionStruct[][](aminoCount * 2);
    uint positionsPointer;

    Structs.ProteinStruct[] memory _proteins = new Structs.ProteinStruct[](proteinIndex.length);
    bool[] memory addedProteins = new bool[](proteinIndex.length);

    for(uint i = firstAminoNumber; i < aminoCount + firstAminoNumber; i++) {
      string memory seed;
      string memory amino = numberToAmino(i);

      seed = string.concat(amino, smallQuery);
      positions[positionsPointer] = getSeedPositions(seed);
      positionsPointer++;

      seed = string.concat(smallQuery, amino);
      positions[positionsPointer] = getSeedPositions(seed);
      positionsPointer++;

      for (uint j = positionsPointer - 2; j < positionsPointer; j++) {
        for(uint k = 0; k < positions[j].length; k++) {
          uint nftId = positions[j][k].nftId;
          if (addedProteins[nftId - 1]) continue;

          _proteins[proteinsFound] = proteinStructs[nftId];
          proteinsFound++;

          addedProteins[nftId - 1] = true;
        }
      }
    }

    proteins =  _proteins.resizeArray(proteins, proteinsFound);
  }

  function puzzleSeedPositions(Structs.SeedPositionStruct[][] memory positions, uint seedTailOverlap) 
  internal view returns(Structs.ProteinStruct[] memory proteins, uint proteinsFound) {
    uint maxQueryAmount = positions[0].length;

    Structs.ProteinStruct[] memory _proteins = new Structs.ProteinStruct[](maxQueryAmount);
    Structs.SeedPositionStruct[] memory possibleMatches = new Structs.SeedPositionStruct[](maxQueryAmount);
    
    possibleMatches = positions[0];

    int[] memory mismatchCounter = new int[](maxQueryAmount); // init value: 0, match: -1, mismatch: > 0
    bool[] memory addedProteins = new bool[](proteinIndex.length);

    for (uint i = 0; i < maxQueryAmount; i++) {
      uint nftId = possibleMatches[i].nftId;
      uint nftIndex = nftId - 1;

      // If the protein has already been added, it's not necessary to include it in our calculations
      if(addedProteins[nftIndex]) continue; 

      for(uint j = 1; j < positions.length; j++) {
        for(uint k = 0; k < positions[j].length; k++) {
          Structs.SeedPositionStruct memory currentSeedPosition = positions[j][k];

          // Again, if the protein was already added, skip.
          // Also treat this round as a mismatch.
          if(addedProteins[currentSeedPosition.nftId - 1]) {
            mismatchCounter[i]++;   
            continue;
          } 

          // if nftId's match AND (previous position + seedStep) equals the current position, then we have a match.
          // However, there's an exception to this rule at the last seed, for this word may overlap with the second last word.
          // See splitWord in QueryHelpers.sol for more information. Particularly the 'forceSize' parameter.
          if(nftId == currentSeedPosition.nftId && 
          currentSeedPosition.position == (possibleMatches[i].position + seedStep - 
          (j == positions.length - 1 ? seedTailOverlap : 0))) {
            possibleMatches[i].position = positions[j][k].position;
            mismatchCounter[i] = -1;
            break;
          } else {
            mismatchCounter[i]++;
          }
        }

        //-1 means we found a match, anything higher indicates that we've only encountered mismatches
        if(mismatchCounter[i] > 0) break; 
        
        //Reset the counter (only happens if this round matched)
        mismatchCounter[i] = 0;
      }

      if(mismatchCounter[i] > 0) continue;

      //If we made it this far, it means a match was found
      _proteins[proteinsFound] = proteinStructs[nftId];
      proteinsFound++;

      addedProteins[nftIndex] = true;
    }

    proteins =  _proteins.resizeArray(proteins, proteinsFound);
  }

  function numberToAmino(uint number) public view returns(string memory amino) {
    while (number > 0) {
      uint t = (number - 1) % aminoAcids.length;
      amino = string.concat(aminoAcids[t], amino);
      number = (number - t) / aminoAcids.length;
    }
  }

  function aminoStartNumber(uint wordSize) internal view returns(uint start) {
    while(wordSize != 0) {
      wordSize--;
      start = start + (aminoAcids.length**wordSize);
    }
  }
}
