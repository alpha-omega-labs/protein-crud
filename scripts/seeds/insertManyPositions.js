//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");

const { manyScripts } = require("../../proteins.config");

async function main() {
  batchCrud(
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
