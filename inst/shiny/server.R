library(shiny)
library(foreign)
library(dlvis)

shinyServer(function(input, output, session) {
  type_options <- list()

  if ("h2o" %in% rownames(installed.packages()))
    type_options <- c(type_options, "autoencoder")

  updateSelectInput(session, "left_type", choices = type_options, selected = type_options[[1]])
  updateSelectInput(session, "right_type", choices = type_options, selected = type_options[[1]])

  dataset <- reactive({
    if (!is.null(input$filename)) {
      datapath <- input$filename$datapath
      read.arff(datapath)
    } else {
      NULL
    }
  })

  observe({
    updateSelectInput(session, "class_pos", choices = 1:length(dataset()))

    updateSelectInput(session, "left_activation", choices = c("RectifierWithDropout", "Tanh"))
    updateSelectInput(session, "right_activation", choices = c("RectifierWithDropout", "Tanh"))
  })

  output$left_plot <- renderPlot({
    if (!is.null(dataset())) {
      print(input$class_pos)
      dlmodel <- newModel.autoencoder(dataset(), class_col = as.numeric(input$class_pos), layer = 2, activation = input$left_activation, epoch_num = input$left_epochs, name = "a")
      plot.dlmodel(dlmodel)
    }
  })
  output$right_plot <- renderPlot({
    if (!is.null(dataset())) {
      print(input$class_pos)
      dlmodel <- newModel.autoencoder(dataset(), class_col = as.numeric(input$class_pos), layer = 2, activation = input$right_activation, epoch_num = input$right_epochs, name = "a")
      plot.dlmodel(dlmodel)
    }
  })

  output$left_first_layer <- renderText({ length(dataset()) - 1 })
  output$left_last_layer <- renderText({ length(dataset()) - 1 })
  output$right_first_layer <- renderText({ length(dataset()) - 1 })
  output$right_last_layer <- renderText({ length(dataset()) - 1 })

  output$dataset_name <- renderText({
    if (is.null(input$filename)) "No dataset loaded" else input$filename$name
  })
})
