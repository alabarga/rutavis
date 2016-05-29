#!/usr/bin/env Rscript
#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
#library(dlvis)
library(foreign)
devtools::load_all()

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
set.seed(10897)

data(iris)
mnist_file <- "experiments/mnist_subset.rda"
if (!file.exists(mnist_file)) {
  mnist <- read.arff("experiments/mnist_test.arff")
  mnist_subset <- mnist[sample(1:10000, 1000), ]
  save(mnist_subset, file = mnist_file)
}
load(mnist_file)

config <- list(

  datasets = list(
    # list(
    #   name = "arrhythmia.arff",
    #   format = "arff",
    #   class_col = -1
    # ),
    list(
      name = "wdbc.arff",
      format = "arff",
      class_col = 1
    ),
    # list(
    #   name = "pima-indians-diabetes.data",
    #   format = "csv",
    #   class_col = -1
    # ),
    # list(
    #   name = "chronic_kidney_disease_full.arff",
    #   format = "arff",
    #   class_col = -1
    # ),
    # list(
    #   name = "iris",
    #   frame = iris,
    #   class_col = -1
    # ),
    list(
      name = "mnist",
      frame = mnist_subset,
      class_col = -1
      )
  ),

  layers = list(
    c(3),
    c(0.75, 3, 0.75),
    c(2),
    c(0.5, 2, 0.5),
    c(1.5, 3, 1.5),
    c(1.5, 1, 2, 1, 1.5),
    c(1.5, 1, 3, 1, 1.5)
    #c(1.5, 1, 0.5, 0.25, 3, 0.25, 0.5, 1, 1.5)
  ),

  activations = c(
    "Tanh",
    "RectifierWithDropout"
  ),

  epochs = c(
    1,
    10,
    100,
    1000
  )
)

readDatasetConfig <- function(ds) {
  filename <- paste0("experiments/", ds$name)
  if (class(ds$frame) == "data.frame")
      ds$frame
    else if (ds$format == "csv")
      read.csv(filename, header = FALSE)
    else if (ds$format == "arff")
      read.arff(filename)
    else
      error("Invalid format")
}

for (ds in config$datasets) {
  dataset <- readDatasetConfig(ds)

  name <- if (class(ds$name) == "character")
      ds$name
    else
      substitute(dataset)

  class_col <- ifelse(ds$class_col < 1, length(dataset), ds$class_col)

  for (layer in config$layers) {

    layer <- ifelse(layer < 2, round(layer * length(dataset)), layer)

    for (activation in config$activations) {
      for (epoch_num in config$epochs) {
        basename <- paste0(name, "_", activation, "_", paste0(layer, collapse = "_"), "_", epoch_num, "epochs")
        pngname <- paste0("experiments/out/", basename, ".png")
        cat(paste0(pngname, "\n"))

        if (!file.exists(pngname))
          tryCatch({
            themodel <- new_model.autoencoder(dataset, class_col, layer, activation, epoch_num, name)

            png(pngname)
            plot(themodel)
            dev.off()
          }, error = function(e) { cat("Couldn't train this autoencoder\n") })
      } # epochs
    } # activations
  } # layers

  # pca
  png(paste0("experiments/out/", name, "_pca2.png"))
  plot(new_model.pca(dataset, class_col, 2, name))
  dev.off()
  png(paste0("experiments/out/", name, "_pca3.png"))
  plot(new_model.pca(dataset, class_col, 3, name))
  dev.off()
} # datasets
