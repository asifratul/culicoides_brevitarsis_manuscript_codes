# dN/dS analysis workflow

This directory contains scripts used to estimate synonymous (dS) and
non-synonymous (dN) substitution rates between orthologous coding sequences
(CDS). The workflow is designed for pairwise or multi-species comparative
evolutionary analyses.

## Workflow overview

To run the dN/dS analysis:

1. Copy all required script files and the codeml control (CTL) template file
   into the working directory.

2. Place **query CDS FASTA files** in the directory:
query/

markdown
Copy code
- Query sequences must be CDS (not protein).
- Typically represents the focal species.

3. Place **target CDS FASTA files** in the directory:
targets/

markdown
Copy code
- Target sequences must also be CDS.
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

- Input FASTA files must contain valid CDS sequences with correct reading
frames.
- Manual inspection may be required for problematic alignments or unexpected
results.
- PAML (codeml) must be installed and accessible in the execution environment.
- Large intermediate files are not included in this repository.
