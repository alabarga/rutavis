#' @export
new_model <- function(type, ...) {
  funcs <- list(
    pca = rutavis::new_model.pca,
    autoencoder = rutavis::new_model.autoencoder,
    rbm = rutavis::new_model.rbm
  )

  funcs[[type]](...)
}
