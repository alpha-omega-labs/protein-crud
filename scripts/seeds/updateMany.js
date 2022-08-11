//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");

const { bypassRevert } = require("../../proteins.config");

async function main() {
  batchCrud(
    manyScripts.files.seedsUpdateMany,
    manyScripts.seedsPerBatch,
    ["seed", "seeds"],
    async (contract, i, data, keys) => {
      const seeds = keys.slice(
        i * manyScripts.seedsPerBatch,
        (i + 1) * manyScripts.seedsPerBatch
      );
      const seedsPositions = seeds.map((seed) => data[seed]);

      const updateManySeeds = await contract.updateManySeeds(
        seeds,
        seedsPositions,
        bypassRevert
      );

      return updateManySeeds;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
