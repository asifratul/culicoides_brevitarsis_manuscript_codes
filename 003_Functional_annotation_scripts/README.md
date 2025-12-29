# Functional annotation scripts

This directory contains scripts used for functional annotation of protein-coding
genes across multiple genomes. These scripts were applied to *Culicoides brevitarsis*
as well as to additional insect genomes used in orthogroup inference and
comparative genomics analyses.

Functional annotation was performed on non-redundant proteomes (longest protein
isoform per gene per genome) to ensure consistency across species.

## Script descriptions

### `Functional_annotation_EggNog.sh`
Runs EggNOG-mapper to assign orthology-based functional annotations, including
COG categories, functional descriptions, and pathway annotations, for predicted
proteins across multiple species.

### `Functional_annotation_InterproScan.sh`
Runs InterProScan to identify conserved protein domains and motifs, and to assign
Gene Ontology (GO) terms and protein family annotations for proteins from multiple
genomes.

## Notes
- External databases (EggNOG, InterPro) are not included in this repository.
- Scripts were executed in a Linux HPC environment.
- Outputs were used for downstream functional categorisation, orthogroup-level
  analyses, and comparative genomics.
