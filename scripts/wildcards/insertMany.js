//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");
const { getIndexerSeedContract } = require("../../helpers/web3");

const { bypassRevert, manyScripts } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  batchCrud(
    await getIndexerSeedContract(hre),
    manyScripts.files.wildcardsInsertMany,
    manyScripts.wildcardsPerBatch,
    ["wildcard", "wildcards"],
    async (contract, i, data, keys) => {
      const wildcards = keys.slice(
        i * manyScripts.wildcardsPerBatch,
        (i + 1) * manyScripts.wildcardsPerBatch
      );

      console.log("======================================================");
      const wildcardSeeds = wildcards.map((wildcard) => {
        console.log(
          wildcard + " will insert " + data[wildcard].seeds.length + " seeds..."
        );
        return data[wildcard].seeds;
      });
      const wildcardCounts = wildcards.map((wildcard) => {
        // console.log(
        //   wildcard + " has a count of " + data[wildcard].count + "..."
        // );
        return data[wildcard].count;
      });
      console.log();

      const insertManyWildcards = await contract.insertManyWildcards(
        wildcards,
        wildcardSeeds,
        wildcardCounts,
        bypassRevert
      );

      return insertManyWildcards;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
