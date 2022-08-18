require("@nomicfoundation/hardhat-toolbox");
const { queryProtein } = require("./helpers/queries");
const {
  getIndexerProteinContract,
  getStringsLibrary,
  getIndexerSeedContract,
  getQuerySemiBlastContract,
  getQueryNaiveContract,
} = require("./helpers/web3");
const {
  hardDelete,
  bypassRevert,
  contracts,
  queryOptions,
} = require("./proteins.config");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "localhost",
  networks: {
    hardhat: { gas: 2000000000, blockGasLimit: 2000000000 },
    localhost: { url: "http://127.0.0.1:8545", timeout: 100000000 },
    genesisd: {
      url: "http://23.88.68.53:8545",
      gas: 1000000000,
      chainId: 29,
      accounts: [],
      timeout: 100000000,
    },
  },
  mocha: {
    timeout: 100000000,
  },
};

//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* PROTEINS CONTRACT */
task("deleteProtein", "Delete a protein with the given NFT ID.")
  .addParam("nft", "The NFT ID.")
  .addOptionalParam(
    "hard",
    "Hard deletion costs more gas.",
    hardDelete ? "true" : "false"
  )
  .addOptionalParam("bypass", "Bypass revert.", bypassRevert ? "true" : "false")
  .setAction(async (taskArgs, hre) => {
    const { nft, hard, bypass } = taskArgs;
    const contract = await getIndexerProteinContract(hre);

    const result = await contract.deleteProtein(nft, eval(hard), eval(bypass));
    console.log(result);
  });

task("getProtein", "Returns the protein for the given NFT ID.")
  .addParam("nft", "The NFT ID.")
  .setAction(async (taskArgs, hre) => {
    const { nft } = taskArgs;
    const contract = await getIndexerProteinContract(hre);

    const result = await contract.getProtein(nft);
    console.log(result);
  });

task("getProteinCount", "How many proteins are included in storage.").setAction(
  async (_, hre) => {
    const contract = await getIndexerProteinContract(hre);

    const result = await contract.getProteinCount();
    console.log(result);
  }
);

task("getProteinAtIndex", "Returns the NFT ID at the given index.")
  .addParam("index", "The index value.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerProteinContract(hre);

    const result = await contract.getProteinAtIndex(taskArgs.index);
    console.log(result);
  });

task(
  "insertSeedAddress",
  "Inserts a new seed address in the proteins contract."
)
  .addParam(
    "address",
    "The seed address to add to the protein indexer.",
    contracts.indexerSeed.address
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerProteinContract(hre);

    await contract.insertSeedAddress(taskArgs.address);
  });

task("updateSeedAddress", "Update the seed address for a given seed size.")
  .addParam("seedsize", "The seed size.")
  .addParam("address", "The seed address to add to the protein indexer.")
  .setAction(async (taskArgs, hre) => {
    const { seedsize, address } = taskArgs;
    const contract = await getIndexerProteinContract(hre);

    await contract.updateSeedAddress(seedsize, address);
  });

task(
  "deleteSeedAddress",
  "Delete the stored seed address for a given seed size."
)
  .addParam("seedsize", "The seed size.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerProteinContract(hre);

    await contract.deleteSeedAddress(taskArgs.seedsize);
  });

task("getSeedAddress", "Get the stored seed address for a given seed size.")
  .addParam("seedsize", "The seed size.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerProteinContract(hre);

    const result = await contract.getSeedAddress(taskArgs.seedsize);
    console.log(result);
  });

task(
  "getIndexerProteinInfo",
  "Returns information about this indexer."
).setAction(async (_, hre) => {
  const contract = await getIndexerProteinContract(hre);

  const result = await contract.getIndexerInfo();
  console.log(result);
});

/* SEEDS CONTRACT */
task("deleteSeed", "Delete the given seed.")
  .addParam("seed", "The seed.")
  .addOptionalParam(
    "hard",
    "Hard deletion costs more gas.",
    hardDelete ? "true" : "false"
  )
  .addOptionalParam("bypass", "Bypass revert.", bypassRevert ? "true" : "false")
  .setAction(async (taskArgs, hre) => {
    const { nft, hard, bypass } = taskArgs;
    const contract = await getIndexerSeedContract(hre);

    const result = await contract.deleteSeed(nft, eval(hard), eval(bypass));
    console.log(result);
  });

