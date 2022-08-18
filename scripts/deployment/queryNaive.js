const {
  getStringsFactory,
  getQueryNaiveFactory,
} = require("../../helpers/web3");
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

  const QueryNaiveFactory = await getQueryNaiveFactory(hre, {
    libraries: {
      Strings: stringsLibraryAddress,
    },
  });
  const queryNaive = await QueryNaiveFactory.deploy();

  await queryNaive.deployed();

  console.log();
  console.log(`QueryNaive contract has been deployed!`);
  console.log(`Address: ${queryNaive.address}`);
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
