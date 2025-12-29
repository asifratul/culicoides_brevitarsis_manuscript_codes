# Genome assembly quality control scripts

This directory contains shell scripts used for genome assembly quality assessment and repeat analysis of *Culicoides brevitarsis*.

All scripts were executed in a Linux HPC environment.

## Script descriptions

### `0_Download_NCBI_accessions.sh`
Downloads genome assemblies and annotation files from NCBI using accession
numbers. Used to retrieve reference genomes for comparative analyses.

### `1_AssemblyStats_AnnotationStats.sh`
Generates genome assembly and annotation statistics, including basic metrics
such as total assembly size, contig/scaffold counts, N50 values, and gene model
summaries.

### `2_Run_busco.sh`
Runs BUSCO to assess genome completeness using appropriate lineage datasets.
Outputs completeness scores (Complete, Duplicated, Fragmented, Missing).

### `3_Repeat_MultiJobSubmission.sh`
Wrapper script for submitting repeat annotation jobs (e.g. RepeatModeler /
RepeatMasker) as multiple HPC jobs.

### `4_Gene_density_summary.sh`
Calculates gene density across genomic intervals or chromosomes for downstream
visualisation and comparative analyses.

### `Kmer_estimation_script.sh`
Performs k-mer based genome size and complexity estimation from sequencing reads.

### `Repeat_Analysis_Script.sh`
Runs repeat content analysis and summarises repeat composition across the genome.

## Notes
- Input data (genome FASTA, reads, BUSCO databases) are not included.
- Scripts may require minor path or module adjustments depending on the HPC
  environment.
