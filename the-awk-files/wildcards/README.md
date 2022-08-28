# Wildcards AWK

This will generate the wildcard structs as seen in the ./datasets/wildcards folder.

## Getting started

Apply the awk in this folder to the nfts.input file in the parent folder.
</br>e.g. this will generate 1000 wildcards with a seed size of 4 per .txt file:
</br>`awk -v w=4 -v max=1000 -f wildcards.awk ../nfts.input`
</br>
</br>

### Variables

- `max`: changes the amount of seeds per file. Default: `1400`.
- `max_position_size`: change the amount of positions a seed may hold. Default: `0` (all).
- `seed_to_print`: if you only want to print one specific seed, e.g. "AAE". Default: "" (all).
- `cap`: this caps the amount of .txt files awk will export. Default: `0` (all).
- `w`: changes the seed size, default: `3`.
- `relative`: setting this to `1` would give a relative position for each word, example: "AAA": [0, 230, 1000, 15005].
  It's the indices you'd get if you'd "append" all sequences together into one gigantic string.
  `0` would give the NFTID plus the index (inside this protein's sequence). Default: `0` (what we use in this repo).
- `base`: change the amount of amino acids (so the protein alphabet) that are available. Default: `20` (what we use in this repo).
- `no_sort`: setting this to `1` will disable sorting. Default: `0`.

### Result

The resulting .txt files can be found in a folder named after the wildcard size (e.g. wildcard_size_3, wildcard_size_4, etc.).
