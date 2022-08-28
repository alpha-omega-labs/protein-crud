## Proteins AWK

This will generate the protein structs as seen in the ./datasets/proteins folder.

## Getting started

Apply the awk in this folder to the nfts.input file in the parent folder.
</br>e.g. this will generate 1000 proteins per .txt file:
</br>`awk -v max=1000 -f proteins.awk ../nfts.input`

### Variables

- `max`: changes the amount of proteins per file. Default `1400`.

### Result

The resulting .txt files can be found in the output-folder.
