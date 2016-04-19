library(shiny)
library(foreign)
library(dlvis)

shinyServer(function(input, output, session) {
  type_options <- list()

  if ("h2o" %in% rownames(installed.packages()))
    type_options <- c(type_options, "autoencoder")

  updateSelectInput(session, "left_type", choices = type_options, selected = type_options[[1]])

  dataset <- reactive({
    if (!is.null(input$filename)) {
      datapath <- input$filename$datapath
      read.arff(datapath)
    } else {
      NULL
    }
  })

  output$dataset_name <- renderText({
    if (is.null(input$filename)) "No dataset loaded" else input$filename$name
  })
})
