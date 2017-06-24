library(shiny)
library(foreign)
library(ruta)
library(rutavis)
library(htmlwidgets)
library(plotly)

# any fixed integer. Will limit the number of working visualizations
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
  ## Learner management --------------------------------------------------------
  PCA <- "pca"
  AUTOENCODER <- "autoencoder"
  RBM <- "rbm"

  learners <- list(PCA, AUTOENCODER)
  activations = c('none', 'relu', 'sigmoid', 'softrelu', 'tanh', 'leaky', 'elu', 'prelu', 'rrelu')
  optimizers = c('sgd', 'rmsprop', 'adam', 'adagrad', 'adadelta')

  for (i_ in 1:MAX_VIS) local({
    i <- i_
    observe({
      # this if statement allows the updateSelectInput to happen only when the visualization
      # html nodes have just been created
      if (!is.null(input$visCount) && input$visCount == i) {
        updateSelectInput(session, paste0("learnerCl", i), choices = learners, selected = learners[[2]])
        updateSelectInput(session, paste0("learnerAct", i), choices = activations, selected = activations[[1]])
        updateSelectInput(session, paste0("learnerOpt", i), choices = optimizers, selected = optimizers[[1]])
      }
    })
  })

  learnerFirst <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("learnerFirst", i)]] <- renderPrint({ dataLength[[i]]() })
  }))

  learnerLast <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("learnerLast", i)]] <- renderPrint({ dataLength[[i]]() })
  }))


  ## Learner

  learner <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      if (!is.null(dataLength[[i]]())) {
        act <- input[[paste0("learnerAct", i)]]
        if (act == 'none') act = NULL
        ruta.makeLearner("autoencoder", hidden = c(dataLength[[i]](), 3, dataLength[[i]]()), activation = act)
      }
    })
  }))

  ## Training

  model <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    reactive({
      if (!is.null(learner[[i]]()) && !is.null(task[[i]]())) {
        epoc <- as.numeric(input[[paste0("learnerRounds", i)]])
        opt <- input[[paste0("learnerOpt", i)]]
        lr <- as.numeric(input[[paste0("learnerRate", i)]])
        wd <- as.numeric(input[[paste0("learnerWD", i)]])
        md <- NULL
        react[[paste0("log", i)]] <- capture.output({
          tryCatch({
            ## available optimizers and parameters:
            ## mx.opt.sgd - learning.rate, momentum, wd, rescale.grad, clip_gradient, lr_scheduler
            ## mx.opt.rmsprop - learning.rate, gamma1, gamma2, wd, rescale.grad, clip_gradient, lr_scheduler
            ## mx.opt.adam - learning.rate, beta1, beta2, epsilon, wd, rescale.grad, clip_gradient, lr_scheduler
            ## mx.opt.adagrad - learning.rate, epsilon, wd, rescale.grad, clip_gradient, lr_scheduler
            ## mx.opt.adadelta - rho, epsilon, wd, rescale.grad, clip_gradient
            ## source: https://github.com/dmlc/mxnet/blob/master/R-package/R/optimizer.R

            md <- switch(opt,
                         sgd = {
                           mom <-
                             as.numeric(input[[paste0("learnerMomentum", i)]])
                           train(
                             learner[[i]](),
                             task[[i]](),
                             epochs = epoc,
                             optimizer = opt,
                             momentum = mom,
                             learning.rate = lr,
                             initializer.scale = scal,
                             wd = wd
                           )
                         },
                         adagrad = {
                           train(
                             learner[[i]](),
                             task[[i]](),
                             epochs = epoc,
                             optimizer = opt,
                             learning.rate = lr,
                             initializer.scale = scal,
                             wd = wd
                           )
                         },
                         rmsprop = {
                           gamma1 <- as.numeric(input[[paste0("learnerGamma1", i)]])
                           gamma2 <- as.numeric(input[[paste0("learnerGamma2", i)]])
                           train(
                             learner[[i]](),
                             task[[i]](),
                             epochs = epoc,
                             optimizer = opt,
                             gamma1 = gamma1,
                             gamma2 = gamma2,
                             learning.rate = lr,
                             initializer.scale = scal,
                             wd = wd
                           )
                         },
                         adam = {
                           beta1 <- as.numeric(input[[paste0("learnerBeta1", i)]])
                           beta2 <- as.numeric(input[[paste0("learnerBeta2", i)]])
                           train(
                             learner[[i]](),
                             task[[i]](),
                             epochs = epoc,
                             optimizer = opt,
                             beta1 = beta1,
                             beta2 = beta2,
                             learning.rate = lr,
                             initializer.scale = scal,
                             wd = wd
                           )
                         },
                         adadelta = {
                           rho <- as.numeric(input[[paste0("learnerRho", i)]])
                           train(
                             learner[[i]](),
                             task[[i]](),
                             epochs = epoc,
                             optimizer = opt,
                             rho = rho,
                             epsilon = eps,
                             learning.rate = lr,
                             wd = wd
                           )
                         })
          }, warning = function(warning) { warning }, error = function(error) { error })
        })

        md
      }
    })
  }))

  ## Plots ---------------------------------------------------------------------

  visTypes = c('internal')

  for (i_ in 1:MAX_VIS) local({
    i <- i_
    observe({
      # this if statement allows the updateSelectInput to happen only when the visualization
      # html nodes have just been created
      if (!is.null(input$visCount) && input$visCount == i) {
        updateSelectInput(session, paste0("visType", i), choices = visTypes, selected = visTypes[[1]])
      }
    })
  })

  plot <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("bigPlot", i)]] <- renderPlotly({
      validate(
        need(!is.null(task[[i]]()), "Please select a dataset")
      )
      validate(
        need(!is.null(model[[i]]()), "Please configure a learner")
      )
      plot(model[[i]](), task[[i]]())
    })
  }))

  ## Logs ----------------------------------------------------------------------
  console <- lapply(1:MAX_VIS, function(i_) local({
    i <- i_

    output[[paste0("console", i)]] <- renderPrint({
      cat(paste(react[[paste0("log", i)]], collapse = "\n"))
    })
  }))

})
