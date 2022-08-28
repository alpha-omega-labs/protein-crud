#!/usr/bin/awk -f

BEGIN{
    seed_size=w ? w : 3;
    base_length= base ? base : 20;
    maxNFT = max ? max : 1400;
    nft_id=1;
    indexer=1;
    counter=0;
    nft_counter=1;

    system("mkdir wildcard_size_"seed_size" 2>&-");
} 

function print_result() {
  
  for(j = 0; j < length(arr); j++) {
    output_folder = "./wildcard_size_"seed_size;
    output_file = output_folder"/wildcard_"seed_size"_structs_"maxNFT"_"indexer"_"j".txt";
    n = length(arr[j]) - 1;

    seed_count = 1;

    for (seed_k in arr[j]) {
      if(seed_k == 0) {
        continue;
      }
      
      seed_positions_count[curr_seed]++;
      arr_str=(seed_count == 1 ? "{" : "")"\""seed_k"\":{\"count\": "seed_positions_count[seed_k]", \"seeds\": ["arr[j][seed_k]"]},";
      print arr_str > output_file;
      if(seed_count == n) print "\""repeat_char("*", seed_size)"\":{\"count\": 0, \"seeds\": []}}" > output_file;
      seed_count++;
    }
  }
    
    delete arr;
    delete seed_positions_count;
    indexer_pointer=0;
    counter = 0;
    indexer++;
} 



function repeat_char(char, amount, res) {
  if(amount == 0) return res;

  res = res""char;
  amount--;

  res = repeat_char(char, amount, res);
  return res;
}

function replace_char_at_index(str, i, len, replace_with) {
  return (i != 1 ? substr(str, 1, i - 1) : "")""replace_with""(i + len <= length(str) ? substr(str, i + len) : "");
}

function generate_wildcard_seeds(seed, seed_arr) {
  delete seed_arr;
  pure_str = seed;
  seed_i = 0;
  
  for(p = 0; p < length(seed); p++) {
    current_str = replace_char_at_index(pure_str, p+1, 1, "*");
    seed_arr[seed_i] = current_str;
    seed_i++;

    for(q = 1; q < length(seed) - p; q++) {
      for(r = p + 1; r <= length(seed) - q; r++) {
        new_str = replace_char_at_index(current_str, r + 1, q, repeat_char("*", q));
        seed_arr[seed_i] = new_str;
        seed_i++;
      }
    }
  }
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
        
        if(counter >= maxNFT) {
            arr_printed++;
            if(arr_printed == cap) exit;

            print_result();
        }

        if(nft_counter != nft_id) {
            print "It seems that there's a gap in the NFTs, all NFTs must be sorted for this to work. NFT counter expected: "nft_counter" but got "nft_id" instead.";
        }
        
        generate_wildcard_seeds(seed, new_seeds);

        for(y = 0; y < length(new_seeds); y++) {
          curr_seed = new_seeds[y];
          if(curr_seed == repeat_char("*", seed_size)) continue;

          current_seed_index = max_position_size == 0 ? 0 : int(seed_positions_count[curr_seed] / max_position_size);
          arr[current_seed_index][0] = "";

          not_exist = wildcard_seed_exists[curr_seed][seed] == 0;
          arr[current_seed_index][curr_seed] = not_exist ? ((arr[current_seed_index][curr_seed] ? arr[current_seed_index][curr_seed]"," : "")"\""seed"\"") : arr[current_seed_index][curr_seed];
          wildcard_seed_exists[curr_seed][seed]++;
          seed_positions_count[curr_seed]++;
        }
    }

    counter++;
    nft_counter++;
}

END{
    print_result();
}