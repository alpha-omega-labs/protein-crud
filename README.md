# Protein CRUD (This readme is outdated!)
A basic CRUD for Proteins with string query functionality.

This has been built within the Hardhat environment and is merely a basis for querying protein sequences and PDBID/ACCESSIONs.

## Getting Started
### 1. Installation
To get started, install all dependencies using a package manager of your choosing. For instance: <code>yarn install</code> or <code>npm install</code>.

### 2. Run Test Node
After having installed all dependencies use <code>npx hardhat node</code> to locally run a test environment where we could deploy our <b>ProteinQuery</b> contract to.
You could also use a different network of your choosing, which you could configure in the <b>hardhat.config.js</b>-file (for more info on this: https://hardhat.org/hardhat-runner/docs/config).

### 3. Deployment
Now after having a node up and running we'll have to deploy our contract using <code>npx hardhat run scripts/deploy.js</code>. Which will return the contract address, found in your terminal.

#### 3.1 Contract Address
After deploying, add the contract address to the <b>proteins.config.js</b> in the root folder, assign the address to the key named <b>contractAddress</b>.

### 4. Adding the Proteins
So our contract's deployed, we now just have to add our proteins to the contract's storage. The script <b>addProteins.js</b> will help with this. It's a simple Javascript that reads data from a <b>.txt file</b> located in the <b>datasets</b>-folder. These files contain the first n proteins from the Genesis L1 dataset (https://datasetnft.org/), where 104059 is the file containing all proteins. Change which dataset size you wish to use by editing this in the <b>proteins.config.js</b> file.
</br>
</br>
Use: <code>npx hardhat run scripts/insertProteins.js</code> to run the script.

#### 4.1 Adding the Seeds (Optional, but recommended)
Since version 1.1.0 a new way to query was added (semi-blast), which depends on the insertion of short seeds. Basically, these seeds are created by cutting all sequences into tiny n-sized words, where n could be adjusted by interacting with the contract. Each short sequence holds information on where this segment could be found.
</br>
</br>
Use: <code>npx hardhat run scripts/insertSeeds.js</code> to run the script. Do know that this is costly and takes longer than the proteins script (optimization is needed).

### 5. Querying the Proteins
We can finally query our dataset of proteins! I've written a task in the <b>hardhat.config.js</b>-file which calls the function <i>naiveQuery</i> and one calling <i>semiBlastQuery</i> (only works with seeds added) present in <b>contracts/ProteinQuery.sol</b>. It enables us to query by <i>sequence OR ID OR both (an exclusive query)</i>. 
</br>
</br>
To run this task, use:
</br>
<code>npx hardhat naiveQuery --id "your_id_query" --sequence "your_sequence_query" --exclusive "true/false"</code>
</br>
</br>
OR
</br>
</br>
<code>npx hardhat semiBlastQuery --sequence "your_sequence_query" --casesensitive "true/false"</code> <i>alot faster!</i>

#### 5.1 Flags
All flags are optional. So if you want to, let's say, only search for id's containing "1A", you'd only set the flag <code>--id</code> to <code>"1A"</code>. If you wanted to search for sequences containing "AAA" but also contain "1A" in its id, you'd have to set both flags to the corresponding values AND set <code>--exclusive</code> to <code>"true"</code>. This, because a value of <code>"false"</code> would return all sequences that match "AAA" AND all sequences that have a id containing "1A", while in this particular case we'd only want the values where both queries are true.
</br>
</br>
The default values for each flag, if omitted, are:

`--id`: ""

`--sequence`: ""

`--exclusive`: "false"

#### 5.2 Returned Value
The query returns an object containing an array with all found proteins and an integer stating the amount of results found: <code>{proteins: Array of ProteinStruct, proteinsFound: uint}</code> where <i>ProteinStruct</i> is an object of the format <code>{nftId: uint, id: string, sequence: string}</code>.
</br>
</br>
So, for instance, getting the sequence of the third protein in the returned value, in Javascript, would look like this: <code>result.proteins[2].sequence</code>. See the <i>naiveQuery</i>-task in <b>hardhat.config.js</b> for a working example on how to loop through all the query results.

## Remarks
- ~~Solidity is not the most optimal when it comes to handling strings. Especially when it comes to larger strings. Therefore ideas like pre-processing the database and storing smaller segments are possible routes to explore to get this working faster (which I'm currently working on).~~ - included since version 1.1.0.
- ~~The searches are <i>case-sensitive</i> at the moment. This could be solved upon insertion of the proteins (but would discard whether the letters were lower or uppercase) or solved by adding an extra toLowerCase function in Solidity. But then again, Solidity is not optimal for string manipulation and this would degrade performance.~~ - included since version 1.2.2.
- There's a limitation in Solidity where `memory arrays` can't be dynamic in size. And since we cannot know beforehand how many results a query will have, we temporarily store the results in an array of size n, with n = the total amount of proteins. To prevent returning an array with a bunch of empty values, we copy the query results, in the temporary array, to a smaller sized array in the last line of the <i>naiveQuery</i> function. But, ofcourse this is an extra step, degrading the speed of our queries. More info about this issue can be found in the contract.
</br>
</br>
- Tousuke (ZEN - https://twitter.com/KeymasterZen)
