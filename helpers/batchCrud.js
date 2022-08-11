//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const fs = require("fs/promises");
const { getIndexerContract } = require("./web3");
const { reportBatchStart, reportBatch, reportGas } = require("./reporter");

module.exports = async (file, batchSize, words, callback) => {
  const res = await fs.readFile(file, { encoding: "utf8" });

  const data = JSON.parse(res);
  const keys = Object.keys(data);
  const dataLength = keys.length;

  const amountTransactions = reportBatchStart(dataLength, batchSize, words);

  const contract = await getIndexerContract(hre);

  console.time("timer");
  let totalGas = 0;

  const callToContract = async (index = 0) => {
    const insertCall = await callback(contract, index, data, keys);

    const receipt = insertCall ? await insertCall.wait() : false;
    const gasCost = receipt ? receipt.gasUsed : 0;
    totalGas = totalGas + parseInt(gasCost);

    if (gasCost != 0) {
      reportBatch(
        index + 1,
        amountTransactions,
        dataLength,
        batchSize,
        gasCost,
        totalGas
      );
    }
  };

  for (let i = 0; i < amountTransactions; i++) {
    await callToContract(i);
  }

  console.timeEnd("timer");

  reportGas(dataLength, totalGas, amountTransactions, words);
};
