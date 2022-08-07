#!/usr/bin/awk -f

function print_array() {
    arr_str="[";
        
    for(x=0;x<maxNFT;x++) {
        if(protein_structs[x]) {
            arr_str = arr_str""protein_structs[x];
        } else {
            arr_str=arr_str"{}";
        }
        
        arr_str=arr_str""(x != maxNFT - 1 ? ","(oneliner == 0 ? "\n" : "") : "");
    } 
    
    arr_str=arr_str"]";
    print arr_str > "./output/protein_structs_"indexer".txt";
    
    delete protein_structs;
    
    counter = 0;
    indexer++;
}

BEGIN{
    maxNFT= max ? max : 1400;
    indexer=1;
    counter=0;
    nft_counter=1;
    system("mkdir output 2>&-");
} 

NF{
    split($0, a, ",");
    nft_id=a[1];
    name=a[2];
    description=a[3];
    ipfs=a[4];
    description_length=length(description);

    if(counter >= maxNFT) {
        print_array();
    }

    if(nft_counter != nft_id) {
        print "It seems that there's a gap in the NFTs, all NFTs must be sorted for this to work. NFT counter expected: "nft_counter" but got "nft_id" instead.";
    }
    
    protein_structs[counter] = "{\"nftId\":"nft_id", \"id\":"name", \"sequence\":"description", \"ipfs\":"ipfs"}";
    counter++;
    nft_counter++;
} 

END{
    print_array();
}

# awk 'function print_array() { array_str="[\n"; for(x=0;x<maxNFT;x++) { if(arr[x]) { array_str = array_str""arr[x]; } else { array_str=array_str"\"\""; } array_str=array_str""(x != maxNFT - 1 ? ",\n" : ""); } array_str=array_str"\n]"; print array_str > "./2-sequences_output/sequences_"indexer".txt"; array_str=""; delete arr; indexer++; counter = 0; } BEGIN{maxNFT = 1400; indexer=1; counter=0; nft_counter=1; system("mkdir 2-sequences_output");} NF{split($0, a, ","); nft_id=a[1]; name=a[2]; description=a[3]; if(counter >= maxNFT) {print_array();} if(nft_counter != nft_id) {print "It seems that there's a gap in the NFTs, all NFTs must be sorted for this to work. NFT counter expected: "nft_counter" but got "nft_id" instead.";} arr[counter] = description; counter++; nft_counter++;} END{ print_array(); }' nfts.input