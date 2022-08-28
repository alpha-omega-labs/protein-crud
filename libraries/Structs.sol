pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

library Structs {
  struct ProteinStruct {
    uint nftId;
    string id;
    string sequence;
    string ipfsHash;
    uint index;
  }

  struct SeedStruct {
    string seed;
    SeedPositionStruct[] positions;
    uint index;
  }

  struct SeedPositionStruct {
    uint nftId;
    uint position;
  }

  struct WildcardStruct {
    string wildcard;
    string[] seeds;
    uint count;
    uint index;
  }

  // For instance an indexer group: 'Homo Sapiens', with an ID of 2 would be the second Indexer for this protein type.
  struct IndexerStruct {
    string group;
    uint id;
  }

  struct QueryOutputNftIds {
    uint[] nftIds;
    uint proteinCount;
  }

  struct QueryOutputSequences {
    string[] sequences;
    uint proteinCount;
  }

  struct QueryOutputIds {
    string[] ids;
    uint proteinCount;
  }

  struct QueryOutputIpfsHashes {
    string[] ipfsHashes;
    uint proteinCount;
  }

  struct QueryOutputProteinStructs {
    ProteinStruct[] proteins;
    uint proteinCount;
  }

  struct QueryOutputPositions {
    SeedPositionStruct[][] positions;
    bool emptyFound;
    bool returnAll;
  }

  // Basis from Subhodi, but altered for our needs (https://gist.github.com/subhodi/b3b86cc13ad2636420963e692a4d896f)
  // This allows us to sort SeedPositionStruct[][]'s based on the length of the positions.
  // A pointers list with the exact length is required to be able to reconstruct the original order.
  // e.g. [AAA, EEI, ASD, RWA] where every three letter word holds a list of structs like these: [{nftId: 3, position: 1}, {nftId: 4, position: 5}, ...].
  // the pointers array would look like [0, 1, 2, 3]. Once they're sorted, the pointers array will perhaps look like [2, 1, 3, 0], but this way we know what word came first.
  function sort(SeedPositionStruct[][] memory positions, uint[] memory pointers)
  public pure returns(SeedPositionStruct[][] memory, uint[] memory) {
    quickSort(positions, pointers, int(0), int(positions.length - 1));

    return (positions, pointers);
  }
  
  // Basis from Subhodi, but altered for our needs (https://gist.github.com/subhodi/b3b86cc13ad2636420963e692a4d896f)
  function quickSort(SeedPositionStruct[][] memory positions, uint[] memory pointers, int left, int right)
  internal pure {
    int i = left;
    int j = right;

    if(i == j) return;

    uint pivot = positions[uint(left + (right - left) / 2)].length;

    while(i <= j) {
      while (positions[uint(i)].length < pivot) i++;
      while (pivot < positions[uint(j)].length) j--;

      if (i <= j) {
        (positions[uint(i)], positions[uint(j)]) = (positions[uint(j)], positions[uint(i)]);
        (pointers[uint(i)], pointers[uint(j)]) = (pointers[uint(j)], pointers[uint(i)]);
        
        i++;
        j--;
      }
    }

    if (left < j) quickSort(positions, pointers, left, j);
    if (i < right) quickSort(positions, pointers, i, right);
  }
}