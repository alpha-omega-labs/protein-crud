#!/usr/bin/awk -f

BEGIN{
    l["A"] = 0;
    l["R"] = 1;
    l["N"] = 2;
    l["D"] = 3;
    l["C"] = 4;
    l["Q"] = 5;
    l["E"] = 6;
    l["G"] = 7;
    l["H"] = 8;
    l["I"] = 9;
    l["L"] = 10;
    l["K"] = 11;
    l["M"] = 12;
    l["F"] = 13;
    l["P"] = 14;
    l["S"] = 15;
    l["T"] = 16;
    l["W"] = 17;
    l["Y"] = 18;
    l["V"] = 19;
    l["B"] = 20;
    l["J"] = 21;
    l["Z"] = 22;
    l["X"] = 23;
    l["U"] = 24;

    amino_acid[0] = "A";
    amino_acid[1] = "C";
    amino_acid[2] = "D";
    amino_acid[3] = "E";
    amino_acid[4] = "F";
    amino_acid[5] = "G";
    amino_acid[6] = "H";
    amino_acid[7] = "I";
    amino_acid[8] = "K";
    amino_acid[9] = "L";
    amino_acid[10] = "M";
    amino_acid[11] = "N";
    amino_acid[12] = "P";
    amino_acid[13] = "Q";
    amino_acid[14] = "R";
    amino_acid[15] = "S";
    amino_acid[16] = "T";
    amino_acid[17] = "V";
    amino_acid[18] = "W";
    amino_acid[19] = "Y";
    amino_acid[20] = "B";
    amino_acid[21] = "J";
    amino_acid[22] = "U";
    amino_acid[23] = "X";
    amino_acid[24] = "Z";
    
    seed_size=w ? w : 3;
    base_length= base ? base : 20;
    maxNFT = max ? max : 1400;
    nft_id=1;
    indexer=1;
    counter=0;
    nft_counter=1;
    indexer_pointer=0;

    system("mkdir seed_size_"seed_size""(unique_id==1 ? "_unique" : "")" 2>&-");

    amino_start=amino_start_number(seed_size);
    amino_end=base_length**seed_size + amino_start;
    amino_count=1;

    for(i = amino_start; i < amino_end; i++) {
        amino_sorted[amino_count] = number_to_amino(i);
        amino_count++;
    }
} 

function amino_start_number(word_size) {
    start_value = 0;

    while(word_size != 0) {
      word_size--;
      start_value = start_value + (base_length**(word_size));
    }

    return start_value;
}

function number_to_amino(number) {
    amino="";

    while (number > 0) {
      t = (number - 1) % base_length;
      amino = amino_acid[t]""amino;
      number = int((number - t) / base_length);
    }

    return amino;
}

function print_result() {    
    output_folder = "./seed_size_"seed_size""(unique_id==1 ? "_unique" : "");
    output_file = output_folder"/seed_"seed_size"_structs_"max"_"indexer".txt";

    if(unique_id) {
        total_length=(base_length)^(seed_size);
        arr_str = "[";

        for(y=0;y < total_length;y++) {
            arr_str=arr_str"["arr[y]"]"; 
            
            if(y != (total_length - 1)) {
                arr_str=arr_str","
            }
        }

        arr_str=arr_str"]";
        print arr_str > output_file;
    } else {
        if(no_sort) {
            seed_count = 1;
            n = length(arr);

            for (seed_k in arr) {
                arr_str=(seed_count == 1 ? "{" : "")"\""seed_k"\":["arr[seed_k]"]"(seed_count < n ? "," : "}"); 
                print arr_str > output_file;
                seed_count++;
            }
        } else {
            n = length(arr);
            seed_count = 0;

            for(i = 1; i <= amino_count; i++) {
                seed_k=amino_sorted[i];
                seed_exists = arr[seed_k];

                if(seed_exists || seed_count >= n) seed_count++;

                last_round = seed_count == n;

                arr_str=(i == 1 ? "{" : "")(seed_exists ? "\""seed_k"\":["arr[seed_k]"]" : "")(seed_count < n && seed_exists ? "," : "")(last_round ? "}" : ""); 
                if(seed_exists || last_round) print arr_str > output_file;
            }
        }

    }
    
    delete arr;
    indexer_pointer=0;
    counter = 0;
    indexer++;
} 

function print_to_file(str) {
    print str > "./seed_size_"seed_size"/indexer_array"indexer".txt";
}

