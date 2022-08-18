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
    Structs.ProteinStruct[] proteins;
    uint proteinCount;
  }

  //This function allows us to resize ProteinStruct arrays to appropriate lengths by copying data to a new sized array.
  function resizeArray(ProteinStruct[] memory _from, ProteinStruct[] memory _to, uint _size) public pure returns(ProteinStruct[] memory) {
    _to = new ProteinStruct[](_size);

    for(uint i = 0; i < _size; i++) {
      _to[i] = _from[i];
    }

    return _to;
  }
}