#' @export
new_model <- function(type, ...) {
  funcs <- list(
    pca = dlvisR::new_model.pca,
    autoencoder = dlvisR::new_model.autoencoder,
    rbm = dlvisR::new_model.rbm
  )

  funcs[[type]](...)
}
