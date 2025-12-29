#!/bin/bash
#SBATCH --job-name=Orthofinder
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=128G
#SBATCH --time=1-0:0:0

export OMP_NUM_THREADS=${SLURM_NTASKS}
module load orthofinder/2.5.4
#Keep all protein files (longest protein per gene choosen) in the "BrevitarsisGeneGroups/" folder

orthofinder -t ${SLURM_NTASKS} -a ${SLURM_NTASKS} -M msa -S diamond -A mafft -T fasttree -f BrevitarsisGeneGroups/