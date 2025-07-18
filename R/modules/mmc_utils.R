# mmc_utils.R

library(Seurat)
library(tidyverse)
library(zellkonverter)
library(SingleCellExperiment)
library(biomaRt)

make_mapmycells_matrix <- function(seurat_obj, output_file = "data/mmc_matrix.csv") {
  expr_mat <- Seurat::LayerData(seurat_obj, assay = "RNA", layer = "counts")
  expr_df <- as.data.frame(as.matrix(expr_mat))
  expr_df <- tibble::rownames_to_column(expr_df, var = "gene")
  write.csv(expr_df, output_file, row.names = FALSE)
}

convert_matrix_gene_symbols_to_ensembl <- function(counts_mat, organism_dataset = "mmusculus_gene_ensembl") {

  gene_symbols <- rownames(counts_mat)
  
  message("Connecting to Ensembl BioMart...")
  mart <- biomaRt::useMart("ensembl", dataset = organism_dataset)
  mapping <- biomaRt::getBM(
    attributes = c("ensembl_gene_id", "mgi_symbol"),
    filters = "mgi_symbol",
    values = gene_symbols,
    mart = mart
  )
  
  # Create mapping vector: symbol → Ensembl
  gene_map <- setNames(mapping$ensembl_gene_id, mapping$mgi_symbol)
  matched <- intersect(gene_symbols, names(gene_map))
  message(length(matched), " / ", length(gene_symbols), " genes mapped to Ensembl IDs.")
  
  # Subset and rename
  mat_out <- counts_mat[matched, , drop = FALSE]
  rownames(mat_out) <- gene_map[matched]
  
  # Drop duplicates
  dups <- duplicated(rownames(mat_out))
  if (any(dups)) {
    message("Dropping ", sum(dups), " duplicated Ensembl IDs.")
    mat_out <- mat_out[!dups, , drop = FALSE]
  }
  
  return(mat_out)
}


make_mapmycells_h5 <- function(seurat_obj, output_file = "data/mmc_matrix.h5ad") {
  # Convert to SingleCellExperiment, using raw counts
  # Set assay to fix seurat5 issue
  DefaultAssay(seurat_obj) <- "RNA"
  
  # Convert raw counts to sce
  counts_mat <- Seurat::GetAssayData(seurat_obj, assay = "RNA", slot = "counts")
  ensembl_matrix <- convert_matrix_gene_symbols_to_ensembl(counts_mat)
  # Coerce matrix to dense so it is recognized as a dataset
  ensembl_matrix <- as.matrix(ensembl_matrix)
  sce <- SingleCellExperiment::SingleCellExperiment(list(counts = ensembl_matrix))
  
  # Write to the output file
  zellkonverter::writeH5AD(sce, output_file)
}