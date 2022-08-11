module.exports = {
  contracts: {
    indexer: {
      // The name of the contract for deployment.
      name: "TempQuery", //This is temporary, eventually this will be set to "Indexer" and Query will be a separate contract.

      //Which contract are we targeting with our scripts/tasks?
      address: "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",

      //Commented out for now
      //   //Identifier for this indexer.
      //   indexerId: 1,

      //   //Is stored to inform us what seedSize this indexer will contain.
      //   seedSize: 3,
    },

    //Work in progress
    // query: {
    //   name: "Query",
    //   address: "",

    //   //list of indexers this Query contract should be initialized with.
    //   //NOTE: it's not necessary to do this.
    //   indexers: [
    //     {
    //       seedSize: 3,
    //       addresses: [],
    //     },
    //   ],
    // },
  },

  // Libraries are only supposed to be deployed once.
  // Fill out the library's address to prevent the deploy.js script from redeploying.
  libraries: {
    strings: {
      name: "Strings",
      address: "",
    },

    structs: {
      name: "Structs",
      address: "",
    },
  },

  manyScripts: {
    // How many proteins will we insert/delete per transaction
    proteinsPerBatch: 50,

    // How many seeds will we insert/delete per transaction
    seedsPerBatch: 20,

    // Check the ./datasets folder to see which dataset sizes are available.
    files: {
      //Remember to always match the protein sizes with the seed sizes.
      proteinsInsertMany: "datasets/proteins/protein_structs_100.txt",
      seedsInsertMany: "datasets/seeds/seed_3_structs_100.txt",

      //when deleting, make sure to set this to the file you used for insertion!
      proteinsDeleteMany: "datasets/proteins/protein_structs_100.txt",
      seedsDeleteMany: "datasets/seeds/seed_3_structs_100.txt",

      proteinsUpdateMany: "datasets/proteins/protein_structs_100.txt",
      seedsUpdateMany: "datasets/seeds/seed_3_structs_100.txt",
    },
  },

  // Normally, inserting the same protein or seed twice would revert the tx, returning an error stating it already exists.
  // However setting bypassRevert to true will prevent Solidity from returning an error message and ignores the request.
  // So if importing failed, but you can't be bothered with figuring out from which ID you should continue, turn this on.
  // Do have in mind that this consumes more gas, for the tx doesn't get reverted!
  bypassRevert: false,

  // So the basic CRUD from Rob Hitchens (found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/) didn't
  // reset all values from the Struct. Which isn't necessary for this to work, but if you really want to remove everything, when deleting, turn this on.
  // NOTE: Slower and probably double the size when it comes to gas. Also, this can always be run, even if you soft deleted everything first.
  hardDelete: false,
};
