#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --time=1-01:30:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=125gb

export NUMEXPR_MAX_THREADS=64

# Script: Run BUSCO for genome, transcriptome, and protein modes
module load busco/5.2.2
set -euo pipefail

INPUT_FILE="$1"
LINEAGE="diptera_odb10"
mkdir -p logs

while read -r accession; do
  echo "Running BUSCO for $accession"
  DATA_DIR="${accession}_data/ncbi_dataset/data"

  # Genome file selection (exclude cds/rna versions)
  genome=$(find "$DATA_DIR" -name "${accession}*_genomic.fna" -not -name "*cds*" -not -name "*rna*" | head -n1)
  rna=$(find "$DATA_DIR" -name "*.rna.fna" | head -n1)
  prot=$(find "$DATA_DIR" -name "*.faa" | head -n1)

  for mode in genome transcriptome protein; do
    case $mode in
      genome) input="$genome" ;;
      transcriptome) input="$rna" ;;
      protein) input="$prot" ;;
    esac

    if [[ -f "$input" ]]; then
      echo "Running BUSCO $mode mode for $accession"
      busco -i "$input" \
            -o "${accession}_${mode}_busco" \
            -l "$LINEAGE" \
            -m "$mode" \
            --out_path "logs" \
            -c 20 -f --offline --quiet || echo "BUSCO $mode failed for $accession"
    else
      echo "No $mode input for $accession"
    fi
  done

done < "$INPUT_FILE"

echo "All BUSCO runs complete."