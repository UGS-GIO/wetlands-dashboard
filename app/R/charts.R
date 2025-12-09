# Chart helper functions for wetlands dashboard
# Provides reusable functions for histograms and boxplots

#' Create a histogram with optional faceting and reference line
#' @param data Data frame with value and subpop columns
#' @param x_label X-axis label (typically "Parameter (units)")
#' @param caption Plot caption
#' @param subpop_var Name of the subpopulation variable for caption
#' @param facet_var Optional variable to facet by (e.g., "fraction" for water)
#' @param facet_labels Named vector for facet labels
#' @param vline_value Optional value for vertical reference line
#' @return ggplot object
create_histogram <- function(data, x_label, caption, subpop_var,
                              facet_var = NULL, facet_labels = NULL,
                              vline_value = NULL) {

  p <- ggplot(data, aes(x = value, fill = subpop)) +
    geom_histogram(bins = 10, color = 'gray80') +
    scale_fill_brewer(palette = 'PuOr', name = NULL) +
    scale_x_continuous(label = scales::comma) +
    labs(
      x = x_label,
      y = 'Frequency',
      caption = stringr::str_wrap(
        paste0('Distribution of ', caption, ' observations shaded by ', subpop_var),
        width = 50
      )
    ) +
    coord_flip() +
    theme_ugsdark() +
    theme(
      legend.position = 'inside',
      legend.position.inside = c(0.7, 0.8)
    )

  # Add vertical reference line if provided
  if (!is.null(vline_value) && !is.na(vline_value)) {
    p <- p + geom_vline(
      xintercept = vline_value,
      linetype = 'dashed',
      color = '#FFFFFF'
    )
  }

  # Add faceting if provided
  if (!is.null(facet_var)) {
    if (!is.null(facet_labels)) {
      p <- p + facet_wrap(
        as.formula(paste0("~", facet_var)),
        labeller = labeller(.cols = facet_labels)
      )
    } else {
      p <- p + facet_wrap(as.formula(paste0("~", facet_var)))
    }
  }

  p
}

#' Create a boxplot with jittered points
#' @param data Data frame with value and subpop columns
#' @param y_label Y-axis label (typically "Parameter (units)")
#' @param caption_param Parameter name for caption
#' @param subpop_var Name of the subpopulation variable for caption
#' @return ggplot object
create_boxplot <- function(data, y_label, caption_param, subpop_var) {

  ggplot(data, aes(x = subpop, y = value, fill = subpop)) +
    geom_boxplot(alpha = 0.9, color = '#d3d3d3') +
    geom_jitter(width = 0.1, alpha = 0.8, color = '#d3d3d3') +
    scale_fill_brewer(palette = 'PuOr') +
    guides(fill = 'none') +
    labs(
      x = '',
      y = y_label,
      caption = stringr::str_wrap(
        paste0('Boxplot (25-75th percentile) of ', caption_param,
               ' across ', subpop_var, 's'),
        width = 50
      )
    ) +
    scale_x_discrete(labels = function(x) sub('\\s', '\n', x)) +
    scale_y_continuous(label = scales::comma) +
    theme_ugsdark()
}

#' Get chart title from parameter info
#' @param param_df Parameter data frame (water_param, soil_param, etc.)
#' @param parameter The parameter code to look up
#' @param label_col Column containing label (default: "label", use "definition" for inverts)
#' @return String like "Parameter Name (units)"
get_chart_title <- function(param_df, parameter, label_col = "label") {

  info <- subset(param_df, param_df$parameter == parameter)
  paste0(info[[label_col]][1], ' (', info$units[1], ')')
}

#' Get chart caption (label without units)
#' @param param_df Parameter data frame
#' @param parameter The parameter code to look up
#' @param label_col Column containing label
#' @return String with just the parameter name
get_chart_caption <- function(param_df, parameter, label_col = "label") {

  info <- subset(param_df, param_df$parameter == parameter)
  info[[label_col]][1]
}
