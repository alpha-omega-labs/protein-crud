//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { getIndexerProteinContract } = require("../../helpers/web3");
const { reportGas } = require("../../helpers/reporter");
const { hardDelete } = require("../../proteins.config");
const hre = require("hardhat");

// May result in an out-of-gas error if the protein size is too big.
// Use deleteMany instead if this occurs.
async function main() {
  const contract = await getIndexerProteinContract(hre);

  const deleteAllProteins = await contract.deleteAllProteins(hardDelete);
  const receipt = await deleteAllProteins.wait();
  reportGas(1, receipt.gasUsed, 1);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
