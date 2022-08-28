const {
  getStringsFactory,
  getQuerySemiBlastFactory,
  getStructsFactory,
} = require("../../helpers/web3");
const { libraries } = require("../../proteins.config");
const hre = require("hardhat");

async function main() {
  let stringsLibraryAddress = libraries.strings.address;
  let structsLibraryAddress = libraries.structs.address;

  if (!stringsLibraryAddress) {
    const Strings = await getStringsFactory(hre);
    const strings = await Strings.deploy();
    await strings.deployed();

    stringsLibraryAddress = strings.address;
  }

  if (!structsLibraryAddress) {
    const Structs = await getStructsFactory(hre);
    const structs = await Structs.deploy();
    await structs.deployed();

    structsLibraryAddress = structs.address;
  }

  const QuerySemiBlastFactory = await getQuerySemiBlastFactory(hre, {
    libraries: {
      Strings: stringsLibraryAddress,
      Structs: structsLibraryAddress,
    },
  });
  const querySemiBlast = await QuerySemiBlastFactory.deploy();

  await querySemiBlast.deployed();

  console.log();
  console.log(`QuerySemiBlast contract has been deployed!`);
  console.log(`Address: ${querySemiBlast.address}`);

  if (!libraries.strings.address) {
    console.log();
    console.log(`Strings Library has been deployed!`);
    console.log(`Address: ${stringsLibraryAddress}`);
  }

  if (!libraries.structs.address) {
    console.log();
    console.log(`Structs Library has been deployed!`);
    console.log(`Address: ${structsLibraryAddress}`);
  }

  if (!libraries.strings.address || !libraries.structs.address) {
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