task(
  "getSeed",
  "Returns all NFTs (with positions) that contain this short seed phrase."
)
  .addParam("seed", "The seed.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerSeedContract(hre);

    const result = await contract.getSeed(taskArgs.seed);
    console.log(result);
  });

task("getSeedCount", "How many seeds are included in storage.").setAction(
  async (_, hre) => {
    const contract = await getIndexerSeedContract(hre);

    const result = await contract.getSeedCount();
    console.log(result);
  }
);

task("getSeedAtIndex", "Returns the seed at the given index.")
  .addParam("index", "The index value.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getIndexerSeedContract(hre);

    const result = await contract.getSeedAtIndex(taskArgs.index);
    console.log(result);
  });

task("getIndexerSeedInfo", "Returns information about this indexer.").setAction(
  async (_, hre) => {
    const contract = await getIndexerSeedContract(hre);

    const result = await contract.getIndexerInfo();
    console.log(result);
  }
);

/* STRINGS LIBRARY */
task("fragmentWord", "Split a word in multiple segments.")
  .addParam("word", "The word")
  .addOptionalParam("size", "The size of the word.", "3")
  .addOptionalParam(
    "step",
    "Step size is the offset used for each next word.",
    "1"
  )
  .addOptionalParam(
    "force",
    "Forces the last segment to have the given size.",
    "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getStringsLibrary(hre);
    const { word, size, step, force } = taskArgs;

    const result = await contract.fragment(
      word,
      parseInt(size),
      parseInt(step),
      eval(force)
    );
    console.log(result);
  });

/* QUERYING */
task(
  "semiBlastQuery",
  "Get all NFTs matching the query using the semi-blast query protocol."
)
  .addOptionalParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize.toString()
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit.toString()
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .addOptionalParam(
    "format",
    'How would you like the data to formatted? Choose between "protein", "id", "nft", "sequence" or "ipfs".',
    queryOptions.defaultFormat
  )
  .setAction(async (taskArgs, hre) => {
    const { sequence, seedsize, limit, casesensitive, format } = taskArgs;

    const contract = await getQuerySemiBlastContract(hre);
    const queryInput = { sequence };
    const queryOptions = {
      seedSize: parseInt(seedsize),
      limit: parseInt(limit),
      caseSensitive: eval(casesensitive),
    };

    if (contract) {
      const result = await queryProtein(
        contract,
        queryInput,
        queryOptions,
        format
      );

      queryOptions.format = format;

      console.log(result.data);
      console.log();
      console.log(`${result.count} results found matching query:`);
      console.log(queryInput);
      console.log(queryOptions);
    }
  });

task(
  "naiveQuery",
  "Get all NFTs matching the query using the naive query protocol."
)
  .addOptionalParam("sequence", "The sequence query.", "")
  .addOptionalParam("id", "The PDBID/ACCESSION query.", "")
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit.toString()
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .addOptionalParam(
    "union",
    "Union query would combine all individual results into one set. E.g. sequence = AAA and id = 1A, would result in all matches for AAA and all matches for 1A.",
    queryOptions.defaultUnion ? "true" : "false"
  )
  .addOptionalParam(
    "format",
    'How would you like the data to formatted? Choose between "protein", "id", "nft", "sequence" or "ipfs".',
    queryOptions.defaultFormat
  )
  .setAction(async (taskArgs, hre) => {
    const { id, sequence, limit, union, casesensitive, format } = taskArgs;

    const contract = await getQueryNaiveContract(hre);
    const queryInput = { id, sequence };
    const queryOptions = {
      limit: parseInt(limit),
      caseSensitive: eval(casesensitive),
      union: eval(union),
    };

    if (contract) {
      const result = await queryProtein(
        contract,
        queryInput,
        queryOptions,
        format
      );

      queryOptions.format = format;

      console.log(result.data);
      console.log();
      console.log(`${result.count} results found matching query:`);
      console.log(queryInput);
      console.log(queryOptions);
    }
  });
