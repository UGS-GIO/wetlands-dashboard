# Data fetching functions for wetlands dashboard
# Handles API calls with CSV fallback

# API Configuration
API_BASE_URL <- "https://postgrest-seamlessgeolmap-734948684426.us-central1.run.app"
API_SCHEMA <- "wetlands"

# Cache environment for storing API responses
api_cache <- new.env()

#' Fetch data from PostgREST API with fallback to CSV
#' @param table_name Name of the table (without wetdash_ prefix)
#' @param csv_filename Optional custom CSV filename
#' @return Data frame with the requested data
fetch_data <- function(table_name, csv_filename = NULL) {

  # Check cache first
  cache_key <- paste0("wetdash_", table_name)
  if (exists(cache_key, envir = api_cache)) {
    return(get(cache_key, envir = api_cache))
  }

  # Try API first
  tryCatch({
    url <- paste0(API_BASE_URL, "/wetdash_", table_name)

    response <- httr::GET(
      url,
      httr::add_headers("Accept-Profile" = API_SCHEMA),
      httr::timeout(30)
    )

    status <- httr::status_code(response)

    if (status == 200) {
      data <- jsonlite::fromJSON(
        httr::content(response, "text", encoding = "UTF-8")
      )

      # Convert to data frame if it's a list
      if (is.list(data) && !is.data.frame(data)) {
        data <- as.data.frame(data)
      }

      # Store source info for status display
      attr(data, "data_source") <- "API"

      # Cache the result
      assign(cache_key, data, envir = api_cache)
      return(data)

    } else if (status == 401) {
      stop("API Unauthorized")
    } else {
      stop("API request failed with status: ", status)
    }

  }, error = function(e) {
    # Fallback to CSV
    csv_file <- if (is.null(csv_filename)) {
      paste0(table_name, ".csv")
    } else {
      csv_filename
    }

    if (file.exists(csv_file)) {
      data <- read.csv(csv_file)
      attr(data, "data_source") <- "CSV"
      assign(cache_key, data, envir = api_cache)
      return(data)
    } else {
      stop("Both API and CSV fallback failed for ", table_name, ": ", e$message)
    }
  })
}

#' Clear the data cache
clear_cache <- function() {
  rm(list = ls(envir = api_cache), envir = api_cache)
}

#' Load all wetlands data tables
#' @return Named list of all data tables
load_all_data <- function() {
  list(
    site_attr = fetch_data("site_attr"),
    flags = fetch_data("flags"),
    inverts = fetch_data("inverts"),
    invert_taxon = fetch_data("invert_param"),
    soil = fetch_data("soil"),
    soil_param = fetch_data("soil_param"),
    water = fetch_data("water"),
    water_param = fetch_data("water_param")
  )
}
