//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");
const { getIndexerProteinContract } = require("../../helpers/web3");
const hre = require("hardhat");

const {
  bypassRevert,
  hardDelete,
  manyScripts,
} = require("../../proteins.config");

async function main() {
  batchCrud(
    await getIndexerProteinContract(hre),
    manyScripts.files.proteinsDeleteMany,
    manyScripts.proteinsPerBatch,
    ["protein", "proteins"],
    async (contract, i, data) => {
      const deleteManyProteins = await contract.deleteManyProteins(
        data
          .filter(
            (_, j) =>
              j >= i * manyScripts.proteinsPerBatch &&
              j < (i + 1) * manyScripts.proteinsPerBatch
          )
          .map((protein) => protein.nftId),
        hardDelete,
        bypassRevert
      );

      return deleteManyProteins;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
