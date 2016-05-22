#' @export
new_model <- function(type, ...) {
  funcs <- list(
    pca = dlvis::new_model.pca,
    autoencoder = dlvis::new_model.autoencoder,
    rbm = dlvis::new_model.rbm
  )

  funcs[[type]](...)
}
