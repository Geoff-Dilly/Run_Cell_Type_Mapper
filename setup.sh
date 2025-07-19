#!/bin/bash

# install.sh
# Author: Geoff Dilly
# Set up an environment and directory structure to run cell_type_mapper

# Get the folder containing install.sh script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

# Make the directory structure
mkdir -p src/
mkdir -p data/
mkdir -p results/
mkdir -p R/
mkdir -p R/modules
mkdir -p data/taxonomies

# Add a .here file for R scripts
touch .here

if [ ! -f ".gitignore" ]; then
cat > .gitignore <<'EOF'
# Ignore generated data and logs
data/*
results/*
src/cell_type_mapper

EOF
fi

if [ ! -f "mapmycells_env.yaml" ]; then
cat > mapmycells_env.yaml <<'EOF'
name: mapmycells_env
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - r-base
  - python=3.11
  - r-seurat
  - h5py
  - r-curl
  - r-httr
  - r-tidyverse
  - r-here
  - scanpy=1.10.0
  - anndata=0.12.0
  - bioconductor-singlecellexperiment
  - bioconductor-zellkonverter
  - bioconductor-org.Mm.eg.db
  - bioconductor-AnnotationDbi

  # Biomart may need to be installed in R
  # conda run -n mapmycells_env Rscript -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", repos="https://cloud.r-project.org")'
  # conda run -n mapmycells_env Rscript -e 'BiocManager::install("biomaRt")'
  # conda run -n mapmycells_env Rscript -e 'install.packages("curl", repos="https://cloud.r-project.org")'

EOF
fi

# Check for git and conda
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Install git first!"
    exit 1
fi
if ! command -v conda &> /dev/null; then
    echo "Error: conda is not installed. Install Anaconda or Miniconda first!"
    exit 1
fi

# Clone the MMC source code
git clone https://github.com/AllenInstitute/cell_type_mapper src/cell_type_mapper

# Make a Conda env
conda env create -f mapmycells_env.yaml

# Install difficult packages in R
conda run -n mapmycells_env Rscript -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", repos="https://cloud.r-project.org")'
conda run -n mapmycells_env Rscript -e 'install.packages("curl", repos="https://cloud.r-project.org")'
conda run -n mapmycells_env Rscript -e 'BiocManager::install("biomaRt")'

# Install MMC tool from source code
conda run -n mapmycells_env pip install -e src/cell_type_mapper

# Download the mouse brain MMC taxonomy (or another taxonomy json)
curl --output-dir data/taxonomies -O https://allen-brain-cell-atlas.s3-us-west-2.amazonaws.com/mapmycells/WMB-10X/20240831/mouse_markers_230821.json

# Download the mouse brain precomputed stats (or another)
curl --output-dir data/taxonomies -O https://allen-brain-cell-atlas.s3-us-west-2.amazonaws.com/mapmycells/WMB-10X/20240831/precomputed_stats_ABC_revision_230821.h5
