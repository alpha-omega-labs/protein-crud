## Proteins AWK

This will generate the protein structs as seen in the ./datasets/proteins folder.

Apply the awk in this folder to the nfts.input file in the parent folder (../nfts.input).
`awk -f proteins.awk ../nfts.input`

You could also change the amount of proteins per file by adding a `max` variable to the awk.

This example will generate 1000 proteins per .txt file.
`awk -v max=1000 -f proteins.awk ../nft.input`

The result can be found in the output-folder.
