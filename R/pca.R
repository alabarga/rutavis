#' @export
new_model.pca <- function(dataset, class_col = length(dataset), dimensions, name, ...) {
  inputs <- dataset[-class_col]

  if (!all(sapply(inputs, function(col) "numeric" %in% class(col))))
    stop("rutavis: Input columns must be numeric for PCA to work")

  # Principal Components Analysis
  results <- stats::prcomp(dataset[-class_col], center = TRUE, scale = FALSE, ...)
  dlmodel <- list(
    model = results$x[, 1:dimensions],
    classes = dataset[class_col],
    name = name
  )
  class(dlmodel) <- "dlmodel"
  dlmodel

  # # Truncate to specified dimension number
  # truncated <- results$x[, 1:dimensions] %*% t(results$rotation[, 1:dimensions])
  # print(dim(results$x[, 1:dimensions]))
  # print(dim(results$rotation[, 1:dimensions]))
  # print(dim(truncated))
  #
  # # Rescale and restore center to data
  # if (any(results$scale != FALSE)) {
  # 	truncated <- scale(truncated, center = FALSE, scale = 1/results$scale)
  # }
  # if (any(results$center != FALSE)) {
  #   truncated <- scale(truncated, center = -1 * results$center, scale = FALSE)
  # }
  # print(dim(dataset))
  #
  # truncated
}
