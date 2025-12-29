#!/bin/bash
# Script 1: Download genomes

module load ncbi-datasets/16.6.0

set -euo pipefail

INPUT_FILE="$1"

# Step 1: Download and unzip
while read -r accession; do
  echo "?? Downloading $accession..."
  zip_file="${accession}_dataset.zip"
  out_dir="${accession}_data"

  datasets download genome accession "$accession" \
    --include genome,gff3,cds,rna,protein \
    --filename "$zip_file"

  unzip -q "$zip_file" -d "$out_dir"
  echo "?? Extracted $accession"
done < "$INPUT_FILE"