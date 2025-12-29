#!/bin/bash
#SBATCH --job-name=Kmer
#SBATCH --time=0-5:00:00
#SBATCH --mem=125G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64

set -e

# Function to display help message
show_help() {
    echo "Usage: $0 [-1 <input_file_R1> -2 <input_file_R2> | -hifi <input_file_HiFi>]"
    echo ""
    echo "   -1, --r1        Input file R1"
    echo "   -2, --r2        Input file R2"
    echo "   -hifi, --hifi   Input file HiFi"
    echo "   -h, --help      Display this help message"
    echo ""
}

# Initialize variables
R1=""
R2=""
HiFi=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -1|--r1) R1=$(readlink -f "$2"); shift ;;
        -2|--r2) R2=$(readlink -f "$2"); shift ;;
        -hifi|--hifi) HiFi=$(readlink -f "$2"); shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Check if required arguments are provided
if [[ -z "$HiFi" && ( -z "$R1" || -z "$R2" ) ]]; then
    echo "Error: Missing required arguments."
    show_help
    exit 1
fi

echo "Step 02. Load modules"
module purge
module load R meryl/1.4.1
genomescope=/datasets/work/ev-agi-apps-db/reference/apps/genomescope2.0/genomescope.R


echo "Step 03. Counting kmers"

if [[ -n "$R1" && -n "$R2" ]]; then
    echo "Counting kmer from Illumina files"
    for i in {19..31..2}; do
        echo "Running commands for k=$i"
        echo "meryl count k=${i} output k${i}.meryl ${R1} ${R2}"
        echo "meryl histogram k${i}.meryl/ > k${i}_meryl.hist"
        echo "Rscript ${genomescope} -i k${i}_meryl.hist -k ${i} -o k${i}_genomescpe"

        mkdir -p ${i}
        cd ${i}
        meryl count k=${i} output k${i}.meryl ${R1} ${R2}
        meryl histogram k${i}.meryl/ > k${i}_meryl.hist
        Rscript ${genomescope} -i k${i}_meryl.hist -k ${i} -o k${i}_genomescpe
        cd ..
    done
elif [[ -n "$HiFi" ]]; then
    echo "Counting kmer from HiFi reads"
    for i in {19..31..2}; do
        echo "Running commands for k=$i"
        echo "meryl count k=${i} output k${i}.meryl ${HiFi}"
        echo "meryl histogram k${i}.meryl/ > k${i}_meryl.hist"
        echo "Rscript {genomescope} -i k${i}_meryl.hist -k ${i} -o k${i}_genomescpe"

        # Check if HiFi file exists and is readable
        if [[ ! -f "${HiFi}" ]]; then
            echo "Error: HiFi file ${HiFi} does not exist or is not readable."
            exit 1
        fi

        mkdir -p ${i}
        cd ${i}
        meryl count k=${i} output k${i}.meryl ${HiFi}
        meryl histogram k${i}.meryl/ > k${i}_meryl.hist
        Rscript ${genomescope} -i k${i}_meryl.hist -k ${i} -o k${i}_genomescpe
        cd ..
    done
else
    echo "No valid input files provided."
    echo "Exiting."
    exit 1
fi

echo "success" > success