//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");

const { bypassRevert, manyScripts } = require("../../proteins.config");

async function main() {
  batchCrud(
    manyScripts.files.proteinsInsertMany,
    manyScripts.proteinsPerBatch,
    ["protein", "proteins"],
    async (contract, i, data) => {
      const batch = data.filter(
        (_, j) =>
          j >= i * manyScripts.proteinsPerBatch &&
          j < (i + 1) * manyScripts.proteinsPerBatch
      );

      const insertManyProteins = await contract.insertManyProteins(
        batch.map((protein) => protein.nftId),
        batch.map((protein) => protein.id),
        batch.map((protein) => protein.sequence),
        batch.map((protein) => protein.ipfs),
        bypassRevert
      );

      return insertManyProteins;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
