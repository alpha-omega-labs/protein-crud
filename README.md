# protein-crud

A basic CRUD for Proteins with string query functionality.

This has been built within the Hardhat environment and is merely a basis for querying protein sequences and PDBIDs.

<h2>1. Getting Started</h2>
To get started, install all dependencies using a package manager of your choosing. For instance: <code>yarn install</code> or <code>npm install</code>.

<h3>2. Run Test Node</h3>
After having installed all dependencies use <code>npx hardhat node</code> to locally run a test environment where we could deploy our <b>ProteinQuery</b> contract to.
You could also use a different network of your choosing, which you could configure in the <b>hardhat.config.js</b>-file (for more info on this: https://hardhat.org/hardhat-runner/docs/config).

<h3>3. Deployment</h3>
Now after having a node up and running we'll have to deploy our contract using <code>npx hardhat run scripts/deploy.js</code>. Which will return the contract address, found in your terminal.

<h4>3.1 Contract Address</h4>
After deploying, add the contract address to an environment file (.env-file) in the root folder and assign the address to a variable called <b>CONTRACT_ADDRESS</b>.
A dummy file is already present in this repository, so you could use that one. Just make sure to change the address and remove the `.dummy` extension.

<h3>4. Adding the Proteins</h3>
So our contract's deployed, we now just have to add our proteins to the contract's storage. The script <b>addProteins.js</b> will help with this. It's a simple Javascript that reads in the data in the <b>protein_struct_1.txt</b>-file located in the root-folder. This contains the first 100 proteins from the Genesis L1 dataset (https://molnft.org/).
</br>
</br>
Use: <code>npx hardhat run scripts/addProteins.js</code> to run the script.

<h3>5. Querying the Proteins</h3>
We can finally query our dataset of proteins! I've written a task in the <b>hardhat.config.js</b>-file which calls the function <i>queryProtein</i> present in <b>contracts/ProteinQuery.sol</b>. It enables us to query by <i>sequence OR pdbid OR both (an exclusive query)</i>. 
</br>
</br>
To run this task, use:
<code>npx hardhat queryProtein --pdbid "your_pdbid_query" --sequence "your_sequence_query" --exclusive "true/false"</code>
</br>
</br>
All flags are optional. So if you want to, let's say, only search for pdbid's containing "1A", you'd only set the flag <code>--pdbid</code> to <code>"1A"</code>. If you wanted to search for sequences containing "AAA" but also contain "1A" in its pdbid, you'd have to set both flags to the corresponding values AND set <code>--exclusive</code> to <code>"true"</code>. This, because a value of <code>"false"</code> would return all sequences that match "AAA" AND all sequences that have a pdbid containing "1A", while in this particular case we'd only want the values where both queries are true.
</br>
</br>
The default values for each flag, if omitted, are:

`--pdbid`: ""

`--sequence`: ""

`--exclusive`: "false"

<h4>5.1 Returned Value</h4>
The query returns an object containing an array with all found proteins and an integer stating the amount of results found: <code>{proteins: Array of ProteinStruct, proteinsFound: uint}</code> where <i>ProteinStruct</i> is an object of the format <code>{nftId: uint, pdbId: string, sequence: string}</code>.
</br>
</br>
So, for instance, getting the sequence of the third protein in the returned value, in Javascript, would look like this: <code>result.proteins[2].sequence</code>. See the <i>queryProtein</i>-task in <b>hardhat.config.js</b> for a working example on how to loop through all the query results.

<h3>Remarks</h3>
- Solidity is not the most optimal when it comes to handling strings. Especially when it comes to large strings. Therefore ideas like pre-processing the database and storing smaller segments are possible routes to explore to get this working faster.
</br>
</br>
- The searches are <i>case-sensitive</i> at the moment. This could be solved upon insertion of the proteins (but would discard whether the letters were lower or uppercase) or solve this by adding an extra toLowerCase function in Solidity. But then again, Solidity is not optimal for string manipulation and this would degrade performance.
</br>
</br>
- There's a limitation in Solidity where `memory arrays` can't be dynamic in size. And since we cannot know beforehand how many results a query will have, we temporarily store the results in an array of size n, with n = the total amount of proteins. To prevent returning an array with a bunch of empty values, we copy the query results in the temporary array to a smaller sized array in the last line of the <i>queryProtein</i> function. But, ofcourse this is an extra step, degrading the speed of our queries. More info is in the contract itself about this issue.
</br>
</br>
- Tousuke (ZEN - https://twitter.com/KeymasterZen)
