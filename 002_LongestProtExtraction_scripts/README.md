 # Longest protein isoform extraction scripts

This directory contains scripts used to extract the longest protein isoform
per gene from annotated proteomes. This step was used to generate non-redundant
protein sets for downstream comparative genomics analyses.

## Script descriptions

### `NCBI_LongestProtein_Script.sh`
Extracts the longest protein isoform per gene from NCBI-style protein FASTA
files, using gene or locus identifiers encoded in sequence headers.

### `VectorBase_LongestProtein_Script.sh`
Extracts the longest protein isoform per gene from VectorBase-style protein
FASTA files, accounting for VectorBase-specific header conventions.

## Notes
- Input protein FASTA files are not included.
- Scripts assume one-to-many transcript–protein relationships per gene.
