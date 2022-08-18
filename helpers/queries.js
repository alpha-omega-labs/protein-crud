const { contracts } = require("../proteins.config");

// Helper function
const queryProtein = async (contract, queryInput, queryOptions, format) => {
  let result;
  let data;

  switch (format) {
    case "id":
      result = await contract.queryIds(
        queryInput,
        queryOptions,
        contracts.indexerProtein.address
      );

      data = { data: result.ids, count: result.proteinCount };
      break;
    case "nft":
      result = await contract.queryNftIds(
        queryInput,
        queryOptions,
        contracts.indexerProtein.address
      );

      data = { data: result.nftIds, count: result.proteinCount };
      break;
    case "sequence":
      result = await contract.querySequences(
        queryInput,
        queryOptions,
        contracts.indexerProtein.address
      );

      data = { data: result.sequences, count: result.proteinCount };
      break;
    case "ipfs":
      result = await contract.queryIpfsHashes(
        queryInput,
        queryOptions,
        contracts.indexerProtein.address
      );

      data = { data: result.ipfsHashes, count: result.proteinCount };
      break;
    default:
      result = await contract.queryProteins(
        queryInput,
        queryOptions,
        contracts.indexerProtein.address
      );

      data = { data: result.proteins, count: result.proteinCount };
  }

  return data;
};

module.exports = { queryProtein };
