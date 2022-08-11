//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { toBillion } = require("./math");

const reportBatchStart = (
  amountEntries,
  batchSize,
  words = ["entry", "entries"]
) => {
  const amountTransactions = Math.ceil(amountEntries / batchSize);

  console.log(`Amount: ${amountEntries} ${words[0]}s.`);
  console.log(
    `Amount of transactions necessary: ${amountTransactions} transactions.`
  );
  console.log(`Batch size: ${batchSize} ${words[0]}s per transaction.\n`);

  return amountTransactions;
};

const reportBatch = (
  transactionNumber,
  amountTransactions,
  amountEntries,
  batchSize,
  batchGas,
  totalGas
) => {
  console.log(
    `${transactionNumber}/${amountTransactions}\t${
      transactionNumber == amountTransactions
        ? amountEntries
        : transactionNumber * batchSize
    }/${amountEntries}\t${batchGas}/${totalGas}`
  );
};

const reportGas = (
  amountEntries,
  gasAmount,
  amountTransactions,
  words = ["entry", "entries"]
) => {
  const avgPerTransaction = gasAmount / amountTransactions;
  const batchSize = Math.round(amountEntries / amountTransactions);

  console.log(
    `\nUsed ${gasAmount} gas (${toBillion(
      gasAmount,
      3
    )} B) across ${amountTransactions} transactions for ${amountEntries} ${
      amountEntries > 1 ? words[1] : words[0]
    }!`
  );

  if (amountEntries > 1) {
    console.log(
      `An average of ${
        Math.round(avgPerTransaction * 100) / 100
      } gas per transaction for ${batchSize} ${
        batchSize > 1 ? words[1] : words[0]
      }, making it ~${
        Math.round((avgPerTransaction / batchSize) * 100) / 100
      } gas per ${words[0]}.`
    );
  }
};

module.exports = {
  reportBatchStart,
  reportBatch,
  reportGas,
};
