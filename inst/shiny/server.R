library(shiny)
library(foreign)
library(dlvis)

shinyServer(function(input, output, session) {
  PCA <- "pca"
  AUTOENCODER <- "autoencoder"
  RBM <- "rbm"

  type_options <- list(PCA)

  if ("h2o" %in% rownames(installed.packages()))
    type_options <- c(type_options, AUTOENCODER)

  if ("darch" %in% rownames(installed.packages()))
    type_options <- c(type_options, RBM)

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
    attributes <- 1:length(dataset())
    names(attributes) <- paste(attributes, "-", names(dataset()))
    updateSelectInput(session, "class_pos", choices = attributes)

    updateSelectInput(session, "left_activation", choices = c("RectifierWithDropout", "Tanh"))
    updateSelectInput(session, "right_activation", choices = c("RectifierWithDropout", "Tanh"))
  })

  output$left_plot <- renderPlot({
    if (!is.null(dataset())) {
      layers <- sapply(1:input$left_layer_count, function(i) input[[paste0("left_layer", i)]])

      dlmodel <-
        if (input$left_type == AUTOENCODER)
          new_model.autoencoder(dataset(), class_col = as.numeric(input$class_pos), layer = layers, activation = input$left_activation, epoch_num = input$left_epochs, name = "")
        else# if (input$left_type == PCA)
          new_model.pca(dataset(), class_col = as.numeric(input$class_pos), dimensions = input$left_dimensions, name = "")

      plot.dlmodel(dlmodel)
    }
  })
  output$right_plot <- renderPlot({
    if (!is.null(dataset())) {
      layers <- sapply(1:input$right_layer_count, function(i) input[[paste0("right_layer", i)]])

      dlmodel <-
        if (input$right_type == AUTOENCODER)
          new_model.autoencoder(dataset(), class_col = as.numeric(input$class_pos), layer = layers, activation = input$right_activation, epoch_num = input$right_epochs, name = "")
        else# if (input$left_type == PCA)
          new_model.pca(dataset(), class_col = as.numeric(input$class_pos), dimensions = input$right_dimensions, name = "")

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
