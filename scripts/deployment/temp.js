const hre = require("hardhat");
const { getIndexerFactory } = require("../../helpers/web3");
const { libraries, contracts } = require("../../proteins.config");

async function main() {
  let stringsLibraryAddress = libraries.strings.address;

  if (!stringsLibraryAddress) {
    const Strings = await hre.ethers.getContractFactory("Strings");
    const strings = await Strings.deploy();
    await strings.deployed();

    stringsLibraryAddress = strings.address;
  }

  let structsLibraryAddress = libraries.structs.address;

  if (!structsLibraryAddress) {
    const Structs = await hre.ethers.getContractFactory("Structs");
    const structs = await Structs.deploy();
    await structs.deployed();

    structsLibraryAddress = structs.address;
  }

  const IndexerFactory = await getIndexerFactory(hre, {
    libraries: {
      Strings: stringsLibraryAddress,
      Structs: structsLibraryAddress,
    },
  });

  const indexer = await IndexerFactory.deploy();
  // contracts.indexer.indexerId,
  // contracts.indexer.seedSize

  await indexer.deployed();
  console.log(`Protein Query contract has been deployed!`);
  console.log(
    `IMPORTANT: add the contract addresses of the Strings and Structs libraries to the config file. This will prevent them from redeploying every time the deploy script is being called.`
  );
  console.log(`Strings Library: ${stringsLibraryAddress}`);
  console.log(`Structs Library: ${structsLibraryAddress}`);
  console.log(`Indexer Contract: ${indexer.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
