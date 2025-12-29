#!/bin/bash
#SBATCH --job-name=AssAnnStats
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16gb

# Load required modules
module load assembly-stats/1.0.1
module load agat/1.0.0

# Exit if no input file provided
if [[ $# -ne 1 ]]; then
  echo "? Usage: $0 accessions.txt"
  exit 1
fi

INPUT_FILE="$1"

# Create output directories if not present
mkdir -p summary
mkdir -p agat_summary

while read -r accession; do
  echo "?? Processing $accession ..."

  # Correct data path (do not restrict to ${accession} subdir)
  DATA_DIR="${accession}_data/ncbi_dataset/data"

  # Match genome file: must start with accession and end with _genomic.fna
  genome=$(find "$DATA_DIR" -type f -name "${accession}*_genomic.fna" | head -n1)

  # Match GFF file
  gff=$(find "$DATA_DIR" -type f -name "*.gff" | head -n1)

  # Assembly-stats
  if [[ -f "$genome" ]]; then
    echo "?? Running assembly-stats..."
    assembly-stats "$genome" > "summary/${accession}_assembly_stats.txt"
  else
    echo "?? Genome FASTA not found for $accession"
    continue
  fi

  # AGAT statistics
  if [[ -f "$gff" ]]; then
    echo "?? Running AGAT stats..."
    agat_sp_statistics.pl --gff "$gff" -g "$genome" -o "agat_summary/${accession}_agat_stats.txt"
  else
    echo "?? GFF file not found for $accession"
  fi

done < "$INPUT_FILE"

echo "? Assembly and annotation stats complete."