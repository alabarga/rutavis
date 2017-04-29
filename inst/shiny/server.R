library(shiny)
library(foreign)
library(ruta)
library(rutavis)

MAX_VIS <- 32

shinyServer(function(input, output, session) {
  ## Globals -------------------------------------------------------------------
  output$MAX_VIS <- renderPrint({ MAX_VIS })

  react <- reactiveValues()

  ## Task management -----------------------------------------------------------
  dataset <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      taskData <- input[[paste0("taskData", i)]]
      if (!is.null(taskData)) {
        read.arff(taskData$datapath)
      }
    })
  }))

  title <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_
    output[[paste0("title", i)]] <- renderPrint({ cat("Visualization ", i) })
  }))

  datasetId <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("datasetId", i)]] <- renderText({
      taskData <- input[[paste0("taskData", i)]]
      validate(
        need(!is.null(taskData), "No dataset loaded")
      )
      taskData$name
    })
  }))

  for (i_ in 1:MAX_VIS) local({
    i <- i_

    observe({
      ds <- dataset[[i]]

      if (!is.null(ds())) {
        attributes <- 0:length(ds())
        names(attributes) <- c("Unlabeled dataset", paste0(1:length(ds()), ": ", names(ds())))
        updateSelectInput(session, paste0("taskCl", i), choices = attributes)
      }
    })
  })

  task <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      ds = dataset[[i]]
      if (!is.null(ds())) {
        cl = as.numeric(input[[paste0("taskCl", i)]])
        if (cl == 0) cl = NULL

        ruta.makeUnsupervisedTask(
          id = input[[paste0("taskData", i)]]$name,
          data = ds(),
          cl = cl
        )
      }
    })
  }))

  dataLength <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      task <- task[[i]]
      if (!is.null(task())) {
        length(task()$data) - ifelse(is.null(task()$cl), 0, 1)
      }
    })
  }))

  learnerFirst <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("learnerFirst", i)]] <- renderPrint({ dataLength[[i]]() })
  }))

  learnerLast <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("learnerLast", i)]] <- renderPrint({ dataLength[[i]]() })
  }))

  ## Learner management --------------------------------------------------------
  PCA <- "pca"
  AUTOENCODER <- "autoencoder"
  RBM <- "rbm"

  learners <- list(PCA, AUTOENCODER)
  activations = c('none', 'relu', 'sigmoid', 'softrelu', 'tanh')

  for (i_ in 1:MAX_VIS) local({
    i <- i_
    observe({
      # this if statement allows the updateSelectInput to happen only when the visualization
      # html nodes have just been created
      if (!is.null(input$visCount) && input$visCount == i) {
        updateSelectInput(session, paste0("learnerCl", i), choices = learners, selected = learners[[2]])
        updateSelectInput(session, paste0("learnerAct", i), choices = activations, selected = activations[[1]])
      }
    })
  })

  ## Activation

  learner = lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      if (!is.null(dataLength[[i]]())) {
        act = input[[paste0("learnerAct", i)]]
        if (act == 'none') act = NULL
        ruta.makeLearner("autoencoder", hidden = c(dataLength[[i]](), 2, dataLength[[i]]()), activation = act)
      }
    })
  }))

  ## Training

  model = lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      if (!is.null(learner[[i]]()) && !is.null(task[[i]]())) {
        react[[paste0("log", i)]] <- capture.output({
          md <- train(learner[[i]](), task[[i]](), epochs = as.numeric(input[[paste0("learnerRounds", i)]]))
        })

        md
      }
    })
  }))

  ## Plots ---------------------------------------------------------------------
  # observe({
  #   output[[paste0("bigPlot", i())]] <- renderPlot({})
  # })
  # output[[paste0("bigPlot", i())]] <- renderPlot({ getPlot(meow, i()) }, width = 600, height = 600)


  plot <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("bigPlot", i)]] <- renderPlot({
      validate(
        need(!is.null(task[[i]]()), "Please select a dataset")
      )
      validate(
        need(!is.null(model[[i]]()), "Please configure a learner")
      )
      rutavis::plot.rutaModel(model[[i]](), task[[i]]())
    }, width = 600, height = 600)
  }))

  ## Logs ----------------------------------------------------------------------
  console <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("console", i)]] <- renderPrint({
      cat(paste(react[[paste0("log", i)]], collapse = "\n"))
    })
  }))

  ## Event test
  # output$console1 <- renderPrint({ input$visCount })
  # plots <- reactive({
  #   lapply(1:as.numeric(input$visCount), function(i) {
  #     my_i <- i
  #     plotName <- paste0("bigPlot", my_i)
  #     output[[plotName]] <- renderPlot({
  #       validate(
  #         need(!is.null(task()), "Please select a dataset")
  #       )
  #       validate(
  #         need(!is.null(model()), "Please configure a learner")
  #       )
  #       rutavis::plot.rutaModel(model(), task())
  #     }, width = 600, height = 600)
  #   })
  # })
})
