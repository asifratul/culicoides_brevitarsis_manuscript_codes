# Chromosome-scale genome of *Culicoides brevitarsis* highlights genetic basis of vector competency

This repository contains the custom scripts and configuration files used in the
analyses reported in the manuscript:

**Chromosome-scale genome of *Culicoides brevitarsis* highlights genetic basis of
vector competency**

## Authors

Khandaker Asif Ahmed*, Melissa J. Klein, Leon Court, Rahul V. Rane,  
Tom K. Walsh, Stacey E. Lynch, Prasad N. Paradkar,  
Debbie Eagles, Gunjan Pandey

\*Corresponding author: khandakerasif.ahmed@csiro.au

## Overview

The scripts in this repository support genome assembly quality assessment,
annotation, and comparative genomics analyses of *Culicoides brevitarsis*, a
major vector of arboviruses affecting livestock.

Analyses include genome quality control, repeat annotation, functional
annotation, orthology inference, and evolutionary rate estimation, with a focus
on identifying genetic features relevant to vector competency.

## Repository structure

The repository is organised by analysis stage:

- `001_Genome_QC_scripts`  
  Genome assembly quality assessment, repeat analysis, and gene density
  estimation.

- `002_LongestProtExtraction_scripts`  
  Extraction of the longest protein isoform per gene for whole genomes, used to
  generate non-redundant proteomes.

- `003_Functional_annotation_scripts`  
  Functional annotation using EggNOG-mapper and InterProScan across multiple
  genomes.

- `004_EgapX_config_files`  
  Configuration files and execution notes for genome annotation using the NCBI
  EGAPx pipeline.

- `005_dNdS_analysis_scripts`  
  dN/dS analysis workflows using longest CDS per gene for evolutionary
  comparisons.

- `006_Blast_OrthoFinder2_scripts`  
  Orthology inference using reciprocal BLAST (RBH) and OrthoFinder.

Each directory contains its own README describing inputs, outputs, and execution
logic.

## Reproducibility notes

- All analyses were performed in a Linux HPC environment.
- Only the longest protein or CDS per gene was used for comparative analyses to
  avoid isoform redundancy.
- Large input files (genome FASTA, RNA-seq data, intermediate outputs) are not
  hosted in this repository.
- External tools (e.g. BUSCO, EggNOG-mapper, InterProScan, BLAST+, OrthoFinder,
  EGAPx, PAML) must be installed separately.

## Code availability

All custom scripts used in this study are available in this repository. The
repository is intended to support transparency and reproducibility of the
analyses described in the manuscript.

## Contact

For questions regarding the code or analyses, please contact the corresponding
author.

