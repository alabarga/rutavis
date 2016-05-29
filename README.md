# dlvis

An R package for visualization of unsupervised deep learning techniques.

## Introduction

dlvis is aimed to ease the understanding of several behaviors in unsupervised deep learning methods via visualizations and representations. In its current state, it's capable of representing two and three-dimensional models built by autoencoders with a range of adjustable parameters, and compare these to a classic dimensionality reduction method, PCA.

## Installation

You can use [@hadley](https://github.com/hadley)'s [devtools](https://cran.r-project.org/web/packages/devtools/index.html) to install dlvis:

~~~r
devtools::install_github("fdavidcl/dlvis")
~~~

Afterwards, you can install the [h2o package](https://cran.r-project.org/web/packages/h2o/index.html) via `install.packages("h2o")`, which will be needed for autoencoder support.

## Usage

This package provides a web UI built using the [shiny package](https://cran.r-project.org/web/packages/shiny/). You can launch it via `dlvis::start_gui()`.

Alternatively, you can use the bundled functions `dlvis::new_model()` and `dlvis::plot.dlvis()` to generate your visualizations. Here is an example:

~~~r
library(dlvis)
iris_model <- new_model(type = "autoencoder",
                        dataset = iris,
                        class_col = 5,
                        layer = c(5, 2, 5),
                        activation = "TanhWithDropout",
                        epochs = 100)
plot(iris_model)
~~~
