#-------------------------------------------------------------------------------
# TODO
#-------------------------------------------------------------------------------
# [ ] Download actual arrhythmia dataset
# [ ] Use / partition mnist
# [X] Save generated models as Rdata
# [ ] Compose animated gifs out of graphics
# [ ] Everything with RBMs

#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
library(dlvis)

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
data(iris)
config <- list(

  datasets = list(
    # list(
    #   name = "arrhythmia.arff",
    #   format = "arff",
    #   class_col = -1
    # ),
    # list(
    #   name = "wdbc.arff",
    #   format = "arff",
    #   class_col = 1
    # ),
    # list(
    #   name = "pima-indians-diabetes.data",
    #   format = "csv",
    #   class_col = -1
    # ),
    # list(
    #   name = "chronic_kidney_disease_full.arff",
    #   format = "arff",
    #   class_col = -1
    # ),
    list(
      name = "iris",
      frame = iris,
      class_col = -1
    )
  ),

  layers = list(
    c(3),
    c(0.75, 3, 0.75),
    c(2),
    c(0.5, 2, 0.5),
    c(1.5, 3, 1.5),
    c(1.5, 1, 2, 1, 1.5),
    c(1.5, 1, 3, 1, 1.5)
  ),

  activations = c(
    "Tanh",
    "RectifierWithDropout"
  ),

  epochs = c(
    1,
    10,
    100,
    1000
  )
)

#-------------------------------------------------------------------------------
# Main script
#-------------------------------------------------------------------------------
main <- function() {
  set.seed(10897)
  h2o.server <- h2o.init(nthreads = -1)

  for (ds in config$datasets) {

    filename <- paste0("data/", ds$name)
    dataset <- if (class(ds$frame) == "data.frame")
        ds$frame
      else if (ds$format == "csv")
        read.csv(filename, header = FALSE)
      else if (ds$format == "arff")
        read.arff(filename)
      else
        error("Invalid format")

    name <- if (class(ds$name) == "character")
        ds$name
      else
        substitute(dataset)

    class_col <- ifelse(ds$class_col < 1, length(dataset), ds$class_col)

    for (layer in config$layers) {

      layer <- ifelse(layer < 2, round(layer * length(dataset)), layer)

      for (activation in config$activations) {
        for (epoch_num in config$epochs) {
          plot(newModel.autoencoder(dataset, class_col, layer, activation, epoch_num, name))
        } # epochs
      } # activations
    } # layers
  } # datasets
}
