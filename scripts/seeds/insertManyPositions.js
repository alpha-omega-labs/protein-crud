//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");
const { getIndexerSeedContract } = require("../../helpers/web3");

const { manyScripts } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  batchCrud(
    await getIndexerSeedContract(hre),
    manyScripts.files.seedsInsertManyPositions,
    manyScripts.seedsPerBatch,
    ["seed", "seeds"],
    async (contract, i, data, keys) => {
      const seeds = keys.slice(
        i * manyScripts.seedsPerBatch,
        (i + 1) * manyScripts.seedsPerBatch
      );

      console.log("======================================================");
      const seedsPositions = seeds.map((seed) => {
        console.log(
          seed + " will insert " + data[seed].length + " positions..."
        );
        return data[seed];
      });
      console.log();

      const insertManySeedPositions = await contract.insertManySeedPositions(
        seeds,
        seedsPositions
      );

      return insertManySeedPositions;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
