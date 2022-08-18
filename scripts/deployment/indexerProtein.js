const { getIndexerProteinFactory } = require("../../helpers/web3");
const { contracts } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  const IndexerProteinFactory = await getIndexerProteinFactory(hre);
  const indexerProtein = await IndexerProteinFactory.deploy(
    contracts.indexerProtein.indexerGroup,
    contracts.indexerProtein.indexerId
  );

  await indexerProtein.deployed();

  console.log();
  console.log(`IndexerProtein contract has been deployed!`);
  console.log(`Address: ${indexerProtein.address}`);
  console.log();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
