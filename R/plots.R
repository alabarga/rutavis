#' @import graphics
plot2d <- function(model, classes, name) {
  classes <- as.factor(unlist(classes))
  graphics::plot(as.matrix(model), col = classes)
  graphics::legend(7, 4.3, unique(classes), col=1:length(classes), pch=1)
}

#' @import scatterplot3d
plot3d <- function(model, classes, name) {
  scatterplot3d::scatterplot3d(
    as.matrix(model),
    color = as.numeric(as.factor(unlist(classes)))
  )
  #scatter3D(as.vector(features_ae[1]), as.vector(features_ae[2]), as.vector(features_ae[3]), colvar = as.numeric(unlist(dataset[class_col])))
}

#' @export
plot.dlmodel <- function(dlmodel, dimensions) {
  if (missing(dimensions))
    dimensions <- ncol(dlmodel$model)

  if (dimensions == 2) {
    plot2d(dlmodel$model, dlmodel$classes, dlmodel$name)
  } else {
    plot3d(dlmodel$model, dlmodel$classes, dlmodel$name)
  }
}
