//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const insertion = require("../helpers/insertion");

const {
  totalProteinAmount,
  proteinsPerBatch,
  bypassRevert,
} = require("../proteins.config");

async function main() {
  insertion(
    `datasets/proteins/protein_structs_${totalProteinAmount}.txt`,
    proteinsPerBatch,
    "protein",
    async (contract, i, data) => {
      const batch = data.filter(
        (_, j) => j >= i * proteinsPerBatch && j < (i + 1) * proteinsPerBatch
      );

      const insertProteins = await contract.insertProteins(
        batch.map((protein) => protein.nftId),
        batch.map((protein) => protein.id),
        batch.map((protein) => protein.sequence),
        batch.map((protein) => protein.ipfs),
        bypassRevert
      );

      return insertProteins;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
