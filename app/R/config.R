# Configuration and classification functions for wetlands dashboard
# Contains lookup tables and helper functions for categorizing data

# HUC6 watershed lookup: maps 6-digit HUC codes to watershed names
huc6_map <- list(
  `Upper Colorado-Dolores` = '140300',
  `Upper Green` = '140401',
  `White-Yampa` = '140500',
  `Lower Green` = '140600',
  `Upper Colorado-Dirty Devil` = '140700',
  `Lower San Juan` = '140802',
  `Lower Colorado-Lake Mead` = '150100',
  `Upper Bear` = '160101',
  `Lower Bear` = '160102',
  `Weber` = '160201',
  `Jordan` = '160202',
  `Great Salt Lake` = '160203',
  `Escalante Desert-Sevier Lake` = '160300',
  `Upper Snake` = '170402'
)

# Study/project to organization mapping
# Update these lists as new data sources are added
study_orgs <- list(
  `Utah Division of Water Quality` = c(
    "fr2020", "fr2013", "fr2015", "gslwet2017", "iw2012",
    "highfreq19", "iw2019", "ref2014", "ref2015", "spur2011"
  ),
  `Utah Geological Survey` = c("pm2022", "ugswet"),
  `Utah State University` = c("usuwet")
)

#' Classify HUC codes to watershed names
#' @param huc_codes Vector of HUC8 or HUC12 codes
#' @return Vector of watershed names
classify_huc <- function(huc_codes) {
  huc6 <- substr(as.character(huc_codes), 1, 6)

  lookup <- unlist(huc6_map)
  names(lookup) <- names(huc6_map)
  huc6_to_label <- setNames(names(lookup), lookup)

  sapply(huc6, function(code) {
    if (code %in% names(huc6_to_label)) {
      huc6_to_label[[code]]
    } else {
      "Other"
    }
  })
}

#' Classify Cowardin codes to Utah wetland types
#' @param codes Vector of Cowardin classification codes
#' @return Vector of wetland type names
classify_wetland <- function(codes) {
  sapply(codes, function(code) {
    if (grepl("AB", code)) {
      "Aquatic Bed"
    } else if (grepl("EM", code)) {
      "Marsh"
    } else if (grepl("SS", code) || grepl("FO", code)) {
      "Woody"
    } else if (grepl("UB", code) || grepl("US", code)) {
      "Playa/Mudflat"
    } else {
      "Other"
    }
  })
}

#' Classify project codes to organization names
#' @param projects Vector of project codes
#' @return Vector of organization names
classify_organization <- function(projects) {
  result <- projects
  for (org_name in names(study_orgs)) {
    result <- ifelse(result %in% study_orgs[[org_name]], org_name, result)
  }
  result
}

#' Prepare site attributes with derived columns
#' Adds Watershed, Wetland Type, and organization columns
#' Also removes equipment blank records
#' @param site_attr Raw site attributes data frame
#' @return Prepared site attributes data frame
prepare_site_attr <- function(site_attr) {
  # Add derived columns

site_attr$Watershed <- classify_huc(site_attr$huc8)
  site_attr$`Wetland Type` <- classify_wetland(site_attr$sysclass)
  site_attr$project <- classify_organization(site_attr$project)

  # Remove equipment blanks
  site_attr <- site_attr[!grepl("_blank_", site_attr$siteid), ]

  site_attr
}
