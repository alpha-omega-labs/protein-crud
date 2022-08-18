pragma solidity ^0.8.12;
import './Owner.sol';
import '../libraries/Strings.sol';
import '../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for seed strings by Tousuke.
contract CrudSeed is Owner {
  using Strings for string;
  
  string[] internal seedIndex;
  mapping(string => Structs.SeedStruct) internal seedStructs;

  uint public positionCount;
  uint public detectablePositions;

  event LogNewSeed (string indexed seed, uint index, Structs.SeedPositionStruct[] positions);
  event LogUpdateSeed (string indexed seed, uint index, Structs.SeedPositionStruct[] positions);
  event LogDeleteSeed (string indexed seed, uint index);

  function insertSeed(string memory seed, Structs.SeedPositionStruct[] memory positions, 
  bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isSeed(seed);
    
    if(bypassRevert && exists) {
      return seedIndex.length - 1;
    } else {
      require(!exists, "This seed already exists and can't be inserted twice. Update its properties instead.");
    }

    seedStructs[seed].seed = seed;
    insertSeedPositions(seed, positions);
    
    seedIndex.push(seed);
    seedStructs[seed].index = seedIndex.length - 1;

    emit LogNewSeed(seed, seedStructs[seed].index, positions);

    return seedIndex.length-1;
  }

  function insertManySeeds(string[] memory seeds, Structs.SeedPositionStruct[][] memory positions, 
  bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < seeds.length; i++) {
      insertSeed(seeds[i], positions[i], bypassRevert);
    }

    return seedIndex.length - 1;
  }

  function insertSeedPosition(string memory seed, Structs.SeedPositionStruct memory position) private onlyAdmin {
    seedStructs[seed].positions.push(position);
    positionCount++;
    detectablePositions++;
  }

  function insertSeedPositions(string memory seed, 
  Structs.SeedPositionStruct[] memory positions) private onlyAdmin {
    for(uint i = 0; i < positions.length; i++) {
      insertSeedPosition(seed, positions[i]);
    }
  }

  function insertManySeedPositions(string[] memory seeds, 
  Structs.SeedPositionStruct[][] memory positions) public onlyAdmin {
    for(uint i = 0; i < seeds.length; i++) {
      require(isSeed(seeds[i]), "Seed could not be found in the database.");
      insertSeedPositions(seeds[i], positions[i]);
    }
  }

  function updateSeed(string memory seed, Structs.SeedPositionStruct[] memory positions, bool bypassRevert) 
  public onlyAdmin returns(bool success) {
    bool exists = isSeed(seed);

    if(bypassRevert && !exists) {
      return true;
    } else {
      require(exists, "Seed could not be found in the database."); 
    }

    // delete seedStructs[seed].positions;
    deleteSeedPositions(seed);
    insertSeedPositions(seed, positions);
    
    Structs.SeedStruct memory _seedStruct = seedStructs[seed];
    emit LogUpdateSeed(seed, _seedStruct.index, _seedStruct.positions);

    return true;
  }

  function updateManySeeds(string[] memory seeds, Structs.SeedPositionStruct[][] memory positions, 
  bool bypassRevert) public onlyAdmin returns(bool success) {
    for(uint i = 0; i < seeds.length; i++) {
      updateSeed(seeds[i], positions[i], bypassRevert);
    }

    return true;
  }

  function deleteSeed(string memory seed, bool hardDelete, bool bypassRevert) 
  public onlyOwner returns(uint seedsLeft) {
    if(hardDelete) {
      seedStructs[seed].seed = "";
      deleteSeedPositions(seed);
    }
    
    bool exists = isSeed(seed);

    if(bypassRevert && !exists) {
      return 0;
    } else {
      require(exists, "Seed could not be found in the database."); 
    }
    
    uint rowToDelete = seedStructs[seed].index;
    string memory keyToMove = seedIndex[seedIndex.length - 1];

    seedIndex[rowToDelete] = keyToMove;
    seedStructs[keyToMove].index = rowToDelete; 
    seedStructs[seed].index = 0;
    detectablePositions = detectablePositions - seedStructs[seed].positions.length;
    seedIndex.pop();

    emit LogDeleteSeed(seed, rowToDelete);
    emit LogUpdateSeed(keyToMove, rowToDelete, seedStructs[keyToMove].positions);

    return seedIndex.length;
  }

  function deleteManySeeds(string[] memory seeds, bool hardDelete, bool bypassRevert) 
  public onlyAdmin returns(uint seedsLeft) {
    for(uint i = 0; i < seeds.length; i++) {
      deleteSeed(seeds[i], hardDelete, bypassRevert);
    }

    return seedIndex.length;
  }

  // May result in an out-of-gas error if the seed size is too big.
  // Use deleteManySeeds instead if this is the case.
  function deleteAllSeeds(bool hardDelete) public onlyAdmin returns(uint seedsLeft) {
    uint _seedLength = seedIndex.length;

    for(uint i = 0; i < _seedLength; i++) {
      deleteSeed(seedIndex[0], hardDelete, false);
    }
    
    return seedIndex.length;
  }

  function deleteSeedPositions(string memory seed) private onlyAdmin returns(uint seedPositionsLeft) {
      uint _seedPositionsLength = seedStructs[seed].positions.length;
      uint positionsRemoved;

      for(uint i = 0; i < _seedPositionsLength; i++) {
        seedStructs[seed].positions.pop();
        positionsRemoved++;
      }

      positionCount = positionCount - positionsRemoved;
      
      if(isSeed(seed)) 
        detectablePositions = detectablePositions - positionsRemoved;
    
      return seedStructs[seed].positions.length;
  }

  function isSeed(string memory seed) public view returns(bool isIndeed) {
    if(seedIndex.length == 0) return false;

    return (seedIndex[seedStructs[seed].index].compare(seed));
  }

  function getSeed(string memory _seed) public view 
  returns(string memory seed, Structs.SeedPositionStruct[] memory positions, uint index) {
    require(isSeed(_seed), "Seed could not be found in the database."); 
    
    Structs.SeedStruct memory _seedStruct = seedStructs[_seed];
    return(
      _seedStruct.seed,
      _seedStruct.positions, 
      _seedStruct.index);
  }

  function getSeedStruct(string memory seed) public view returns(Structs.SeedStruct memory seedStruct) {
    return seedStructs[seed];
  }

  function getSeedPositions(string memory seed) public view returns (Structs.SeedPositionStruct[] memory) {
    return seedStructs[seed].positions;
  }

  function getManySeedPositions(string[] memory seeds, bool returnOnEmpty) public view returns (Structs.SeedPositionStruct[][] memory positions, bool emptyFound) {
    positions = new Structs.SeedPositionStruct[][](seeds.length);

    for(uint i = 0; i < seeds.length; i++) {
      Structs.SeedPositionStruct[] memory _positions = getSeedPositions(seeds[i]);

      if(returnOnEmpty && _positions.length == 0) {
        emptyFound = true;
        break;
      }

      positions[i] = _positions;
    }
  }

  function getSeedCount() public view returns(uint count) {
    return seedIndex.length;
  }

  function getSeedAtIndex(uint index) public view returns(string memory seed) {
    return seedIndex[index];
  }
}
