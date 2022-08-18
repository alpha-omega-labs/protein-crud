pragma solidity ^0.8.12;
import './Owner.sol';
import '../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for protein strings by Tousuke.

contract CrudProtein is Owner {
  uint[] public proteinIndex;
  mapping(uint => Structs.ProteinStruct) public proteinStructs;

  event LogNewProtein (uint indexed nftId, uint index, string id, string sequence, string ipfsHash);
  event LogUpdateProtein (uint indexed nftId, uint index, string id, string sequence, string ipfsHash);
  event LogDeleteProtein (uint indexed nftId, uint index);

  function insertProtein(uint nftId, string memory id,
  string memory sequence, string memory ipfsHash, bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isProtein(nftId);

    if(bypassRevert && exists) {
      return proteinIndex.length - 1;
    } else {
      require(!exists, "This nft already exists and can't be inserted twice. Update its properties instead.");
    }

    proteinStructs[nftId].nftId = nftId;
    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    proteinStructs[nftId].ipfsHash = ipfsHash;
    
    proteinIndex.push(nftId);
    proteinStructs[nftId].index = proteinIndex.length - 1;

    emit LogNewProtein(nftId, proteinStructs[nftId].index, id, sequence, ipfsHash);

    return proteinIndex.length - 1;
  }

  function insertManyProteins(uint[] memory nftIds, string[] memory ids, 
  string[] memory sequences, string[] memory ipfsHashes, bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < nftIds.length; i++) {
      insertProtein(nftIds[i], ids[i], sequences[i], ipfsHashes[i], bypassRevert);
    }

    return proteinIndex.length - 1;
  }

  function updateProtein(uint nftId, string memory id, string memory sequence,
  string memory ipfsHash, bool bypassRevert) public onlyAdmin returns(bool success) {
    bool exists = isProtein(nftId);

    if(bypassRevert && !exists) {
      return true;
    } else {
      require(exists, "NFT ID could not be found in the database.");
    }
    
    proteinStructs[nftId].nftId = nftId;
    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    proteinStructs[nftId].ipfsHash = ipfsHash;

    emit LogUpdateProtein(nftId, proteinStructs[nftId].index, id, sequence, ipfsHash);

    return true;
  }

  function updateManyProteins(uint[] memory nftIds, string[] memory ids, 
  string[] memory sequences, string[] memory ipfsHashes, bool bypassRevert) public onlyAdmin returns(bool success) {
    for(uint i = 0; i < nftIds.length; i++) {
      updateProtein(nftIds[i], ids[i], sequences[i], ipfsHashes[i], bypassRevert);
    }

    return true;
  }

  // Hard deletion will also reset all values inserted in the protein structs. This is costly and not necessary.
  function deleteProtein(uint nftId, bool hardDelete, bool bypassRevert) public onlyAdmin returns(uint proteinsLeft) {
    if(hardDelete) {
      proteinStructs[nftId].nftId = 0;
      proteinStructs[nftId].sequence = "";
      proteinStructs[nftId].id = "";
      proteinStructs[nftId].ipfsHash = "";
    }

    bool exists = isProtein(nftId);

    if(bypassRevert && !exists) {
      return 0;
    } else {
      require(exists, "NFT ID could not be found in the database."); 
    }

    uint rowToDelete = proteinStructs[nftId].index;
    uint keyToMove = proteinIndex[proteinIndex.length - 1];

    proteinIndex[rowToDelete] = keyToMove;
    proteinStructs[keyToMove].index = rowToDelete; 
    proteinStructs[nftId].index = 0;
    proteinIndex.pop();

    emit LogDeleteProtein(nftId, rowToDelete);
    
    Structs.ProteinStruct memory _proteinStruct = proteinStructs[keyToMove];
    emit LogUpdateProtein(keyToMove, rowToDelete, _proteinStruct.id, _proteinStruct.sequence, _proteinStruct.ipfsHash);

    return proteinIndex.length;
  }

  function deleteManyProteins(uint[] memory nftIds, bool hardDelete, bool bypassRevert) public onlyAdmin returns(uint proteinsLeft) {
    for(uint i = 0; i < nftIds.length; i++) {
      deleteProtein(nftIds[i], hardDelete, bypassRevert);
    }

    return proteinIndex.length;
  }

  // May result in an out-of-gas error if the protein size is too big.
  // Use deleteManyProteins instead if this is the case.
  function deleteAllProteins(bool hardDelete) public onlyAdmin returns(uint proteinsLeft) {
    uint _proteinLength = proteinIndex.length;

    for(uint i = 0; i < _proteinLength; i++) {
      deleteProtein(proteinIndex[0], hardDelete, false);
    }
    
    return proteinIndex.length;
  }

  function isProtein(uint nftId) public view returns(bool isIndeed) {
    if(proteinIndex.length == 0) return false;

    return (proteinIndex[proteinStructs[nftId].index] == nftId);
  }

  function getProtein(uint _nftId) public view returns(uint nftId, string memory id, string memory sequence, string memory ipfsHash, uint index) {
    require(isProtein(_nftId), "NFT ID could not be found in the database."); 

    Structs.ProteinStruct memory _proteinStruct = proteinStructs[_nftId];
    return(
      _proteinStruct.nftId, 
      _proteinStruct.id, 
      _proteinStruct.sequence,
      _proteinStruct.ipfsHash,
      _proteinStruct.index);
  }

  function getProteinStruct(uint nftId) public view returns(Structs.ProteinStruct memory proteinStruct) {
    return proteinStructs[nftId];
  }

  function getProteinStructAtIndex(uint index) public view returns(Structs.ProteinStruct memory proteinStruct) {
    return proteinStructs[proteinIndex[index]];
  }

  function getManyProteinStructs(uint[] memory nftIds) public view returns(Structs.ProteinStruct[] memory proteins) {
    proteins = new Structs.ProteinStruct[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      proteins[i] = getProteinStruct(nftIds[i]);
    }
  }

  function getAllProteinStructs() public view returns(Structs.ProteinStruct[] memory _proteinStructs) {
    _proteinStructs = new Structs.ProteinStruct[](proteinIndex.length);

    for(uint i = 0; i < proteinIndex.length; i++) {
      _proteinStructs[i] = getProteinStruct(proteinIndex[i]);
    }
  }

  function getManyProteinIds(uint[] memory nftIds) public view returns(string[] memory ids) {
    ids = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      ids[i] = getProteinStruct(nftIds[i]).id;
    }
  }

  function getManyProteinSequences(uint[] memory nftIds) public view returns(string[] memory sequences) {
    sequences = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      sequences[i] = getProteinStruct(nftIds[i]).sequence;
    }
  }

  function getManyProteinIpfsHashes(uint[] memory nftIds) public view returns(string[] memory ipfsHashes) {
    ipfsHashes = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      ipfsHashes[i] = getProteinStruct(nftIds[i]).ipfsHash;
    }
  }

  function getProteinCount() public view returns(uint count) {
    return proteinIndex.length;
  }

  function getProteinAtIndex(uint index) public view returns(uint nftId) {
    return proteinIndex[index];
  }
}