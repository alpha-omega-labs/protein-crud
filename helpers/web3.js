//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { contracts, libraries } = require("../proteins.config");

const getIndexerProteinContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.indexerProtein.name,
    contracts.indexerProtein.address
  );

  return contract;
};

const getIndexerSeedContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.indexerSeed.name,
    contracts.indexerSeed.address
  );

  return contract;
};

const getQuerySemiBlastContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.querySemiBlast.name,
    contracts.querySemiBlast.address
  );

  return contract;
};

const getQueryNaiveContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.queryNaive.name,
    contracts.queryNaive.address
  );

  return contract;
};

const getIndexerSeedFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.indexerSeed.name,
    config
  );

  return Factory;
};

const getIndexerProteinFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.indexerProtein.name,
    config
  );

  return Factory;
};

const getQuerySemiBlastFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.querySemiBlast.name,
    config
  );

  return Factory;
};

const getQueryNaiveFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.queryNaive.name,
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

const getStringsFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    libraries.strings.name,
    config
  );

  return Factory;
};

const getStructsLibrary = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    libraries.structs.name,
    libraries.structs.address
  );

  return contract;
};

const getStructsFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    libraries.structs.name,
    config
  );

  return Factory;
};

module.exports = {
  getIndexerProteinContract,
  getIndexerProteinFactory,
  getIndexerSeedContract,
  getIndexerSeedFactory,
  getQuerySemiBlastContract,
  getQuerySemiBlastFactory,
  getQueryNaiveContract,
  getQueryNaiveFactory,
  getStringsLibrary,
  getStringsFactory,
  getStructsLibrary,
  getStructsFactory,
};
