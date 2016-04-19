#!/usr/bin/env Rscript
#-------------------------------------------------------------------------------
# TODO
#-------------------------------------------------------------------------------
# [ ] Download actual arrhythmia dataset
# [ ] Use / partition mnist
# [X] Save generated models as Rdata
# [ ] Compose animated gifs out of graphics
# [ ] Everything with RBMs

#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
library(foreign)
library(h2o)
#library(plot3D)
library(ggplot2)
library(scatterplot3d)

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
data(iris)
config <- list(

  datasets = list(
    # list(
    #   name = "arrhythmia.arff",
    #   format = "arff",
    #   class_col = -1
    # ),
    # list(
    #   name = "wdbc.arff",
    #   format = "arff",
    #   class_col = 1
    # ),
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
    list(
      name = "iris",
      frame = iris,
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

config1 <- list(
  datasets = list(list(name = "arrhythmia.arff", class_col = -1)),
  layers = list(c(3)),
  activations = c("Tanh"),
  epochs = c(1)
)

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
plot_autoencoder <- function(dataset, class_col = length(dataset), layer, activation, epoch_num, name) {
  dataset.h2o <- as.h2o(dataset)

  inputs <- 1:(ncol(dataset)-1)

  dataset.h2o <- dataset.h2o[-class_col]

  #print(as.data.frame(dataset.h2o))

  # pca_model <- h2o.prcomp(arr.h2o, k = 3)
  # plot(pca_model@model$sdev)
  #
  # features_pca <- h2o.predict(pca_model, arr.h2o, num_pc=50)
  # summary(features_pca)

  basename <- paste0(name, "_", activation, "_", paste0(layer, collapse = "_"), "_", epoch_num, "epochs")
  rdaname <- paste0("save/", basename, ".rda")

  if (file.exists(rdaname)) {
    load(rdaname)
    tryCatch(
      {
        ae_model <- h2o.loadModel(paste0(getwd(), "/save/", savename))
        cat("Model loaded from disk\n")
      },
      error = function(e) cat("Something happened when loading saved model. Trying to continue...\n")
    )
  } else {
    cat("Generating new model...\n")
    ae_model <- h2o.deeplearning(
      x = inputs,
      training_frame = dataset.h2o,
      activation = activation,
      autoencoder = T,
      hidden = layer,
      epochs = epoch_num,
      ignore_const_cols = F,
      max_w2 = 10,
      l1 = 1e-5
    )

    #save(ae_model, file = rdaname)
    h2o.saveModel(ae_model, path = "save")
    savename <- ae_model@model_id
    save(savename, file = rdaname)
    cat(paste0(savename, "\n"))
  }
  #str(ae_model)

  features_ae <- h2o.deepfeatures(ae_model, dataset.h2o, layer = floor((length(layer) + 1)/2))
  #summary(features_ae)

  #data_reconstr <- h2o.predict(ae_model, dataset.h2o)
  #summary(data_reconstr)

  pngname <- paste0("out/", basename, ".png")
  cat(paste0(pngname, "\n"))
  png(pngname)

  if (ncol(features_ae) == 2) {
    classes <- as.factor(unlist(dataset[class_col]))
    plot(as.matrix(features_ae), col = classes)
    legend(7,4.3,unique(classes),col=1:length(classes),pch=1)
  } else {
    scatterplot3d(
      as.matrix(features_ae),
      color = as.numeric(as.factor(unlist(dataset[class_col])))
    )
    #scatter3D(as.vector(features_ae[1]), as.vector(features_ae[2]), as.vector(features_ae[3]), colvar = as.numeric(unlist(dataset[class_col])))
  }

  dev.off()

  pngname
}

#-------------------------------------------------------------------------------
# Main script
#-------------------------------------------------------------------------------
main <- function() {
  set.seed(10897)
  h2o.server <- h2o.init(nthreads = -1)

  for (ds in config$datasets) {

    filename <- paste0("data/", ds$name)
    dataset <- if (class(ds$frame) == "data.frame")
        ds$frame
      else if (ds$format == "csv")
        read.csv(filename, header = FALSE)
      else if (ds$format == "arff")
        read.arff(filename)
      else
        error("Invalid format")

    name <- if (class(ds$name) == "character")
        ds$name
      else
        substitute(dataset)

    class_col <- ifelse(ds$class_col < 1, length(dataset), ds$class_col)

    for (layer in config$layers) {

      layer <- ifelse(layer < 2, round(layer * length(dataset)), layer)

      for (activation in config$activations) {
        for (epoch_num in config$epochs) {
          plot_autoencoder(dataset, class_col, layer, activation, epoch_num, name)
        } # epochs
      } # activations
    } # layers
  } # datasets
}
