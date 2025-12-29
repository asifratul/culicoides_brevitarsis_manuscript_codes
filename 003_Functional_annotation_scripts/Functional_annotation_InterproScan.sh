#!/bin/bash
#SBATCH --job-name=InterPro
#SBATCH --time=2-0:00:00
#SBATCH --mem=125G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64

export OMP_NUM_THREADS=${SLURM_NTASKS}

module load interproscan/5.72-103.0
module load python

# Specify input and output paths
INPUT_FASTA="protein.faa"
OUTPUT_TSV="BSF_AllProt_interPro.tsv"

export OMP_NUM_THREADS=${SLURM_NTASKS}

# Run InterProScan
interproscan-64G.sh -T ${MEMDIR} --cpu ${SLURM_NTASKS} -i $INPUT_FASTA -f tsv --goterms -o $OUTPUT_TSV -f tsv -dp -pa


awk -F'\t' '{print $1, $14}' OFS='\t' BSF_AllProt_interPro.tsv > BSF_AllProt_interPro_Clean.tsv