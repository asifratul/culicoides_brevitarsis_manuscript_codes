#!/bin/bash
#SBATCH --job-name=Eggnoc
#SBATCH --time=2-0:00:00
#SBATCH --mem=125G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32

export OMP_NUM_THREADS=${SLURM_NTASKS}
module load eggnogmapper/2.1.6

emapper.py --cpu 64 -i Culicoides_brevitarsis.fasta --output_dir . --report_orthologs --tax_scope Diptera --dbmem -o out --override -m diamond --dmnd_ignore_warnings --dmnd_algo ctg --evalue 0.001 --score 60 --pident 60 --query_cover 50 --subject_cover 50 --itype proteins --target_orthologs all --go_evidence all --pfam_realign none --report_orthologs --decorate_gff yes --excel


