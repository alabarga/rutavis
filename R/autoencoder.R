#-------------------------------------------------------------------------------
# TODO
#-------------------------------------------------------------------------------
# [ ] Download actual arrhythmia dataset
# [ ] Use / partition mnist
# [X] Save generated models as Rdata
# [ ] Compose animated gifs out of graphics
# [ ] Everything with RBMs

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
#' @export
newModel.autoencoder <- function(dataset, class_col = length(dataset), layer, activation, epoch_num, name) {
  if (!requireNamespace("h2o", quietly = TRUE)) {
    stop("dlvis: Package 'h2o' is not installed and is needed for autoencoder functionality")
  }

  print(class_col)

  h2o::h2o.init()

  dataset.h2o <- h2o::as.h2o(dataset)

  inputs <- 1:(ncol(dataset)-1)

  dataset.h2o <- dataset.h2o[-class_col]

  basename <- paste0(name, "_", activation, "_", paste0(layer, collapse = "_"), "_", epoch_num, "epochs")
  rdaname <- paste0("save/", basename, ".rda")

  # if (file.exists(rdaname)) {
  #   load(rdaname)
  #   tryCatch(
  #     {
  #       ae_model <- h2o.loadModel(paste0(getwd(), "/save/", savename))
  #       cat("Model loaded from disk\n")
  #     },
  #     error = function(e) cat("Something happened when loading saved model. Trying to continue...\n")
  #   )
  # } else {
    cat("Generating new model...\n")
    ae_model <- h2o::h2o.deeplearning(
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
    h2o::h2o.saveModel(ae_model, path = "save")
    savename <- ae_model@model_id
    save(savename, file = rdaname)
    cat(paste0(savename, "\n"))
  # }
  #str(ae_model)

  features_ae <- h2o::h2o.deepfeatures(ae_model, dataset.h2o, layer = floor((length(layer) + 1)/2))

  dlmodel <- list(
    model = features_ae,
    classes = dataset[class_col],
    name = name
  )
  class(dlmodel) <- "dlmodel"
  dlmodel
}
