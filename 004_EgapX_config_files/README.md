# NCBI EGAPx configuration files and execution notes

This directory contains configuration files and execution notes used for genome
annotation with the NCBI Eukaryotic Genome Annotation Pipeline (EGAPx). These
files were used for annotating *Culicoides* genomes as part of comparative and
reference genome analyses.

## Contents

- YAML configuration files for EGAPx genome annotation
- Example commands used to generate YAML files
- Notes on RNA-seq input preparation and pipeline execution

## Configuration files

### Culicoides_sonorensis.yaml
EGAPx configuration file used for annotating the *Culicoides sonorensis* genome.

### Culicoides_stellifer.yaml
EGAPx configuration file used for annotating the *Culicoides stellifer* genome.

## YAML generation

YAML configuration files were generated using the NCBI-provided
`generateYAML.py` script. An example command used for YAML generation is shown
below:

```bash
module load python

generateYAML.py \
    --download_dir culicoides_sonorensis/egapx_RNA_download \
    --genome_fasta culicoides_sonorensis/GCA_047716325.1_idCulSono.KS.ABADRU.1.0.female_genomic.fna.gz \
    --taxonomic_ID 179676 \
    --annotation_provider "Asif_Ahmed" \
    --annotation_name_prefix "GCA_047716325.1" \
    --locus_tag_prefix "CulSono.KS.ABADRU" \
    --output_file sono.yaml
```
## RNA-SEQ INPUT VERIFICATION

All RNA-seq files used as evidence for EGAPx annotation were verified prior to
pipeline execution. The following command was used to list resolved file paths
for downloaded RNA-seq data:

find culicoides_sonorensis/egapx_RNA_download/ -type f -exec readlink -f {} \;

## EGAPX PIPELINE EXECUTION

Genome annotation jobs were executed locally using the EGAPx pipeline via a
SLURM-based HPC environment. An example submission command is shown below:

```bash
sbatch egapx_annotation_pipeline/run_egapx_local.slurm \
    sono.yaml \
    culicoides_sonorensis/annotation_output
```
## NOTES
- These commands are provided for documentation and reproducibility purposes.
- The EGAPx local annotation pipeline was obtained from the official NCBI GitHub repository (https://github.com/ncbi/egapx) and executed on an HPC system.
- Paths, and resource specifications may require adjustment
  depending on the local computing environment.
- Large input files (genome FASTA, RNA-seq reads) are not included in this
  repository.




