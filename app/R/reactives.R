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

#' Render histogram plot with automatic label extraction
#' Wraps req(), data extraction, and histogram creation
render_histogram_plot <- function(subpop_reactive, subpop_var,
                                  facet_var = NULL, facet_labels = NULL,
                                  vline_col = "acute") {
  renderPlot({
    req(subpop_reactive())
    data <- subpop_reactive()

    vline_value <- if (vline_col %in% names(data)) unique(data[[vline_col]])[1] else NULL

    create_histogram(
      data = data,
      x_label = build_legend_title(data),
      caption = unique(data$label)[1],
      subpop_var = subpop_var,
      facet_var = facet_var,
      facet_labels = facet_labels,
      vline_value = vline_value
    )
  })
}

#' Render boxplot with automatic label extraction
#' Wraps req(), data extraction, and boxplot creation
render_boxplot <- function(subpop_reactive, subpop_var, hline_col = "acute") {
  renderPlot({
    req(subpop_reactive())
    data <- subpop_reactive()

    hline_value <- if (hline_col %in% names(data)) unique(data[[hline_col]])[1] else NULL

    create_boxplot(
      data = data,
      y_label = build_legend_title(data),
      caption_param = unique(data$label)[1],
      subpop_var = subpop_var,
      hline_value = hline_value
    )
  })
}

#' Calculate relative abundance by group for community plots
#' Standard pattern: join, group, summarize, pivot, calculate relative abundance
#' @param inverts_data Inverts data frame
#' @param lookup_data Data frame with taxon and grouping column
#' @param group_col Name of the grouping column
#' @param invert_metrics Data frame with total site abundance
#' @param parameter_name Name to assign to parameter column
calculate_relative_abundance <- function(inverts_data, lookup_data, group_col,
                                        invert_metrics, parameter_name) {
  inverts_data %>%
    left_join(lookup_data, by = 'taxon') %>%
    group_by(siteid, .data[[group_col]]) %>%
    summarise(abund = sum(abundance), .groups = 'drop') %>%
    pivot_wider(names_from = all_of(group_col), values_from = abund, values_fill = 0) %>%
    left_join(select(invert_metrics, siteid, abundance), by = 'siteid') %>%
    mutate(across(-c(siteid, abundance), ~ (.x / abundance) * 100)) %>%
    select(-abundance) %>%
    pivot_longer(cols = -siteid, names_to = 'group', values_to = 'rel_abnd') %>%
    mutate(parameter = parameter_name)
}
