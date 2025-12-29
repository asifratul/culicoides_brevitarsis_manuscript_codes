#!/bin/bash

module load samtools/1.19.2
module load bedtools/2.31.1

echo -e "Genome\tMeanGeneCount\tSE_GeneCount\tMeanGeneLength\tSE_GeneLength\tTotalWindows" > gene_density_summary.tsv

for dir in *_data; do
    prefix=${dir%_data}
    genome_file=$(find "$dir/ncbi_dataset/data" -name "*.fna" ! -name "*cds_from_genomic.fna" | head -n 1)
    gff_file=$(find "$dir/ncbi_dataset/data" -name "*.gff" | head -n 1)

    if [[ ! -f "$genome_file" || ! -f "$gff_file" ]]; then
        echo "Missing genome or GFF in $dir"
        continue
    fi

    # Step 1: Index genome
    samtools faidx "$genome_file"

    # Step 2: Create 100kb genome windows
    bedtools makewindows -g "${genome_file}.fai" -w 100000 > "${prefix}_100kb_windows.bed"

    # Step 3: Extract gene coordinates
    awk '$3 == "gene"' "$gff_file" | awk 'BEGIN{OFS="\t"} {print $1, $4-1, $5, "gene_"NR, ".", "+"}' > "${prefix}_genes.bed"

    # Step 4: Calculate coverage (gene count per window)
    bedtools coverage -a "${prefix}_100kb_windows.bed" -b "${prefix}_genes.bed" -counts > "${prefix}_gene_counts.txt"

    # Step 5: Calculate mean and SE for gene count per window
    read mean_count se_count <<< $(awk '{sum+=$4; sumsq+=$4*$4} END {
        if (NR > 1) {
            mean = sum/NR;
            se = sqrt((sumsq - NR*mean^2)/(NR - 1))/sqrt(NR);
            printf "%.4f %.4f", mean, se;
        } else {
            print "0 0";
        }
    }' "${prefix}_gene_counts.txt")

    total_windows=$(awk 'END {print NR}' "${prefix}_gene_counts.txt")

    # Step 6: Calculate mean and SE for gene length
    read mean_gene_length se_gene_length <<< $(awk '$3 == "gene" {
        len = $5 - $4 + 1;
        sum += len;
        sumsq += len * len;
        count += 1;
    } END {
        if (count > 1) {
            mean = sum / count;
            se = sqrt((sumsq - count*mean^2)/(count - 1))/sqrt(count);
            printf "%.2f %.2f", mean, se;
        } else {
            print "0 0";
        }
    }' "$gff_file")

    echo -e "${prefix}\t${mean_count}\t${se_count}\t${mean_gene_length}\t${se_gene_length}\t${total_windows}" >> gene_density_summary.tsv
done
