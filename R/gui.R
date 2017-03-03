#' @import foreign
#' @export
start_gui <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("rutavis: Package 'shiny' is required to start the GUI")
  }

  shiny::runApp(appDir = system.file("shiny", package = "rutavis"), launch.browser = TRUE)

  invisible()
}
