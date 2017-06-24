#' @import plotly
plot2d <- function(model, classes, name, ...) {
  classes <- as.factor(unlist(classes))
  mm <- as.data.frame(model)
  plotly::plot_ly(
    mm, x = mm[[1]], y = mm[[2]], color = classes,
    mode = "markers", type = "scatter",
    ...
  )
}

#' @import plotly
plot3d <- function(model, classes, name, ...) {
  classes <- as.factor(unlist(classes))
  mm <- as.data.frame(model)
  plotly::plot_ly(
    mm, x = mm[[1]], y = mm[[2]], z = mm[[3]],
    color = classes, type = "scatter3d",
    ...
  )
}

#' Plot the deep features of a learned model.
#'
#' Plot the deep features of a learned model.
#'
#' @param model A trained \code{rutaModel} object.
#' @param task A \code{rutaTask} object.
#' @param ... Additional parameters for the plotting library
#' @import ruta
#' @export
plot.rutaModel <- function(model, task, ...) {
  deepF <- ruta::ruta.deepFeatures(model, task)
  dimensions <- ncol(deepF)

  plotFunction <- if (dimensions == 2) {
    plot2d
  } else if (dimensions == 3) {
    plot3d
  } else {
    stop(paste0("rutavis doesn't currently support more than 3 dimensions (dimensions = ", dimensions, ")"))
  }

  plotFunction(deepF, task$data[, task$cl], task$id, ...)
}
