#!/bin/bash
#SBATCH --job-name=RBH_blastp_mel_brev
#SBATCH --output=rbh_blastp_%j.out
#SBATCH --error=rbh_blastp_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=64G
#SBATCH --time=10:0:0

module load blast+/2.16.0

# ===== Input protein FASTAs =====
## only provide longest protein per gene file#
DMEL="Armigeres_immunityProt.fasta"
BREV="Culicoides_brevitarsis.fasta"

# ===== Output directories =====
OUTDIR="RBH_results"
mkdir -p $OUTDIR/BlastDB

# ===== Step 1: Build BLAST databases =====
makeblastdb -in "$DMEL" -dbtype prot -out "$OUTDIR/BlastDB/Dmel_db"
makeblastdb -in "$BREV" -dbtype prot -out "$OUTDIR/BlastDB/Brev_db"

# ===== Step 2: Forward & Reverse BLASTP =====
blastp -db "$OUTDIR/BlastDB/Brev_db" -query "$DMEL" \
  -evalue 1e-5 -num_threads 8 \
  -out "$OUTDIR/Dmel_vs_Brev.tsv" \
  -outfmt "6 qseqid qstart qend qlen sseqid sstart send slen pident evalue bitscore length mismatch gaps"

blastp -db "$OUTDIR/BlastDB/Dmel_db" -query "$BREV" \
  -evalue 1e-5 -num_threads 8 \
  -out "$OUTDIR/Brev_vs_Dmel.tsv" \
  -outfmt "6 qseqid qstart qend qlen sseqid sstart send slen pident evalue bitscore length mismatch gaps"

echo "✅ Step 2 done: Raw BLAST outputs saved."

# ===== Step 3: RBH from raw BLAST results =====
awk '!a[$1]++ {print $1"\t"$5}' "$OUTDIR/Dmel_vs_Brev.tsv" > "$OUTDIR/fwd_raw.txt"
awk '!a[$1]++ {print $1"\t"$5}' "$OUTDIR/Brev_vs_Dmel.tsv" > "$OUTDIR/rev_raw.txt"

awk 'NR==FNR {r[$1]=$2; next} r[$2]==$1 {print $1"\t"$2}' \
  "$OUTDIR/rev_raw.txt" "$OUTDIR/fwd_raw.txt" > "$OUTDIR/RBH_raw.tsv"

echo -e "Dmel_ID\tBrev_ID" | cat - "$OUTDIR/RBH_raw.tsv" > "$OUTDIR/tmp" && mv "$OUTDIR/tmp" "$OUTDIR/RBH_raw.tsv"
echo "✅ Step 3 done: RBH_raw.tsv created."

# ===== Step 4: Filter each BLAST for ≥50% coverage =====
awk '{
  aln=$12; qlen=$4; slen=$8;
  cov=aln/((qlen<slen)?qlen:slen);
  if(cov>=0.5) print $0
}' "$OUTDIR/Dmel_vs_Brev.tsv" > "$OUTDIR/Dmel_vs_Brev_cov50.tsv"

awk '{
  aln=$12; qlen=$4; slen=$8;
  cov=aln/((qlen<slen)?qlen:slen);
  if(cov>=0.5) print $0
}' "$OUTDIR/Brev_vs_Dmel.tsv" > "$OUTDIR/Brev_vs_Dmel_cov50.tsv"

echo "✅ Step 4 done: Coverage-filtered files created."

# ===== Step 5: RBH from coverage-filtered BLASTs =====
awk '!a[$1]++ {print $1"\t"$5}' "$OUTDIR/Dmel_vs_Brev_cov50.tsv" > "$OUTDIR/fwd_cov.txt"
awk '!a[$1]++ {print $1"\t"$5}' "$OUTDIR/Brev_vs_Dmel_cov50.tsv" > "$OUTDIR/rev_cov.txt"

awk 'NR==FNR {r[$1]=$2; next} r[$2]==$1 {print $1"\t"$2}' \
  "$OUTDIR/rev_cov.txt" "$OUTDIR/fwd_cov.txt" > "$OUTDIR/RBH_cov50.tsv"

echo -e "Dmel_ID\tBrev_ID" | cat - "$OUTDIR/RBH_cov50.tsv" > "$OUTDIR/tmp" && mv "$OUTDIR/tmp" "$OUTDIR/RBH_cov50.tsv"

echo "✅ Step 5 done: RBH_cov50.tsv created."

# ===== Final summary =====
echo "🎉 Workflow complete."
echo "Files created:"
echo " - Raw BLAST outputs:         $OUTDIR/Dmel_vs_Brev.tsv , $OUTDIR/Brev_vs_Dmel.tsv"
echo " - RBH (raw):                 $OUTDIR/RBH_raw.tsv"
echo " - Coverage-filtered outputs: $OUTDIR/Dmel_vs_Brev_cov50.tsv , $OUTDIR/Brev_vs_Dmel_cov50.tsv"
echo " - RBH (≥50% coverage):       $OUTDIR/RBH_cov50.tsv"
