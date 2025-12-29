#!/bin/bash
#SBATCH --job-name=RepeatModeler_Masker
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --mem=128G
#SBATCH --time=2-0:0:0

set -e

# This script runs RepeatModeler and RepeatMasker to identify repeats in a genome fasta file.
# It takes four arguments:
# 1. Genome fasta file path
# 2. Number of CPUs to use
# 3. Output directory path
# 4. Genome prefix name

# Function to print usage instructions
print_usage() {
echo "Usage: $0 -g genome.fasta -c num_cpus -o output_dir -p genome_prefix"
exit 1
}

# Parse input flags and options
if [ $# -eq 0 ]; then
print_usage
fi

while getopts ":g:c:o:p:" opt; do
case $opt in
g) GENOME="$OPTARG"
;;
c) CPU="$OPTARG"
;;
o) OUTPUTS="$OPTARG"
;;
p) GENOME_PRF="$OPTARG"
;;
\?) echo "Invalid option -$OPTARG" >&2
print_usage
;;
esac
done

# Load required modules
module load repeatmodeler/2.0.2a repeatmasker/4.1.2p1

# Check if genome fasta file exists
if [[ ! -e $GENOME ]]; then
echo "Genome fasta file does not exist.. exiting"
exit 1
fi

# Create output directory
WKDIR=`pwd`/$OUTPUTS/
mkdir -p $WKDIR
cd $WKDIR
echo "Current directory is $WKDIR"

# Copy genome fasta file to the working directory

if [[ ! -e $WKDIR/genome.fasta ]]; then 
echo "Copying genome fasta file to the working directory"
cp ../$GENOME $WKDIR/genome.fasta
else
echo "Genome fasta file already exists in the working directory.. skipping"
fi

# Check if RepeatModeler was run successfully in an earlier run 
if [[ ! -e $WKDIR/repeatmodeler/"$GENOME_PRF"-families.fa ]]; then
# Remove repeatmodeler directory and create a new one
rm -fr $WKDIR/repeatmodeler/
mkdir -p $WKDIR/repeatmodeler
cd $WKDIR/repeatmodeler
echo "[`date`]: Running RepeatModeler to identify repeats"

# Build database and run RepeatModeler
BuildDatabase -name $GENOME_PRF -engine ncbi $WKDIR/genome.fasta 1> build_db.log 2>&1 && \
RepeatModeler -database $GENOME_PRF -pa $CPU 1> repeatmodeler.log 2>&1

else
echo "RepeatModeler was run successfully in an earlier run.. skipping"
fi

# Check if RepeatMasker was run successfully in an earlier run 
if [[ ! -e $WKDIR/rep_mask/rep_mask.success ]]; then
# Remove rep_mask directory and create a new one
rm -fr $WKDIR/rep_mask/
mkdir -p $WKDIR/rep_mask
cd $WKDIR/rep_mask
echo "[`date`]: Running RepeatMasker to identify repeats"

# Run RepeatMasker and save output to file
RepeatMasker -lib $WKDIR/repeatmodeler/"$GENOME_PRF"-families.fa -gff -engine ncbi -pa $CPU $WKDIR/genome.fasta 1> rep_mask.log 2>&1 && \
touch rep_mask.success && cat "$GENOME_PRF".out | tail -n +3 | perl -ne 'chomp; s/^\s+//; @t = split(/\s+/); print $t[4]."\t"."repmask\tnonexonpart\t".$t[5]."\t".$t[6]."\t0\t.\t.\tsrc=RM\n";' \
| sort -n -k 1,1 > $WKDIR/repeats.out else
echo "RepeatMasker was run successfully in an earlier run.. skipping"
fi