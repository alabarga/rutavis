#' @import graphics
#' @import plotly
plot2d <- function(model, classes, name) {
  classes <- as.factor(unlist(classes))
  #graphics::plot(model, col = classes)
  #graphics::legend(7, 4.3, unique(classes), col=1:length(classes), pch=1)
  mm <- as.data.frame(model)
  plotly::plot_ly(
    mm, x = mm[[1]], y = mm[[2]], color = classes, mode = "markers", type = "scatter"
  )
}

#' @import scatterplot3d
plot3d <- function(model, classes, name) {
  scatterplot3d::scatterplot3d(
    model,
    color = as.numeric(as.factor(unlist(classes)))
  )
}

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
    stop("rutavis doesn't currently support more than 3 dimensions")
  }

  plotFunction(deepF, task$data[, task$cl], task$id)
}
