# dN/dS analysis workflow

This directory contains scripts used to estimate synonymous (dS) and
non-synonymous (dN) substitution rates between orthologous coding sequences
(CDS). The workflow is designed for pairwise or multi-species comparative
evolutionary analyses using **only the longest CDS per gene**.

## Workflow overview

To run the dN/dS analysis:

1. Copy all required script files and the codeml control (CTL) template file
   into the working directory.

2. Place **query CDS FASTA files (longest CDS per gene only)** in the directory:
query/
- Query sequences must be CDS (not protein).
- Only one representative CDS (longest isoform) per gene should be included.
- Typically represents the focal species.

3. Place **target CDS FASTA files (longest CDS per gene only)** in the directory:
targets/
- Target sequences must be CDS.
- Only one representative CDS (longest isoform) per gene should be included.
- May include one or multiple comparison species.

4. File naming requirements:
- FASTA filenames must be simplified and consistent.
- Example:
  ```
  AedesAegypti.fasta
  ```
- Avoid spaces and special characters in filenames.

5. Run the scripts sequentially, following the order indicated by their
numbering.

## Script order

1. **Blast-to-CDS preparation script**  
Identifies orthologous CDS pairs based on sequence similarity.

2. **dN/dS calculation script**  
Prepares alignments and performs codon-based evolutionary analyses.

3. **PAML execution script**  
Runs `codeml` using the provided CTL template file.

## Notes

- All input FASTA files must contain valid CDS sequences with correct reading
frames.
- Only the longest CDS per gene should be used to avoid isoform redundancy.
- Manual inspection may be required for problematic alignments.
- PAML (codeml) must be installed and accessible in the execution environment.
- Large intermediate files are not included in this repository.
