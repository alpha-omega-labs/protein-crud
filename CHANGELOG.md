## SEMI-BLAST ERA

#### 1.2.0 (2022-08-10)

- Created libraries instead of heaping everything into one contract.
- Contract use case separated (Indexers, Query contract, etc.).
- Deletion for the CRUDs fixed and optimized.
- Various scripts created and renamed.
- Bugfixes.
- Refactored and abstraction of code.
- Config file changed alot.

#### 1.1.0 (2022-08-03)

- Added The AWK Files.
- Added the ability to query smaller words.

- MAJOR IMPROVEMENT: An algorithm inspired by the blast protocol has been implemented; massively improving the speed for our queries. It has a similar approach of cutting all sequences into short segments and puzzling them together, but we only return the segments matching the queried string exactly. Unlike blast, where we use a scoring matrix to 'judge' a fragment, or where (some versions) allow for gaps to be present in-between seeds. The drawback with this semi-blast approach is that we discard every sequence that isn't an exact match with our query, while blast could also included similar proteins in its search results (if they score an E-value above a certain threshold). This will probably be implemented at some point in the future.
- A CRUD for Seeds has been added. This enables us to store all possible n-sized segments available in our imported proteins (where n = a small number like 3, 4, 5 or 6). Currently it only has been tested with 3 letter words, but ideally a longer word would improve the algorithm's speed (in exchange for storage space).
- Created a proteins.config.js file and removed the .env file. Now the contract address has to be configured in this file. This config file includes more options, like setting the batch size for importing or changing the seed size for the seed CRUD.
- The Owner contract has more functionality now. For instance, we're now able to create and remove admins allowing others to interact with the C, U and D of the CRUDs.
- Fixed the gas used issue in the addProteins script. Now it waits for the transaction receipt before trying to calculate the gas used.
- The protein .txt files are now in the subfolder ./datasets/proteins/.
- Seed structs of different sizes have been added to ./datasets/seeds/.
- Renamed the addProteins script to insertProteins, queryProtein to naiveQuery, getProteinCount to proteinCount and getProteinAtIndex to proteinAtIndex.
- An insertSeeds.js script has been added (should be run after deployment in order for the new algorithm to work).
- Tasks 'semiBlastQuery', 'seedCount', 'seedAtIndex', 'updateSeedSize', 'updateSeedStep' and 'getSeed' added.
- Abstracted and refactored the insert-script (saved in ./helper/insertion.js). The insertSeeds and insertProteins scripts use this script as a basis.
- Created some helper functions.
- Restructured all contracts and set the Solidity version to 0.8.12.
- Refactored code.
- Added comments.
- Updated README.md.

## NAIVE ERA

#### 1.0.2 (2022-08-02)

- Created an insertProteins function in the ProteinCrud contract, we can now add multiple proteins at once.
- Owner contract added. The ProteinCrud contract inherits its functionality, enabling it to prevent addresses, other than the owner, from accessing sensitive data/functions.
- Added the Genesis network to the hardhat config file.
- Revisited the addProteins.js script, it now shows more detailed analytics when adding proteins.

#### 1.0.1 (2022-08-01)

- Renamed PDBID to ID.
- Added more datasets, of sizes 10, 100, 1000, 5000, 10000 and 104059.
- More tasks added (getProteinCount, getProtein, getProteinAtIndex found in the hardhat.config.js file).
- Added an extra parameter to the insertProtein function (bypassRevert) to prevent transactions to be reverted when adding a protein that already exists.

#### 1.0.0 (2022-08-01)

- Added Solidity Contracts.
- Two scripts for contract deployment and protein insertion.
- One task for querying the protein strings based on PDBID or SEQUENCE.
- A dataset of 100 proteins.
