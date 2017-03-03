#' @export
new_model.rbm <- function(dataset, class_col = length(dataset), epoch_num, num_cd, name) {
  if (!requireNamespace("darch", quietly = TRUE)) {
    stop("rutavis: Package 'darch' is not installed and is needed for Restricted Boltzmann Machine functionality")
  }

  # rbm <- newRBM(length(dataset) - 1, 2, batchSize = 1)
  # trainRBM(rbm, as.matrix(dataset[-class_col]), numEpochs = epoch_num, numCD = num_cd)
  #
  # print(class(rbm))
  #
  # dlmodel <- list(
  #   model = rbm@output,
  #   classes = dataset[class_col],
  #   name = name
  # )
  # class(dlmodel) <- "dlmodel"
  # dlmodel
  #
  # rbm
  dataset <- iris
  class_col <- 5
  num_cd <- 1
  epoch_num <- 1
  darch <- newDArch(c(length(dataset)-1, 2, length(dataset)-1), batchSize = 2)
  ds <- createDataSet(dataset[-class_col], dataset[-class_col])
  what <- preTrainDArch(darch, ds, epoch_num, num_cd)
}
