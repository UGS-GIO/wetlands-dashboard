# Reactive helper functions for wetlands dashboard
# Simple utilities to reduce repetition while keeping code readable

#' Build a legend title from data columns
#' Extracts the label and units to create "Label (units)" format
#' @param data Data frame with label/units or definition/units columns
#' @param label_col Name of the label column ("label" or "definition")
build_legend_title <- function(data, label_col = "label") {
  paste0(unique(data[[label_col]])[1], ' (', unique(data$units)[1], ')')
}
