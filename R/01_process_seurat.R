# mmc_utils.R

library(Seurat)
library(zellkonverter)
library(SingleCellExperiment)
library(readr)
library(here)
setwd(here())

# Load the necessary functions
source("R/modules/mmc_utils.R")

# Load the input sample informaton
input_table <- read_csv("seurat_input.csv")

# Split into a DF for each entry
sample_list <- split(input_table, seq_len(nrow(input_table)))

for (sample in sample_list) {
	sample_name <- sample$sample_name
	sample_seurat <- readRDS(sample$input_file)
	output_file <- file.path("data", paste0(sample_name, "_mmc_mtx.h5ad"))
	make_mapmycells_h5(seurat_obj = sample_seurat, output_file = output_file)
}
