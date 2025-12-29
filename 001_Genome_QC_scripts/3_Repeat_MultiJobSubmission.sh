#!/bin/bash

mkdir -p logs
mkdir -p repeat_out

for dir in *_data; do
  genome_file=$(find "$dir/ncbi_dataset/data" -type f -name "*genomic.fna" ! -name "*cds_from_genomic.fna")

  if [[ -f "$genome_file" ]]; then
    prefix=${dir%_data}  # Remove '_data' from directory name
    output_dir="repeat_out/${prefix}"  # All outputs go under repeat_out/

    sbatch --job-name="rm_${prefix}" \
           --output="logs/${prefix}.log" \
           Repeat_Analysis_Script.sh -g "$genome_file" -c 64 -o "$output_dir" -p "$prefix"

    echo "✅ Submitted job for $prefix"
  else
    echo "⚠️ No genomic.fna found in $dir"
  fi
done