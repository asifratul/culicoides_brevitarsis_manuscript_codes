#!/bin/bash

module load paml/4.10.9

CODON_DIR=output/07_codon_aln_by_query
OUTDIR=output/08_codeml_out
CTL_TEMPLATE=TemplateCodeML.ctl
SUMMARY=output/08_codeml_summary.tsv

mkdir -p "$OUTDIR"

# Copy codon alignments to codeml run folder
cp "$CODON_DIR"/*.fasta "$OUTDIR/"

for fasta_path in "$CODON_DIR"/*.fasta; do
    fasta_file=$(basename "$fasta_path")
    base=$(basename "$fasta_path" .fasta)
    ctl_file="${OUTDIR}/${base}.ctl"
    out_file="${base}_Dn_Ds.txt"

    # Generate codeml .ctl file with updated seqfile/outfile references
    perl -pe "s/CHANGETHISNAME/${fasta_file}/g" "$CTL_TEMPLATE" > "$ctl_file"

    # Run codeml from within OUTDIR
    (cd "$OUTDIR" && yes "" | codeml "$(basename "$ctl_file")" > /dev/null 2>&1)
	
done

echo "🎉 Codeml runs complete."


mkdir -p "$(dirname "$SUMMARY")"
echo -e "query\ttarget\tt\tS\tN\tdN/dS\tdN\tSE(dN)\tdS\tSE(dS)" > "$SUMMARY"

for file in "$OUTDIR"/*_Dn_Ds.txt; do
    NAME=$(basename "$file" _Dn_Ds.txt)
    
    cat "$file" | \
        perl -0777 -pe 's/.*F3x4\.//gs' | \
        perl -0777 -pe 's/.*?\((.*?)\).*?\((.*?)\).*?t=(.*?)\n(.*?)\(by method 1\).*?\(by method 2\)/\1\t\2\3\t\4\n/gs' | \
        perl -pe 's/=(\d)/= \1/g' | \
        perl -pe 's/( )\1+/ /g' | \
        tr ' ' '\t' | \
        awk '{ print $2"\t"$1"\t"$3"\t"$5"\t"$7"\t"$9"\t"$18"\t"$20"\t"$23"\t"$25 }' | \
        grep 'Query|' >> "$SUMMARY"

    echo "✅ Parsed: $file"
done

echo "🎉 All _Dn_Ds.txt files processed. Summary saved to: $SUMMARY"
