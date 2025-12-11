# Reactive helper functions for wetlands dashboard
# Simple utilities to reduce repetition while keeping code readable

#' Build a legend title from data columns
#' Extracts the label and units to create "Label (units)" format
#' @param data Data frame with label/units or definition/units columns
#' @param label_col Name of the label column ("label" or "definition")
build_legend_title <- function(data, label_col = "label") {
  paste0(unique(data[[label_col]])[1], ' (', unique(data$units)[1], ')')
}

#' Add spatial geometry to data
#' Joins site attributes and converts to SF object with jitter
#' @param data Data frame with siteid column
#' @param site_attr Site attributes data frame with lat/lon
#' @return SF data frame with geometry
add_spatial_geometry <- function(data, site_attr) {
  data %>%
    left_join(
      site_attr %>% select(siteid, latitude, longitude, ecoregion, Watershed, `Wetland Type`),
      by = 'siteid'
    ) %>%
    filter(!is.na(longitude) & !is.na(latitude)) %>%
    st_as_sf(coords = c('longitude', 'latitude'), crs = 4326) %>%
    st_jitter(amount = 0.001)
}
