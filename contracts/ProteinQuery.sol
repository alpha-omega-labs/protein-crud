pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

import './ProteinCrud.sol';
import './SeedCrud.sol';

import "../node_modules/hardhat/console.sol";


contract ProteinQuery is ProteinCrud, SeedCrud {
  
  /* QUERYING (NAIVE APPROACH) */

  // The naive approach of querying. Works okay with smaller datasets, but takes a lot of time when it has to go through a bunch of sequences.
  // Proteins are queried by going through every single one of them, step-by-step (it checks whether the query is contained in the protein's sequence).
  function naiveQuery(string memory idQuery, string memory sequenceQuery, bool exclusive) public view returns(ProteinStruct[] memory proteins, uint proteinsFound) {
      //We'll create a temporary array with a length equal to all proteins stored in our database.
      ProteinStruct[] memory _proteins = new ProteinStruct[](proteinIndex.length);
      ProteinStruct memory _protein;

      bool idIsEmpty = bytes(idQuery).length == 0;
      bool sequenceIsEmpty = bytes(sequenceQuery).length == 0;

      for(uint i = 0; i < proteinIndex.length; i++) {
        _protein = proteinStructs[proteinIndex[i]];
        bool includeId = !idIsEmpty && containsWord(idQuery, _protein.id);
        bool includeSequence = !sequenceIsEmpty && containsWord(sequenceQuery, _protein.sequence);
      
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
    proteins = resizeProteinStructArray(_proteins, proteins, proteinsFound);

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
  // TODO: handle queries shorter than the seed size
  // TODO: Add the querying of id's.
  function semiBlastQuery(string memory sequenceQuery) public view returns(ProteinStruct[] memory proteins, uint proteinsFound) {
    require(seedIndex.length > 0, "In order to query in this manner, seeds have to be inserted first.");
    
    if(bytes(sequenceQuery).length < seedSize) {
      //when the queried sequence is shorter than the seedSize
    } else {
      (string[] memory splittedQuery, uint seedTailSize) = splitWord(sequenceQuery, seedSize, seedStep, true);
      SeedPositionStruct[][] memory positions = getAllSeedPositions(splittedQuery);
      (proteins, proteinsFound) = puzzleSeedPositions(positions, seedSize - seedTailSize);
    }

    return (proteins, proteinsFound);
  }

  function puzzleSeedPositions(SeedPositionStruct[][] memory positions, uint seedTailOverlap) 
  internal view returns(ProteinStruct[] memory proteins, uint proteinsFound) {
    uint maxQueryAmount = positions[0].length;

    ProteinStruct[] memory _proteins = new ProteinStruct[](maxQueryAmount);
    SeedPositionStruct[] memory possibleMatches = new SeedPositionStruct[](maxQueryAmount);
    
    possibleMatches = positions[0];

    int[] memory mismatchCounter = new int[](maxQueryAmount); // init value: 0, match: -1, mismatch: > 0
    bool[] memory addedProteins = new bool[](proteinIndex.length);

    for (uint i = 0; i < maxQueryAmount; i++) {
      uint nftId = possibleMatches[i].nftId;
      uint nftIndex = nftId - 1;

      for(uint j = 1; j < positions.length; j++) {
        for(uint k = 0; k < positions[j].length; k++) {
          SeedPositionStruct memory currentSeedPosition = positions[j][k];

          // if nftId's match AND previous position + seedStep equals the current position, then we have a match.
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
      if(!addedProteins[nftIndex]) {
        _proteins[proteinsFound] = proteinStructs[nftId];
        proteinsFound++;

        addedProteins[nftIndex] = true;
      }
    }

    proteins = resizeProteinStructArray(_proteins, proteins, proteinsFound);
  }

  //This function allows us to resize ProteinStruct arrays to appropriate lengths by copying data to a new sized array.
  function resizeProteinStructArray(ProteinStruct[] memory _from, ProteinStruct[] memory _to, uint _size) private pure returns(ProteinStruct[] memory) {
    _to = new ProteinStruct[](_size);

    for(uint i = 0; i < _size; i++) {
      _to[i] = _from[i];
    }

    return _to;
  }
}