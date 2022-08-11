//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { getIndexerContract } = require("../../helpers/web3");
const { reportGas } = require("../../helpers/reporter");
const { hardDelete } = require("../../proteins.config");

// May result in an out-of-gas error if the seed size is too big.
// Use deleteManySeeds instead if this occurs.
async function main() {
  const contract = await getIndexerContract(hre);

  const deleteAllSeeds = await contract.deleteAllSeeds(hardDelete);
  const receipt = await deleteAllSeeds.wait();
  reportGas(1, receipt.gasUsed, 1);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
