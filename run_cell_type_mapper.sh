#!/bin/bash

# Check for a project marker file or directory
if [ ! -d "data" ] || [ ! -d "results" ] || [ ! -f "seurat_input.csv" ]; then
  echo "Error: Please run this script from the project root directory."
  echo "Expected to find data/, results/, and seurat_input.csv here."
  exit 1
fi

# Run the R script to generate the h5 files
Rscript "R/01_process_seurat.R"

# Read the sample names from the CSV
tail -n +2 seurat_input.csv | cut -d, -f1 | while read sample
do
  # 
  input_h5ad="data/${sample}_mmc_mtx.h5ad"
  output_json="results/${sample}_output.json"
  output_csv="results/${sample}_output.csv"

  # Check if the h5 file exists
  if [ ! -f "$input_h5ad" ]; then
    echo "Warning: $input_h5ad does not exist, skipping $sample."
    continue
  fi

  # Run cell_type_mapper using the mouse brain data
  python -m cell_type_mapper.cli.from_specified_markers \
    --query_path "$input_h5ad" \
  	--extended_result_path "$output_json" \
  	--csv_result_path "$output_csv" \
  	--drop_level CCN20230722_SUPT \
  	--cloud_safe False \
  	--query_markers.serialized_lookup data/taxonomies/mouse_markers_230821.json \
  	--precomputed_stats.path data/taxonomies/precomputed_stats_ABC_revision_230821.h5 \
  	--type_assignment.normalization raw \
  	--type_assignment.n_processors 4 
done