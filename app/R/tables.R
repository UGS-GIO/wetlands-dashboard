# Table helper functions for wetlands dashboard
# Provides reusable functions for summary tables and downloads

#' Create a summary statistics table
#' @param data Data frame with value, subpop, and parameter columns (can be sf)
#' @param param_df Optional parameter data frame to get units from
#' @param label_col Column containing label (default: "label", use "definition" for inverts)
#' @return A DT datatable object
create_summary_table <- function(data, param_df = NULL, label_col = "label") {

  # Drop geometry if sf object
  if (inherits(data, "sf")) {
    data <- sf::st_drop_geometry(data)
  }

  table_df <- data %>%
    dplyr::group_by(subpop) %>%
    dplyr::summarise(
      `Sample Size` = dplyr::n(),
      Minimum = min(value, na.rm = TRUE),
      Median = median(value, na.rm = TRUE),
      Mean = mean(value, na.rm = TRUE),
      Maximum = max(value, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    dplyr::mutate(
      dplyr::across(dplyr::where(is.numeric), ~signif(., 2))
    ) %>%
    dplyr::rename(Group = subpop) %>%
    dplyr::select(Group, `Sample Size`, Minimum, Median, Mean, Maximum)

  # Add units to column headers if param_df provided
  if (!is.null(param_df) && "parameter" %in% names(data)) {
    param_info <- subset(param_df, param_df$parameter == unique(data$parameter))
    units <- paste0("(", param_info$units[1], ")")
    colnames(table_df) <- c("Group", "Sample Size",
                            paste("Min", units),
                            paste("Median", units),
                            paste("Mean", units),
                            paste("Max", units))
  }

  DT::datatable(
    table_df,
    rownames = FALSE,
    class = 'compact dark-theme',
    fillContainer = FALSE,
    options = list(
      dom = 't',
      ordering = FALSE,
      paging = FALSE,
      searching = FALSE,
      info = FALSE,
      columnDefs = list(
        list(className = 'dt-center', targets = '_all')
      )
    )
  )
}

#' Create download handler for data export
#' @param data_reactive Reactive expression returning the data to download
#' @param filename_prefix Prefix for the downloaded file
#' @return A downloadHandler
create_download_handler <- function(data_reactive, filename_prefix) {

  downloadHandler(
    filename = function() {
      paste0(filename_prefix, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- data_reactive()
      # Drop geometry if sf object
      if (inherits(data, "sf")) {
        data <- sf::st_drop_geometry(data)
      }
      write.csv(data, file, row.names = FALSE)
    }
  )
}
