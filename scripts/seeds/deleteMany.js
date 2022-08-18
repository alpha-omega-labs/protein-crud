//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");
const { getIndexerSeedContract } = require("../../helpers/web3");
const hre = require("hardhat");

const {
  bypassRevert,
  hardDelete,
  manyScripts,
} = require("../../proteins.config");

async function main() {
  batchCrud(
    await getIndexerSeedContract(hre),
    manyScripts.files.seedsDeleteMany,
    manyScripts.seedsPerBatch,
    ["seed", "seeds"],
    async (contract, i, _, keys) => {
      const deleteManySeeds = await contract.deleteManySeeds(
        keys.slice(
          i * manyScripts.seedsPerBatch,
          (i + 1) * manyScripts.seedsPerBatch
        ),
        hardDelete,
        bypassRevert
      );

      return deleteManySeeds;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
