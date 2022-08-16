const { getStringsFactory, getQueryFactory } = require("../../helpers/web3");
const { libraries } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  let stringsLibraryAddress = libraries.strings.address;

  if (!stringsLibraryAddress) {
    const Strings = await getStringsFactory(hre);
    const strings = await Strings.deploy();
    await strings.deployed();

    stringsLibraryAddress = strings.address;
  }

  const QueryFactory = await getQueryFactory(hre, {
    libraries: {
      Strings: stringsLibraryAddress,
    },
  });
  const query = await QueryFactory.deploy();

  await query.deployed();

  console.log();
  console.log(`Query contract has been deployed!`);
  console.log(`Address: ${query.address}`);
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
