#' @import foreign
#' @export
start_gui <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("dlvis: Package 'shiny' is required to start the GUI")
  }

  shiny::runApp(appDir = system.file("shiny", package = "dlvis"), launch.browser = TRUE)

  invisible()
}
