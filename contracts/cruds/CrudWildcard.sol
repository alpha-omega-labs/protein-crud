pragma solidity ^0.8.12;
import '../base/Owner.sol';
import '../../libraries/Strings.sol';
import '../../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for wildcard strings by Tousuke.

contract CrudWildcard is Owner {
  using Strings for string;
  
  string[] internal wildcardIndex;
  mapping(string => Structs.WildcardStruct) internal wildcardStructs;

  event LogNewWildcard (string indexed wildcard, uint index, string[] seeds, uint count);
  event LogUpdateWildcard (string indexed wildcard, uint index, string[] seeds, uint count);
  event LogDeleteWildcard (string indexed wildcard, uint index);

  function insertWildcard(string memory wildcard, string[] memory seeds, uint count, bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isWildcard(wildcard);
    
    if(bypassRevert && exists) {
      return wildcardIndex.length - 1;
    } else {
      require(!exists, "This seed already exists and can't be inserted twice. Update its properties instead.");
    }

    //https://github.com/zenodeapp/protein-crud/issues/18, to prevent inserting on top of old values after soft-deletion
    require(wildcardStructs[wildcard].seeds.length == 0, "This wildcard already has seeds stored and likely has been soft-deleted in the past. Either reuse the stored seeds by reverting the soft-deletion (revertSoftDeletion()) or hard-delete this wildcard before attempting to insert it again.");

    wildcardStructs[wildcard].wildcard = wildcard;
    wildcardStructs[wildcard].count = count;
    insertWildcardSeeds(wildcard, seeds);
    
    wildcardIndex.push(wildcard);
    wildcardStructs[wildcard].index = wildcardIndex.length - 1;

    emit LogNewWildcard(wildcard, wildcardStructs[wildcard].index, seeds, count);

    return wildcardIndex.length-1;
  }

  function insertManyWildcards(string[] memory wildcards, string[][] memory seeds, uint[] memory count, 
  bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < wildcards.length; i++) {
      insertWildcard(wildcards[i], seeds[i], count[i], bypassRevert);
    }

    return wildcardIndex.length - 1;
  }

  function updateWildcard(string memory wildcard, string[] memory seeds, bool bypassRevert) 
  public onlyAdmin returns(bool success) {
    bool exists = isWildcard(wildcard);

    if(bypassRevert && !exists) {
      return true;
    } else {
      require(exists, "Wildcard could not be found in the database."); 
    }

    deleteWildcardSeeds(wildcard);
    insertWildcardSeeds(wildcard, seeds);
    
    Structs.WildcardStruct memory _wildcardStruct = wildcardStructs[wildcard];
    emit LogUpdateWildcard(wildcard, _wildcardStruct.index, _wildcardStruct.seeds, _wildcardStruct.count);

    return true;
  }

  function updateManyWildcards(string[] memory wildcards, string[][] memory seeds, 
  bool bypassRevert) public onlyAdmin returns(bool success) {
    for(uint i = 0; i < wildcards.length; i++) {
      updateWildcard(wildcards[i], seeds[i], bypassRevert);
    }

    return true;
  }

  function deleteWildcard(string memory wildcard, bool hardDelete, bool bypassRevert) 
  public onlyOwner returns(uint seedsLeft) {
    if(hardDelete) {
      wildcardStructs[wildcard].wildcard = "";
      wildcardStructs[wildcard].count = 0;
      deleteWildcardSeeds(wildcard);
    }
    
    bool exists = isWildcard(wildcard);

    if(bypassRevert && !exists) {
      return 0;
    } else {
      require(exists, "Wildcard could not be found in the database."); 
    }
    
    uint rowToDelete = wildcardStructs[wildcard].index;
    string memory keyToMove = wildcardIndex[wildcardIndex.length - 1];

    wildcardIndex[rowToDelete] = keyToMove;
    wildcardStructs[keyToMove].index = rowToDelete; 
    wildcardStructs[wildcard].index = 0;
    wildcardIndex.pop();

    emit LogDeleteWildcard(wildcard, rowToDelete);
    emit LogUpdateWildcard(keyToMove, rowToDelete, wildcardStructs[keyToMove].seeds, wildcardStructs[keyToMove].count);

    return wildcardIndex.length;
  }

  function deleteManyWildcards(string[] memory wildcards, bool hardDelete, bool bypassRevert) 
  public onlyAdmin returns(uint wildcardSeedsLeft) {
    for(uint i = 0; i < wildcards.length; i++) {
      deleteWildcard(wildcards[i], hardDelete, bypassRevert);
    }

    return wildcardIndex.length;
  }

  // May result in an out-of-gas error if the wildcard size is too big (use deleteManyWildcards instead if this happens).
  function deleteAllWildcards(bool hardDelete) public onlyAdmin returns(uint wildcardSeedsLeft) {
    uint _wildcardLength = wildcardIndex.length;

    for(uint i = 0; i < _wildcardLength; i++) {
      deleteWildcard(wildcardIndex[0], hardDelete, false);
    }
    
    return wildcardIndex.length;
  }

  function undoWildcardDeletion(string memory wildcard) public onlyAdmin returns(uint index) {
    require(!isWildcard(wildcard) && wildcard.compare(wildcardStructs[wildcard].wildcard), "Reverting soft-deletions can only be done on wildcards that have been soft-deleted.");

    wildcardIndex.push(wildcard);
    wildcardStructs[wildcard].index = wildcardIndex.length - 1;

    Structs.WildcardStruct memory _wildcardStruct = wildcardStructs[wildcard];
    emit LogNewWildcard(wildcard, _wildcardStruct.index, _wildcardStruct.seeds, _wildcardStruct.count);

    return wildcardIndex.length - 1;
  }

  function insertWildcardSeeds(string memory wildcard, 
  string[] memory seeds) private onlyAdmin {
    for(uint i = 0; i < seeds.length; i++) {
      wildcardStructs[wildcard].seeds.push(seeds[i]);
    }
  }

  function appendWildcardSeeds(string memory wildcard, 
  string[] memory seeds) public onlyAdmin {
    require(isWildcard(wildcard), "Wildcard could not be found in the database.");

    insertWildcardSeeds(wildcard, seeds);
  }

  function appendManyWildcardSeeds(string[] memory wildcards, 
  string[][] memory seeds) public onlyAdmin {
    for(uint i = 0; i < wildcards.length; i++) {
      appendWildcardSeeds(wildcards[i], seeds[i]);
    }
  }

  function deleteWildcardSeeds(string memory wildcard) private onlyAdmin returns(uint wildcardSeedsLeft) {
    uint _wildcardSeedsLength = wildcardStructs[wildcard].seeds.length;

    for(uint i = 0; i < _wildcardSeedsLength; i++) {
      wildcardStructs[wildcard].seeds.pop();
    }

    return wildcardStructs[wildcard].seeds.length;
  }

  function isWildcard(string memory wildcard) public view returns(bool isIndeed) {
    if(wildcardIndex.length == 0) return false;

    return (wildcardIndex[wildcardStructs[wildcard].index].compare(wildcard));
  }

  function getWildcard(string memory _wildcard) public view 
  returns(string memory wildcard, string[] memory seeds, uint count, uint index) {
    require(isWildcard(_wildcard), "Wildcard could not be found in the database."); 
    
    Structs.WildcardStruct memory _wildcardStruct = wildcardStructs[_wildcard];
    return(
      _wildcardStruct.wildcard,
      _wildcardStruct.seeds,
      _wildcardStruct.count,
      _wildcardStruct.index);
  }

  function getWildcardStruct(string memory wildcard) public view returns(Structs.WildcardStruct memory wildcardStruct) {
    return wildcardStructs[wildcard];
  }

  function getWildcardSeeds(string memory wildcard) public view returns (string[] memory) {
    return wildcardStructs[wildcard].seeds;
  }

  function getWildcardCount() public view returns(uint count) {
    return wildcardIndex.length;
  }

  function getWildcardIndex() public view returns(string[] memory wildcards) {
    return wildcardIndex;
  }

  function getWildcardAtIndex(uint index) public view returns(string memory wildcard) {
    return wildcardIndex[index];
  }
}
