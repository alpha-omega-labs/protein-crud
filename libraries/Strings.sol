pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

library Strings {
  // Splits a string into smaller fragments based on the given size and step-size. Here follow some examples:
  // word=ABCDEF, size=3 and step=1 will give every possible 3 letter fragment in the word: [ABC, BCD, CDE, DEF].
  // word=ABCDEF, size=4 and step=2 will result in: [ABCD, CDEF, EF].
  // word=ABCDEFG, size=3 and step=3 will give every fragment without overlap: [ABC, DEF, G].
  // word=ABCDEFG, size=3, step=3 and forceSize=true will result in: [ABC, DEF, EFG].
  function fragment(string memory word, uint size, uint step, bool forceSize) public pure returns(string[] memory fragments, uint seedTailSize) {
    require(step <= size, "Step can't be higher than the given size.");
    require(step > 0, "A step value higher than 0 is required.");

    bytes memory wordBytes = bytes(word);
    uint wordSize = wordBytes.length;

    require(wordSize >= size, "Word can't be smaller than the fragment size.");

    uint wordPointer = 0;
    
    //My brain hurt after having figured this one out :).
    //This is basically the amount of words we're able to make, while being considerate of both the 'size' and 'step'-value.
    uint wordThreshold = wordSize - size;
    uint wordCount = (wordThreshold / step) + (wordThreshold % step > 0 ? 1 : 0) + 1;

    fragments = new string[](wordCount);

    for(uint i = 0; i < wordCount; i++) {
      bytes memory segment = i < wordCount - 1
        ? sliceBytes(wordBytes, wordPointer, size)
        : forceSize
          ? sliceBytes(wordBytes, wordSize - size, size)
          : sliceBytes(wordBytes, wordPointer, wordSize - wordPointer);

      fragments[i] = string(segment);
      
      wordPointer = i == wordCount - 1
        ? wordPointer
        : wordPointer + step;
    }


    // A word can't always be split equally in w-sized pieces,
    // This integer indicates how many characters the last word returned.
    // NOTE: even if forceSize is turned on, this will still return the tail size as if forceSize was turned off.
    seedTailSize = wordSize - wordPointer;
  }

  // Private helper function, part of fragment().
  function sliceBytes(bytes memory word, uint start, uint size) private pure returns(bytes memory sliced) {
    require(start + size <= word.length,  "Sliced fragment is outside the scope of the byte array.");

    sliced = new bytes(size);
    for (uint j = 0; j < size; j++) { 
      sliced[j] = word[start + j]; 
    }
  }

  // https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity
  function compare(string memory a, string memory b) public pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  // From Hermes Ateneo (https://github.com/HermesAteneo/solidity-repeated-word-in-string/blob/main/RepeatedWords.sol)
  function contains(string memory what, string memory where) public pure returns (bool found) {
    bytes memory whatBytes = bytes(what);
    bytes memory whereBytes = bytes(where);

    if (whereBytes.length < whatBytes.length) return false;

    found = false;
    for (uint i = 0; i <= whereBytes.length - whatBytes.length; i++) {
      bool flag = true;

      for (uint j = 0; j < whatBytes.length; j++) {
        if (whereBytes [i + j] != whatBytes [j]) {
          flag = false;
          break;
        }
      }
      
      if (flag) {
        found = true;
        break;
      }
    }

    return found;
  }
}