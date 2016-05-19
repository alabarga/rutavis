#' @export
newModel <- function(type, ...) {
  funcs <- list(
    pca = dlvis::newModel.pca,
    autoencoder = dlvis::newModel.autoencoder,
    rbm = dlvis::newModel.rbm
  )

  funcs[[type]](...)
}
