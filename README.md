#  Run Cell Type Mapper

**Author:** Geoff Dilly, PhD
**Lab:** Messing Lab, UT Austin

## Overview

This repository contains tools for running The Allen Institute's [Cell Type Mapper](https://portal.brain-map.org/atlases-and-data/rnaseq/cell-type-mapper) tool on Seurat-processed single-cell sequencing data. It is intended to supplement clustering analysis performed in other single-cell analysis pipelines. This repo is intended for neuroscience research in the Messing Lab at UT Austin, and can be adapted for similar use.  

## Contents

- `setup.sh`: Creates a directory structure and Conda environment recommended for this repo.
- `R/`: R scripts and modules for extracting and formatting data from Seurat objects.
- `src/`: Python code for installing Cell Type Mapper.
- `data/`: Directory for raw data and MMC taxonomies.
- `results/`: Directory for outputs.

## Usage

1. **Setup the directory structure and environment:**
	```sh
	git clone <repo_url>
	cd <repo_directory>
	bash setup.sh
	```
2. **Set up `seurat_input.csv`:**
	- `sample_name`: Sample ID
	- `input_file`: Path to Seurat file (.RDS)  

		**Example:**
		```
		sample_name,input_file
		Subject_1,"data/sub1_seurat.RDS"
		Subject_2,"data/sub2_seurat.RDS"
		Subject_3,"data/sub3_seurat.RDS"
		Subject_4,"data/sub4_seurat.RDS"
		```
3. **Activate conda environment:**
	```
	conda activate mapmycells_env
	```
4. **Run `run_cell_type_mapper.sh`**
	- This will generate an .h5ad file formatted for Map My Cells, and an output .h5ad and CSV containing the predicted cell types for each cell in the input file.
	```sh
	bash run_cell_type_mapper.sh
	```

## Requirements

- Anaconda
- See `mapmycells_env.yaml` for dependencies

## Acknowledgements

This repository is maintained for experiments in the Messing Lab at UT Austin. 
