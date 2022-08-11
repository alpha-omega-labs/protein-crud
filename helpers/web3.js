//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { contracts, libraries } = require("../proteins.config");

const getIndexerContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.indexer.name,
    contracts.indexer.address
  );

  return contract;
};

const getQueryContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.query.name,
    contracts.query.address
  );

  return contract;
};

const getIndexerFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.indexer.name,
    config
  );

  return Factory;
};

const getQueryFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.query.name,
    config
  );

  return Factory;
};

const getStringsLibrary = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    libraries.strings.name,
    libraries.strings.address
  );

  return contract;
};

const getStructsLibrary = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    libraries.structs.name,
    libraries.structs.address
  );

  return contract;
};

module.exports = {
  getIndexerContract,
  getQueryContract,
  getIndexerFactory,
  getQueryFactory,
  getStringsLibrary,
  getStructsLibrary,
};
