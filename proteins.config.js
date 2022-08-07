module.exports = {
  // The name of the contract to deploy.
  contractName: "ProteinQuery",

  // The address to where your contract has been deployed.
  contractAddress: "0x5fbdb2315678afecb367f032d93f642f64180aa3",

  // How many proteins does our dataset consist of (this value is also used for seeds).
  // NOTE: check the ./datasets folder to see which dataset sizes are available.
  totalProteinAmount: 100,

  // How many proteins inserted per transaction
  proteinsPerBatch: 50,

  // How many seeds to insert per transaction
  seedsPerBatch: 20,

  // If you change this value, make sure to also change it in the SeedCrud contract (both seedSize and seedStep), or
  // if the contract is already deployed, call: updateSeedSize and updateSeedStep (strongly adviced to keep both equal in value)
  // NOTE: check the ./datasets folder to see which dataset sizes are available.
  seedSize: 3,

  // Normally, inserting the same protein or seed twice would revert the tx, returning an error stating it already exists.
  // However setting bypassRevert to true will prevent Solidity from returning an error message and ignores the request.
  // So if importing failed, but you can't be bothered with figuring out from which ID you should continue, turn this on.
  // Do have in mind that this consumes more gas, for the tx doesn't get reverted!
  bypassRevert: true,
};
