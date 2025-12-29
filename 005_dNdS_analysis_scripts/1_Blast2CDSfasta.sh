#!/bin/bash

module load blast+/2.16.0
module load seqkit/2.7.0

#make two folders, "query" (to keep query fasta), "targets" (to keep multiple target fasta)#
#make simple fasta file name = AedesAegypti.fasta, it will be easier for downstream renaming#

# === Directory Setup ===
RAW_TARGET_DIR=targets
RENAMED_TARGET_DIR=targets_renamed
QUERY_IN=query/CompetencySono_86Seq.fasta
QUERY_RENAMED=query/query_renamed.fasta

BLAST_DB_DIR=output/00_blast_db
BLAST_OUT_DIR=output/01_blast
RBH_DIR=output/02_rbh
MATRIX=output/rbh_query_matrix.tsv
IDDIR=output/03_id_lists
CDSDIR=output/04_cds_by_query

mkdir -p "$RENAMED_TARGET_DIR" "$BLAST_DB_DIR" "$BLAST_OUT_DIR" "$RBH_DIR" "$IDDIR" "$CDSDIR" query

# === Step 1: Rename FASTA headers ===
awk '{if($0 ~ /^>/) print ">Query|"substr($0,2); else print $0}' "$QUERY_IN" > "$QUERY_RENAMED"

for file in "$RAW_TARGET_DIR"/*.fasta; do
    filename=$(basename "$file")
    prefix="${filename%.fasta}"
    awk -v pfx="$prefix" '/^>/ {print ">"pfx"|"substr($0,2)} !/^>/ {print}' "$file" > "$RENAMED_TARGET_DIR/$filename"
done

# === Step 2: Make BLAST databases ===
makeblastdb -in "$QUERY_RENAMED" -dbtype nucl -out "$BLAST_DB_DIR/query_db"
for f in "$RENAMED_TARGET_DIR"/*.fasta; do
    base=$(basename "$f" .fasta)
    makeblastdb -in "$f" -dbtype nucl -out "$BLAST_DB_DIR/${base}_db"
done

# === Step 3: Run reciprocal BLASTN ===
for f in "$RENAMED_TARGET_DIR"/*.fasta; do
    base=$(basename "$f" .fasta)

    blastn -query "$QUERY_RENAMED" -db "$BLAST_DB_DIR/${base}_db" \
        -out "$BLAST_OUT_DIR/query_vs_${base}.blast" \
        -word_size 9 -outfmt 6 -max_target_seqs 1 -num_threads 4

    blastn -query "$f" -db "$BLAST_DB_DIR/query_db" \
        -out "$BLAST_OUT_DIR/${base}_vs_query.blast" \
        -word_size 9 -outfmt 6 -max_target_seqs 1 -num_threads 4
done

# === Step 4: Generate RBH files ===
for forward in "$BLAST_OUT_DIR"/query_vs_*.blast; do
    target=$(basename "$forward" | sed 's/query_vs_//' | sed 's/.blast//')
    reverse="$BLAST_OUT_DIR/${target}_vs_query.blast"

    [[ ! -f "$reverse" ]] && echo "⚠️ Skipping $target: reverse missing" && continue

    awk '{print $1"\t"$2}' "$forward" > "$RBH_DIR/fwd.tmp"
    awk '{print $1"\t"$2}' "$reverse" > "$RBH_DIR/rev.tmp"

    awk 'NR==FNR {rev[$1]=$2; next} {if (rev[$2]==$1) print $1"\t"$2}' \
        "$RBH_DIR/rev.tmp" "$RBH_DIR/fwd.tmp" > "$RBH_DIR/${target}_rbh.tsv"

    rm "$RBH_DIR/fwd.tmp" "$RBH_DIR/rev.tmp"
done

# === Step 5: Build matrix ===
species=()
for f in "$RBH_DIR"/*_rbh.tsv; do
    sp=$(basename "$f" _rbh.tsv)
    species+=("$sp")
done

cat "$RBH_DIR"/*_rbh.tsv | cut -f1 | sort -u > all_query_ids.txt
echo -e "Query\t${species[*]}" | tr ' ' '\t' > "$MATRIX"

declare -A data
for sp in "${species[@]}"; do
    while IFS=$'\t' read -r q t; do
        data["${q}__${sp}"]="$t"
    done < "$RBH_DIR/${sp}_rbh.tsv"
done

while read -r qid; do
    row="$qid"
    for sp in "${species[@]}"; do
        val="${data[${qid}__${sp}]}"
        [[ -z "$val" ]] && val="-"
        row="${row}\t${val}"
    done
    echo -e "$row" >> "$MATRIX"
done < all_query_ids.txt

rm all_query_ids.txt

# === Step 6: Extract CDS based on matrix ===
tail -n +2 "$MATRIX" | while IFS=$'\t' read -r query_id rest; do
    safe_qid=$(echo "$query_id" | tr '|/ ' '__')
    idfile="$IDDIR/${safe_qid}.ids"
    outfa="$CDSDIR/${safe_qid}.fasta"

    echo "$query_id" > "$idfile"
    IFS=$'\t' read -r -a targets <<< "$rest"
    for id in "${targets[@]}"; do
        [[ "$id" != "-" ]] && echo "$id" >> "$idfile"
    done

    echo "$query_id" > tmp_query.txt
    seqkit grep -f tmp_query.txt "$QUERY_RENAMED" > "$outfa"

    tail -n +2 "$idfile" > tmp_targets.txt
    for tfa in "$RENAMED_TARGET_DIR"/*.fasta; do
        seqkit grep -f tmp_targets.txt "$tfa" >> "$outfa" 2>/dev/null
    done
done

rm -f tmp_query.txt tmp_targets.txt

echo "🎉 All steps complete: RBH, matrix, and CDS FASTAs ready."
