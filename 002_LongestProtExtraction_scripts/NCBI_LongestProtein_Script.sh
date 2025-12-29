#!/bin/bash
#SBATCH --job-name=BUSCO
#SBATCH --time=05:30:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=64gb

git clone https://github.com/rahulvrane/orthonome
export ORTHONOME=`pwd`/orthonome

module load python/3.9.4
module load seqkit/2.7.0

#datasets download genome accession GCF_029784015.1 --include gff3,rna,cds,protein,genome,seq-report
#unzip ncbi_dataset.zip -d ferr/

#datasets download genome accession GCF_019175385.1 --include gff3,rna,cds,protein,genome,seq-report
#unzip ncbi_dataset.zip -d barb/

CDIR=`pwd`
for PRF in BSF; do
    #cd $PRF
    python3 $ORTHONOME/ncbi_cds2nucfile.py ./ncbi_dataset/data/GCF_*/cds_from_genomic.fna "$PRF".cds
    cat "$PRF".cds | awk '$0 ~ ">" {
        print c;
        c=0;
        printf substr($0,2,100) "\t";
    }
    $0 !~ ">" {
        c+=length($0);
    }
    END {
        print c;
    }' | sort -k3,3nr | sort -k2,2 -u | cut -f1,2 | tr '\t' ' ' | grep [a-Z] > "$PRF".idx
    awk '{print $1}' "$PRF".idx | seqkit grep -f - ./ncbi_dataset/data/GCF_*/protein.faa > "$PRF"_longestProtein.fasta
#python3 $ORTHONOME/orthonome_inputs_after_gffread.py "$PRF" ncbi_dataset/data/GCF_*/*gff
    cd $CDIR
done