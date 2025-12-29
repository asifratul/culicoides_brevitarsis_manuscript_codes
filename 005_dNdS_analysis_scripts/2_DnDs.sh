#!/bin/bash

set -euo pipefail
# Make sure "TemplateCodeML.ctl" file exists in the same directory

# === Load Required Modules ===
module load seqkit/2.7.0
module load mafft/7.526
module load paml/4.10.9

# === Directory Setup ===
CDS_DIR=output/04_cds_by_query
PROT_DIR=output/05_protein_by_query
ALN_DIR=output/06_protein_aln_by_query
CODON_DIR=output/07_codon_aln_by_query
OUTDIR=output/08_codeml_out
PAL2NAL_DIR=tools/pal2nal
PAL2NAL="$PAL2NAL_DIR/pal2nal.pl"

SUMMARY=output/08_codeml_summary.tsv

mkdir -p "$PROT_DIR" "$ALN_DIR" "$CODON_DIR" "$OUTDIR" "$PAL2NAL_DIR"

# === Step 1: Translate and Align Proteins ===
echo "🔁 Translating CDS and aligning proteins..."
for cds in "$CDS_DIR"/*.fasta; do
    base=$(basename "$cds" .fasta)
    prot="$PROT_DIR/${base}.faa"
    aln="$ALN_DIR/${base}.aln"

    seqkit translate "$cds" --trim > "$prot"
    mafft --auto --quiet "$prot" > "$aln"
    echo "✅ Protein aligned: $base"
done

# === Step 2: Download PAL2NAL if Missing ===
if [[ ! -f "$PAL2NAL" ]]; then
    echo "📥 Downloading PAL2NAL..."
    wget -q http://www.bork.embl.de/pal2nal/distribution/pal2nal.v14.tar.gz -O - | tar -xz -C "$PAL2NAL_DIR" --strip-components=1
    chmod +x "$PAL2NAL"
fi

# === Step 3: Codon Alignment ===
echo "🔁 Building codon alignments..."
for prot_aln in "$ALN_DIR"/*.aln; do
    base=$(basename "$prot_aln" .aln)
    cds="$CDS_DIR/${base}.fasta"
    out="$CODON_DIR/${base}.fasta"
    [[ -f "$cds" ]] && "$PAL2NAL" "$prot_aln" "$cds" -output fasta -nogap > "$out" && echo "✅ Codon aligned: $base"
done