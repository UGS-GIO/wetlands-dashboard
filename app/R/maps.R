# Map helper functions for wetlands dashboard
# Provides reusable functions for Leaflet map rendering

#' Create a base Leaflet map centered on Utah
#' @return A leaflet map object with CartoDB tiles
create_base_map <- function() {

  leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    setView(lng = -112.41, lat = 40.38, zoom = 7)
}

#' Update map markers using leafletProxy
#' @param map_id The leaflet output ID
#' @param data SF data frame with points and values
#' @param value_col Column name containing values (default: "value")
#' @param units_col Column name containing units (default: "units")
#' @param title Legend title
#' @param label_func Function to generate marker labels (receives data row)
#' @param legend_id Unique ID for the legend layer
update_map_markers <- function(map_id, data, title, legend_id,
                                label_func = NULL) {

  pal <- colorNumeric(
    palette = 'plasma',
    domain = data$value,
    reverse = TRUE
  )

  # Default label function
  if (is.null(label_func)) {
    labels <- paste0(data$value, ' ', data$units)
  } else {
    labels <- label_func(data)
  }

  proxy <- leafletProxy(map_id, data = data) %>%
    clearMarkers() %>%
    removeControl(legend_id) %>%
    addCircleMarkers(
      fillColor = ~pal(value),
      fillOpacity = 0.8,
      radius = 8,
      color = '#7f7f7f',
      stroke = TRUE,
      weight = 1,
      label = labels
    ) %>%
    addLegend(
      pal = pal,
      values = data$value,
      position = 'bottomright',
      opacity = 1,
      title = title,
      layerId = legend_id
    )

  # Fit bounds if valid
  bounds <- st_bbox(data)
  if (all(is.finite(bounds)) &&
      bounds["xmin"] < bounds["xmax"] &&
      bounds["ymin"] < bounds["ymax"]) {
    proxy <- fitBounds(
      proxy,
      lng1 = unname(bounds["xmin"]),
      lat1 = unname(bounds["ymin"]),
      lng2 = unname(bounds["xmax"]),
      lat2 = unname(bounds["ymax"]),
      options = list(padding = c(50, 50))
    )
  }

  proxy
}

#' Update water map with filtered/unfiltered distinction
#' Water map is special - has two legends for fill color and outline
#' @param map_id The leaflet output ID
#' @param data SF data frame with water chemistry data
#' @param title Legend title for values
update_water_map <- function(map_id, data, title) {

  # Weight based on filtered/unfiltered
  weight_vector <- ifelse(data$fraction == 'filtered', 3, 1)

  fill_pal <- colorNumeric(
    palette = 'plasma',
    domain = data$value,
    reverse = TRUE
  )

  outline_pal <- colorFactor(
    palette = c('black', 'gray50'),
    domain = c('filtered', 'unfiltered')
  )

  proxy <- leafletProxy(map_id, data = data) %>%
    clearMarkers() %>%
    clearControls() %>%
    addCircleMarkers(
      fillColor = ~fill_pal(value),
      fillOpacity = 0.8,
      color = ~outline_pal(fraction),
      radius = 8,
      stroke = TRUE,
      weight = weight_vector,
      label = ~paste0(value, ' ', units, ' (', fraction, ')')
    ) %>%
    addLegend(
      pal = fill_pal,
      values = data$value,
      position = 'bottomright',
      opacity = 1,
      title = title
    ) %>%
    addLegend(
      colors = c('black', '#7f7f7f'),
      opacity = 1,
      labels = c('Filtered', 'Unfiltered'),
      position = 'bottomright',
      title = 'Sample Type (Outline)'
    )

  # Fit bounds if valid
  bounds <- st_bbox(data)
  if (all(is.finite(bounds)) &&
      bounds["xmin"] < bounds["xmax"] &&
      bounds["ymin"] < bounds["ymax"]) {
    proxy <- fitBounds(
      proxy,
      lng1 = unname(bounds["xmin"]),
      lat1 = unname(bounds["ymin"]),
      lng2 = unname(bounds["xmax"]),
      lat2 = unname(bounds["ymax"]),
      options = list(padding = c(50, 50))
    )
  }

  proxy
}
