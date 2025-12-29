#module load python
generateYAML.py \
    --download_dir culicoides_sonorensis/egapx_RNA_download \
    --genome_fasta culicoides_sonorensis/GCA_047716325.1_idCulSono.KS.ABADRU.1.0.female_genomic.fna.gz \
    --taxonomic_ID 179676 \
    --annotation_provider "Asif_Ahmed" \
    --annotation_name_prefix "GCA_047716325.1" \
    --locus_tag_prefix "CulSono.KS.ABADRU"
    --output_file sono.yaml
	

###list all RNAseq data####
find culicoides_sonorensis/egapx_RNA_download/ -type f -exec readlink -f {} \;

## submit job###	
sbatch -A OD-230654 egapx_annotation_pipeline/run_egapx_local.slurm sono.yaml culicoides_sonorensis/annotation_output
	