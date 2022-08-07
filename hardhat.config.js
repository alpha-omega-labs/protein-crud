require("@nomicfoundation/hardhat-toolbox");
const { getProteinContract } = require("./helpers/web3");

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
/* QUERIES */
task("naiveQuery", "Get all NFTs matching id or sequence with the given query.")
  .addOptionalParam("sequence", "The sequence query.", "")
  .addOptionalParam("id", "The PDBID/ACCESSION query.", "")
  .addOptionalParam(
    "exclusive",
    "Exclusive would mean that both query restrictions must be true, else one or the other has to be true.",
    "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);
    const { id, sequence, exclusive } = taskArgs;

    const result = await contract.naiveQuery(id, sequence, eval(exclusive));
    console.log(result.proteins);
    console.log(
      `${result.proteinsFound} results found matching query {sequence: "${sequence}", id: "${id}", exclusive: ${exclusive}}.`
    );
  });

task(
  "semiBlastQuery",
  "Get all NFTs matching the query using the semi-blast protocol."
)
  .addOptionalParam("sequence", "The sequence query.", "")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);
    const { sequence } = taskArgs;

    const result = await contract.semiBlastQuery(sequence);
    console.log(result.proteins);
    console.log(
      `${result.proteinsFound} results found matching query {sequence: "${sequence}"}.`
    );
  });

/* READS */
task("getProtein", "Returns the protein for the given NFT ID.")
  .addParam("nft", "The NFT ID.")
  .setAction(async (taskArgs, hre) => {
    const { nft } = taskArgs;
    const contract = await getProteinContract(hre);

    const result = await contract.getProtein(nft);
    console.log(result);
  });
task(
  "getSeed",
  "Returns all NFTs (with positions) that contain this short seed phrase."
)
  .addParam("seed", "The seed.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);

    const result = await contract.getSeed(taskArgs.seed);
    console.log(result);
  });

task("proteinCount", "How many proteins are included in storage.").setAction(
  async (_, hre) => {
    const contract = await getProteinContract(hre);

    const result = await contract.proteinCount();
    console.log(result);
  }
);
task("seedCount", "How many seeds are included in storage.").setAction(
  async (_, hre) => {
    const contract = await getProteinContract(hre);

    const result = await contract.seedCount();
    console.log(result);
  }
);

task("proteinAtIndex", "Returns the NFT ID at the given index.")
  .addParam("index", "The index value.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);

    const result = await contract.getProteinAtIndex(taskArgs.index);
    console.log(result);
  });
task("seedAtIndex", "Returns the seed at the given index.")
  .addParam("index", "The index value.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);

    const result = await contract.seedAtIndex(taskArgs.index);
    console.log(result);
  });

task("seedSize", "Get the seed size.").setAction(async (_, hre) => {
  const contract = await getProteinContract(hre);

  const result = await contract.seedSize();
  console.log(`Seed size is ${result}`);
});
task("seedStep", "Get the seed step.").setAction(async (_, hre) => {
  const contract = await getProteinContract(hre);

  const result = await contract.seedStep();
  console.log(`Seed step is ${result}`);
});

task("updateSeedSize", "Set a new value for the seed size.")
  .addParam("size", "The size.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);

    await contract.updateSeedSize(parseInt(taskArgs.size));
  });
task("updateSeedStep", "Set a new value for the seed step.")
  .addParam("step", "The step.")
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);

    await contract.updateSeedStep(parseInt(taskArgs.step));
  });

/* HELPERS */
task("splitWord", "Split a word in multiple segments.")
  .addParam("word", "The word")
  .addOptionalParam("size", "The size of the word.", "3")
  .addOptionalParam(
    "step",
    "Step size is the offset used for each next word.",
    "1"
  )
  .addOptionalParam(
    "forcesize",
    "Forces the last segment to have the given size.",
    "false"
  )
  .setAction(async (taskArgs, hre) => {
    const contract = await getProteinContract(hre);
    const { word, size, step, forcesize } = taskArgs;

    const result = await contract.splitWord(
      word,
      parseInt(size),
      parseInt(step),
      eval(forcesize)
    );
    console.log(result);
  });
