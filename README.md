# [rutavis](http://fdavidcl.me/rutavis)

An R package for visualization of unsupervised deep learning techniques.

## Introduction

rutavis is aimed to ease the understanding of several behaviors in unsupervised deep learning methods via visualizations and representations. In its current state, it's capable of representing two and three-dimensional models built by autoencoders with a range of adjustable parameters, and compare these to a classic dimensionality reduction method, PCA.

## Installation

You can use [@hadley](https://github.com/hadley)'s [devtools](https://cran.r-project.org/web/packages/devtools/index.html) to install dlvis:

~~~r
devtools::install_github("fdavidcl/rutavis")
~~~


## Usage

This package provides a web UI built using the [shiny package](https://cran.r-project.org/web/packages/shiny/). You can launch it via `rutavis::ruta.gui()`.
