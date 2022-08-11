//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");

const { bypassRevert, manyScripts } = require("../../proteins.config");

async function main() {
  batchCrud(
    manyScripts.files.seedsInsertMany,
    manyScripts.seedsPerBatch,
    ["seed", "seeds"],
    async (contract, i, data, keys) => {
      const seeds = keys.slice(
        i * manyScripts.seedsPerBatch,
        (i + 1) * manyScripts.seedsPerBatch
      );
      const seedsPositions = seeds.map((seed) => data[seed]);

      const insertManySeeds = await contract.insertManySeeds(
        seeds,
        seedsPositions,
        bypassRevert
      );

      return insertManySeeds;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
