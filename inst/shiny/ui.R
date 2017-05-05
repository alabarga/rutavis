## This is a dummy shiny page I use to extract dependencies (such as Plotly
## scripts and styles)
page <- basicPage(
  plotlyOutput("dummyPlot")
)

deps <- htmltools::findDependencies(page)

## We don't want the Bootstrap framework though
for (i in 1:length(deps))
  if (deps[[i]]$name == "bootstrap")
    deps[[i]] <- NULL

## Use our template file, adding the extracted dependencies
htmltools::attachDependencies(htmlTemplate("template.html"), deps)
