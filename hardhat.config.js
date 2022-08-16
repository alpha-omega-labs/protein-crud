require("@nomicfoundation/hardhat-toolbox");
const {
  getIndexerProteinContract,
  getStringsLibrary,
  getIndexerSeedContract,
  getQueryContract,
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

/* OWNER CONTRACT */
// task("addAdmin", "Add a new admin.")
//   .addParam("address", "The address.")
//   .setAction(async (taskArgs) => {
//     const contract = await getIndexerProteinContract();

//     await contract.addAdmin(taskArgs.address);
//   });

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

// task("naiveQuery", "Get all NFTs matching id or sequence with the given query.")
//   .addOptionalParam("sequence", "The sequence query.", "")
//   .addOptionalParam("id", "The PDBID/ACCESSION query.", "")
//   .addOptionalParam(
//     "exclusive",
//     "Exclusive would mean that both query restrictions must be true, else one or the other has to be true.",
//     "false"
//   )
//   .setAction(async (taskArgs, hre) => {
//     const contract = await getQueryContract(hre);
//     const { id, sequence, exclusive } = taskArgs;

//     const result = await contract.naiveQuery(id, sequence, eval(exclusive));
//     console.log(result.proteins);
//     console.log(
//       `${result.proteinsFound} results found matching query {sequence: "${sequence}", id: "${id}", exclusive: ${exclusive}}.`
//     );
//   });

/* QUERY CONTRACT */
task(
  "queryProteinsBySequence",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getQueryContract(hre);
    const { sequence, seedsize, limit, casesensitive } = taskArgs;

    const result = await contract.queryProteinsBySequence(
      contracts.indexerProtein.address,
      sequence,
      { seedSize: seedsize, limit, caseSensitive: eval(casesensitive) }
    );

    console.log(result.proteins);
    console.log(
      `${result.proteinCount} results found matching query {sequence: "${sequence}", seedsize: ${seedsize}, limit: ${limit}, casesensitive: ${casesensitive}}.`
    );
  });

task(
  "queryNftIdsBySequence",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getQueryContract(hre);
    const { sequence, seedsize, limit, casesensitive } = taskArgs;

    const result = await contract.queryNftIdsBySequence(
      contracts.indexerProtein.address,
      sequence,
      { seedSize: seedsize, limit, caseSensitive: eval(casesensitive) }
    );

    console.log(result.nftIds);
    console.log(
      `${result.proteinCount} results found matching query {sequence: "${sequence}", seedsize: ${seedsize}, limit: ${limit}, casesensitive: ${casesensitive}}.`
    );
  });

task(
  "queryIdsBySequence",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getQueryContract(hre);
    const { sequence, seedsize, limit, casesensitive } = taskArgs;

    const result = await contract.queryIdsBySequence(
      contracts.indexerProtein.address,
      sequence,
      { seedSize: seedsize, limit, caseSensitive: eval(casesensitive) }
    );

    console.log(result.ids);
    console.log(
      `${result.proteinCount} results found matching query {sequence: "${sequence}", seedsize: ${seedsize}, limit: ${limit}, casesensitive: ${casesensitive}}.`
    );
  });

task(
  "querySequencesBySequence",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getQueryContract(hre);
    const { sequence, seedsize, limit, casesensitive } = taskArgs;

    const result = await contract.querySequencesBySequence(
      contracts.indexerProtein.address,
      sequence,
      { seedSize: seedsize, limit, caseSensitive: eval(casesensitive) }
    );

    console.log(result.sequences);
    console.log(
      `${result.proteinCount} results found matching query {sequence: "${sequence}", seedsize: ${seedsize}, limit: ${limit}, casesensitive: ${casesensitive}}.`
    );
  });

task(
  "queryIpfsHashesBySequence",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addParam("sequence", "The sequence query.", "")
  .addOptionalParam(
    "seedsize",
    "Seed size to use for querying.",
    queryOptions.defaultSeedSize
  )
  .addOptionalParam(
    "limit",
    "Limit the amount of results given back.",
    queryOptions.defaultLimit
  )
  .addOptionalParam(
    "casesensitive",
    "Case-sensitive lookup.",
    queryOptions.defaultCaseSensitivity ? "true" : "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getQueryContract(hre);
    const { sequence, seedsize, limit, casesensitive } = taskArgs;

    const result = await contract.queryIpfsHashesBySequence(
      contracts.indexerProtein.address,
      sequence,
      { seedSize: seedsize, limit, caseSensitive: eval(casesensitive) }
    );

    console.log(result.ipfsHashes);
    console.log(
      `${result.proteinCount} results found matching query {sequence: "${sequence}", seedsize: ${seedsize}, limit: ${limit}, casesensitive: ${casesensitive}}.`
    );
  });
