# ggplot2 dark theme for wetlands dashboard
# Used across all histogram, boxplot, and bar chart visualizations

theme_ugsdark <- function() {
  theme_minimal(
    base_family = 'Segoe UI'
  ) +
    theme(
      axis.text = element_text(
        size = 13,
        color = "#ffffff"
      ),
      axis.title = element_text(
        size = 14,
        color = '#ffffff'
      ),
      strip.text = element_text(
        size = 14,
        color = '#ffffff'
      ),
      panel.grid.minor = element_line(color = '#5E5E5E'),
      panel.grid.major = element_line(color = '#5E5E5E'),
      plot.background = element_rect(
        fill = '#282828',
        color = NA
      ),
      panel.background = element_rect(
        fill = '#282828',
        color = NA
      ),
      legend.background = element_rect(
        fill = '#282828',
        color = NA
      ),
      legend.text = element_text(
        color = '#ffffff',
        size = 11
      ),
      legend.title = element_text(
        color = '#ffffff',
        size = 11
      ),
      plot.caption = element_text(
        color = '#ffffff',
        hjust = 0.5,
        size = 12
      ),
      strip.background = element_rect(
        fill = '#1B1B1B',
        color = '#1B1B1B'
      )
    )
}
