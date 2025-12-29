#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file.fasta>"
    exit 1
fi

input_file="$1"

#1: Extract sequence header, 
#2: split the header by "|", print sequence header, the first and third columns, and the sequence lengths
#3: Sort column 3 by longest to smallest and then column 2 by A to Z
#4: Reduce file by column 2(GeneIds), keeping only unique IDs
#5: Extract sequences based on unique protein IDs

seqkit fx2tab "$input_file" | 
awk -F'\t' '{split($1, header, "|"); print header[1]"\t"header[3]"\t"length($2)}'|
sort -k3,3nr -k2,2 | awk -F'\t' '!seen[$2]++' |
awk '{print $1}' | tr -d ' ' | 
seqkit grep -f - "$input_file" > "${input_file%.*}_longest.fasta"