function letter_to_index(lett, ind) {
    return (base_length)^(seed_size - ind - 1) * l[lett];
} 

NF{
    split($0, a, ",");

    if(nft_id != a[1]) {
        indexer_pointer += (seed_size - 1);
    } 
    
    nft_id=a[1];
    name=a[2];
    split(a[3], b, "\"");
    description=b[2];
    description_length=length(description);
    words_possible=description_length-seed_size+1;
    local_pointer=0;
    

    for(j=0;j < words_possible; j++){
        seed_index=0;
        seed = substr(description, j+1, seed_size);

        if(unique_id) {
            if(seed in seed_arr) {
                seed_index = seed_arr[seed];
            } else {
                for(k=j; k < (j + seed_size); k++) {
                    letter=substr(description,k+1, 1);
                    letter_key = letter""(k-j);
                    if(letter_key in letter_arr) {
                        letter_index = letter_arr[letter_key];
                    } else {
                        letter_index = letter_to_index(letter,k-j);
                        letter_arr[letter_key] = letter_index;
                    }
                    seed_index+=letter_index;
                }

                seed_arr[seed] = seed_index;
            }
        } else {
            
        }
        
        # print "INDEXER="indexer" NFTID="nft_id" NFT_INDEXER_INDEX="(nft_id-1)%maxNFT " NAME="name" SEED="seed" SEED_UNIQUE_NUMBER="seed_index " POS_IN_SEQUENCE="local_pointer" POS_IN_INDEXER_SEQUENCE="indexer_pointer > "./seed_size_"seed_size"/indexer_"indexer".txt";
        if(counter >= maxNFT) {
            print_result();
        }

        if(nft_counter != nft_id) {
            print "It seems that there's a gap in the NFTs, all NFTs must be sorted for this to work. NFT counter expected: "nft_counter" but got "nft_id" instead.";
        }
        
        pos_obj = relative ? indexer_pointer : "{\"nftId\":"(nft_id-1)%(maxNFT) + 1",\"position\":"local_pointer"}";
        if(unique_id) {
            arr[seed_index] = (arr[seed_index] ? arr[seed_index]"," : "")pos_obj;
        } else {
            arr[seed] = (arr[seed] ? arr[seed]"," : "")pos_obj;
        }
        
        local_pointer++;
        indexer_pointer++;
    }

    counter++;
    nft_counter++;
}

END{
    print_result();
}

# awk 'function letter_to_index(lett, ind) {return (base_length)^(seed_size - ind - 1) * l[lett];} BEGIN{l["A"] = 0;l["R"] = 1;l["N"] = 2;l["D"] = 3;l["C"] = 4;l["Q"] = 5;l["E"] = 6;l["G"] = 7;l["H"] = 8;l["I"] = 9;l["L"] = 10;l["K"] = 11;l["M"] = 12;l["F"] = 13;l["P"] = 14;l["S"] = 15;l["T"] = 16;l["W"] = 17;l["Y"] = 18;l["V"] = 19;l["B"] = 20;l["J"] = 21;l["Z"] = 22;l["X"] = 23;l["U"] = 24;base_length=25;seed_size=6; maxNFT = 1400; nft_id=1; indexer=1; counter=0;indexer_pointer=0;system("mkdir seed_size_"seed_size" 2>&-");} NF{split($0, a, ","); if(nft_id != a[1]) {indexer_pointer+= (seed_size - 1)} nft_id=a[1]; name=a[2]; split(a[3], b, "\""); description=b[2]; description_length=length(description); words_possible=description_length-seed_size+1; local_pointer=0; for(j=0;j < words_possible; j++) {seed_index=0; seed=""; for(k=j; k < (j + seed_size); k++) {letter=substr(description,k+1, 1); seed=seed""letter; seed_index+=letter_to_index(letter,k-j);}; if(counter >= maxNFT) {indexer_pointer=0; counter = 0;indexer++;}; print "INDEXER="indexer" NFTID="nft_id" NFT_INDEXER_INDEX="(nft_id-1)%maxNFT " NAME="name" SEED="seed" SEED_UNIQUE_NUMBER="seed_index " POS_IN_SEQUENCE="local_pointer" POS_IN_INDEXER_SEQUENCE="indexer_pointer > "./seed_size_"seed_size"/indexer_"indexer".txt"; local_pointer++; indexer_pointer++;}; counter++;}' ../nfts.input