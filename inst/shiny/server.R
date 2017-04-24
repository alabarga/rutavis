library(shiny)
library(foreign)
library(ruta)
library(rutavis)

# ta = ruta.makeUnsupervisedTask(
#   id = paste0("task", 0),
#   data = iris,
#   cl = 5
# )
# ae = ruta.makeLearner("autoencoder", hidden = c(4, 2, 4))
# md = train(ae, ta, epochs = 10)

shinyServer(function(input, output, session) {
  ## Globals--------------------------------------------------------------------
  values <- reactiveValues()

  ## Visualizations ------------------------------------------------------------
  visualizationId <- reactive({ input$visualizationId })

  ## Task management -----------------------------------------------------------
  dataset <- reactive({
    if (!is.null(input$taskData)) {
      datapath <- input$taskData$datapath
      read.arff(datapath)
    }
  })

  observe({
    if (!is.null(dataset())) {
      attributes <- 0:length(dataset())
      names(attributes) <- c("Unlabeled dataset", paste0(1:length(dataset), ": ", names(dataset())))
      updateSelectInput(session, "taskCl", choices = attributes)
    }
  })

  task <- reactive({
    if (!is.null(dataset())) {
      cl = as.numeric(input$taskCl)
      if (cl == 0) cl = NULL

      ruta.makeUnsupervisedTask(
        id = input$taskData$name,
        data = dataset(),
        cl = cl
      )
    }
  })

  output$datasetId <- renderText({
    validate(
      need(!is.null(input$taskData), "No dataset loaded")
    )
    input$taskData$name
  })

  dataLength <- reactive({
    if (!is.null(task())) {
      length(task()$data) - ifelse(is.null(task()$cl), 0, 1)
    }
  })

  output$learnerFirst <- renderPrint({ dataLength() })
  output$learnerLast <- renderPrint({ dataLength() })

  ## Learner management --------------------------------------------------------
  PCA <- "pca"
  AUTOENCODER <- "autoencoder"
  RBM <- "rbm"

  learners <- list(PCA, AUTOENCODER)

  updateSelectInput(session, "learnerCl", choices = learners, selected = learners[[2]])

  ## Activation
  activations = c('none', 'relu', 'sigmoid', 'softrelu', 'tanh')
  updateSelectInput(session, "learnerAct", choices = activations, selected = activations[[1]])

  learner = reactive({
    if (!is.null(dataLength())) {
      act = input$learnerAct
      if (act == 'none') act = NULL
      ruta.makeLearner("autoencoder", hidden = c(dataLength(), 2, dataLength()), activation = act)
    }
  })

  ## Training

  model = reactive({
    if (!is.null(learner()) && !is.null(task())) {
      values[["log"]] <- capture.output({
        md <- train(learner(), task(), epochs = as.numeric(input$learnerRounds))
      })

      md
    }
  })

  ## Plots ---------------------------------------------------------------------
  output$bigPlot <- renderPlot({
    validate(
      need(!is.null(task()), "Please select a dataset")
    )
    validate(
      need(!is.null(model()), "Please configure a learner")
    )
    rutavis::plot.rutaModel(model(), task())
  }, width = 600, height = 600)

  ## Logs ----------------------------------------------------------------------
  output$console <- renderPrint({
    cat(paste(values[["log"]], collapse = "\n"))
  })
})
