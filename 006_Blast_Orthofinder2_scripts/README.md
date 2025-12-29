# Orthology inference using BLAST RBH and OrthoFinder

This directory contains scripts used to infer orthologous relationships between
species using reciprocal BLAST best hits (RBH) and OrthoFinder. These workflows
were applied in comparative genomics analyses involving *Culicoides brevitarsis*
and other insect genomes.

All analyses were performed using **only the longest protein isoform per gene**
for each genome to avoid redundancy arising from alternative splicing.

---

## 1. Reciprocal BLAST (RBH) workflow

The RBH pipeline identifies putative 1:1 orthologs using reciprocal BLASTP
searches between two proteomes.

### Input requirements

- Protein FASTA files must contain **only the longest protein per gene**
- One FASTA file per species
- Example filenames:
Culicoides_brevitarsis.fasta, Armigeres_immunityProt.fasta

### RBH analysis steps

1. **BLAST database construction**  
 Protein BLAST databases are built for each species using `makeblastdb`.

2. **Forward and reverse BLASTP searches**  
 - Query species A against species B
 - Query species B against species A  
 BLASTP is run with an e-value threshold of `1e-5`.

3. **Initial RBH identification (raw)**  
 Reciprocal best hits are extracted from raw BLAST outputs based on the
 top-scoring hit per query sequence.

4. **Coverage filtering (≥50%)**  
 BLAST alignments are filtered to retain hits with alignment length covering
 at least 50% of the shorter sequence (query or subject).

5. **Final RBH identification (coverage-filtered)**  
 Reciprocal best hits are re-derived from the coverage-filtered BLAST results.

### RBH outputs

All RBH outputs are written to the `RBH_results/` directory:

- `Dmel_vs_Brev.tsv` – Raw BLASTP output (species A vs species B)
- `Brev_vs_Dmel.tsv` – Raw BLASTP output (species B vs species A)
- `RBH_raw.tsv` – RBH pairs derived from raw BLAST results
- `Dmel_vs_Brev_cov50.tsv` – Coverage-filtered BLAST results (≥50%)
- `Brev_vs_Dmel_cov50.tsv` – Coverage-filtered BLAST results (≥50%)
- `RBH_cov50.tsv` – Final high-confidence RBH ortholog pairs

---

## 2. OrthoFinder workflow

OrthoFinder was used to infer orthogroups and orthologous relationships across
multiple species using a graph-based clustering approach.

### Input requirements

- All protein FASTA files must contain **only the longest protein per gene**
- One FASTA file per species
- All FASTA files must be placed in the directory: BrevitarsisGeneGroups/

### OrthoFinder execution

OrthoFinder was executed in an HPC environment using the following command:
Notes on OrthoFinder configuration
DIAMOND was used for sequence similarity searches.
MAFFT was used for multiple sequence alignment.
FastTree was used for gene tree inference.
OrthoFinder v2.5.4 was used for all analyses.

Notes
SLURM resource directives may require adjustment depending on the computing
environment.

Input proteomes and large intermediate files are not included in this
repository.

Orthology results were used for downstream functional annotation, gene family
analysis, and dN/dS estimation

---
