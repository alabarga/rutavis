#' @import foreign
#' @export
start_gui <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("dlvisR: Package 'shiny' is required to start the GUI")
  }

  shiny::runApp(appDir = system.file("shiny", package = "dlvisR"), launch.browser = TRUE)

  invisible()
}
