const {
  getIndexerSeedFactory,
  getStringsFactory,
} = require("../../helpers/web3");
const { libraries, contracts } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  let stringsLibraryAddress = libraries.strings.address;

  if (!stringsLibraryAddress) {
    const Strings = await getStringsFactory(hre);
    const strings = await Strings.deploy();
    await strings.deployed();

    stringsLibraryAddress = strings.address;
  }

  const IndexerSeedFactory = await getIndexerSeedFactory(hre, {
    libraries: {
      Strings: stringsLibraryAddress,
    },
  });
  const indexerSeed = await IndexerSeedFactory.deploy(
    contracts.indexerSeed.indexerGroup,
    contracts.indexerSeed.indexerId,
    contracts.indexerSeed.seedSize
  );

  await indexerSeed.deployed();

  console.log();
  console.log(`IndexerSeed contract has been deployed!`);
  console.log(`Address: ${indexerSeed.address}`);
  if (!libraries.strings.address) {
    console.log();
    console.log(`Strings Library has been deployed!`);
    console.log(`Address: ${stringsLibraryAddress}`);
    console.log("IMPORTANT: add library addresses to the config file.");
    console.log(
      "This will prevent them from redeploying every time the deploy script is called!"
    );
  }
  console.log();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
