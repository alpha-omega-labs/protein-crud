module.exports = {
  contracts: {
    indexerProtein: {
      // The name of the contract for deployment.
      name: "IndexerProtein",

      //Which contract are we targeting for our protein scripts/tasks?
      address: "",

      //Group name where this indexer belongs to.
      indexerGroup: "Homo Sapiens",
      //Number in the group.
      indexerId: 1,
    },

    indexerSeed: {
      // The name of the contract for deployment.
      name: "IndexerSeed",

      ///Which contract are we targeting for our seed scripts/tasks?
      address: "",

      //Group name where this indexer belongs to.
      indexerGroup: "Homo Sapiens",
      //Number in the group.
      indexerId: 1,
      //This is stored to inform us what seedSize this indexer will contain.
      seedSize: 3,
    },

    queryNaive: {
      name: "QueryNaive",
      address: "",
    },

    querySemiBlast: {
      name: "QuerySemiBlast",
      address: "",
    },
  },

  // Libraries are only supposed to be deployed once.
  // Fill out the library's address to prevent the scripts to redeploy.
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

    // How many wildcards will we insert/delete per transaction
    wildcardsPerBatch: 50,

    // Check the ./datasets folder to see which dataset sizes are available.
    files: {
      //Remember to always match the protein sizes with the seed sizes.
      proteinsInsertMany: "datasets/proteins/protein_structs_100.txt",
      seedsInsertMany: "datasets/seeds/seed_3_structs_100.txt",
      wildcardsInsertMany: "datasets/wildcards/wildcard_3_structs_100.txt",

      //This allows us to add extra positions to (known) seeds! Useful if you need to add the seed's array in parts!
      seedsAppendManyPositions: "datasets/seeds/",

      //when deleting, make sure to set this to the file you used for insertion!
      proteinsDeleteMany: "datasets/proteins/protein_structs_100.txt",
      seedsDeleteMany: "datasets/seeds/seed_3_structs_100.txt",

      proteinsUpdateMany: "datasets/proteins/protein_structs_100.txt",
      seedsUpdateMany: "datasets/seeds/seed_3_structs_100.txt",
    },
  },

  queryOptions: {
    defaultLimit: 0,
    defaultCaseSensitivity: false,
    defaultSeedSize: 3, //Only for semi-blast
    defaultUnion: false, //Currently only for the naive algorithm
    defaultFormat: "protein", //Possible values: "protein", "id", "nft", "sequence" or "ipfs".
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
