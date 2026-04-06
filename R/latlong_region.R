#' Filter rows by geographic region
#'
#' @description
#' Retains only rows whose coordinates fall within one or more named
#' geographic regions. Supports countries, sovereign territories, broader
#' geographic regions, and named marine areas including seas, bays, gulfs,
#' straits, and ocean basins via Natural Earth data. Region terms are matched
#' case-insensitively across all available name fields in both land and marine
#' polygon layers.
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Column name of the latitude column, supplied either
#'   unquoted (\code{lat}) or quoted (\code{"lat"}). Must contain numeric
#'   decimal degree values.
#' @param longitude Column name of the longitude column, supplied either
#'   unquoted (\code{lon}) or quoted (\code{"lon"}). Must contain numeric
#'   decimal degree values.
#' @param region Character vector of region names to match. Partial and
#'   case-insensitive matching is supported across country names, sovereign
#'   states, administrative regions, subregions, continents, and named marine
#'   areas such as seas, gulfs, and straits. Multiple values are unioned
#'   before filtering (e.g. \code{c("Japan", "Sea of Japan")} retains rows
#'   in either area).
#' @param dataset Character. Natural Earth dataset scale to use.
#'   Default is \code{"auto"}.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in either
#'   coordinate column are dropped before filtering. Default is \code{FALSE}.
#'
#' @return
#' A data frame containing only rows whose coordinates fall within the union
#' of all matched region polygons, with the same columns as \code{data}.
#' Console messages report the matched country and geographic region names,
#' the number of rows retained, and the number excluded outside the specified
#' regions.
#'
#' @details
#' Two Natural Earth polygon layers are queried: country polygons covering
#' land territories, regions, subregions, and continents; and geographic
#' region polygons covering named marine and physical features. Each
#' \code{region} term is matched against all available name fields in both
#' layers, and all matched polygons are unioned into a single bounding
#' geometry before the spatial filter is applied.
#'
#' Shapefiles are downloaded via \code{rnaturalearth::ne_download} on first
#' use and cached locally — subsequent calls with the same dataset are fast.
#' Requires the \pkg{rnaturalearth} and \pkg{sf} packages; an informative
#' error is raised if either is not installed.
#'
#' Coordinate columns must be in decimal degrees. Use
#' \code{\link{latlong_convert}} to convert DMS or base-60 columns first.
#' Use \code{\link{latlong_limits}} to inspect the coordinate extent of the
#' data before choosing region terms, and \code{\link{latlong_filter}} to
#' remove invalid coordinates beforehand.
#'
#' An error is raised if no polygons match any of the supplied
#' \code{region} terms across either layer.
#'
#' @seealso
#' \code{\link{latlong_limits}} for inspecting coordinate extent before
#' choosing region terms,
#'
#' \code{\link{latlong_filter}} for removing invalid coordinates before
#' filtering,
#'
#' \code{\link{latlong_range}} for filtering to a user-defined bounding box
#' rather than a named region,
#'
#' \code{\link{latlong_split}} for separating a combined coordinate column
#' into distinct latitude and longitude columns before filtering as
#' \code{\link{latlong_range}} does not function with combined columns,
#'
#' \code{\link{latlong_convert}} for converting DMS or base-60 columns to
#' decimal degrees before filtering.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c(35.6, 34.0, 51.5, 48.8),
#'   lon = c(139.7, 131.0, -0.1, 2.3)
#' )
#'
#' # Filter to a single country
#' latlong_region(df, latitude = lat, longitude = lon,
#'                region = "Japan")
#'
#' # Filter to multiple regions — land and marine areas unioned
#' latlong_region(df, latitude = lat, longitude = lon,
#'                region = c("Japan", "Sea of Japan", "East China Sea"))
#'
#' # Filter to a continent
#' latlong_region(df, latitude = lat, longitude = lon,
#'                region = "Europe")
#'
#' # Drop NA rows before filtering
#' latlong_region(df, latitude = lat, longitude = lon,
#'                region = "Japan", drop_na = TRUE)
#' }
#'
#' @export






latlong_region <- function(data, latitude, longitude, region, dataset = "auto",
                           drop_na = FALSE) {
  
  lat_col <- gsub('^"|"$', '', deparse(substitute(latitude)))
  lon_col <- gsub('^"|"$', '', deparse(substitute(longitude)))
  
  if (!lat_col %in% names(data))
    stop(paste0("[latlong_region] latitude column not found -> ",  lat_col))
  if (!lon_col %in% names(data))
    stop(paste0("[latlong_region] longitude column not found -> ", lon_col))
  
  if (!requireNamespace("rnaturalearth", quietly = TRUE))
    stop("Package 'rnaturalearth' is required. Install with: install.packages('rnaturalearth')")
  if (!requireNamespace("sf", quietly = TRUE))
    stop("Package 'sf' is required. Install with: install.packages('sf')")
  
  # --- Optional NA removal ---
  na_removed <- 0
  if (drop_na) {
    keep       <- !is.na(data[[lat_col]]) & !is.na(data[[lon_col]])
    na_removed <- sum(!keep)
    data       <- data[keep, , drop = FALSE]
    message(sprintf("[latlong_region] %d NA row(s) removed", na_removed))
  }
  
  # --- Load polygon layers ---
  # Layer 1: countries — land territories, regions, continents
  countries_sf <- tryCatch(
    rnaturalearth::ne_countries(scale = "medium", returnclass = "sf"),
    error = function(e) NULL
  )
  
  # Layer 2: geographic regions — named seas, bays, gulfs, straits, ocean basins
  geo_regions_sf <- tryCatch(
    rnaturalearth::ne_download(scale = "medium",
                               type     = "geography_regions_polys",
                               category = "physical",
                               returnclass = "sf", load = TRUE),
    error = function(e) NULL
  )
  
  # --- Match region terms against all available layers ---
  matched_sf_list <- list()
  
  # Countries
  if (!is.null(countries_sf)) {
    search_fields <- c("name", "name_long", "sovereignt", "admin",
                       "subregion", "region_wb", "region_un", "continent")
    search_fields <- search_fields[search_fields %in% names(countries_sf)]
    country_rows  <- unique(unlist(lapply(region, function(r)
      unique(unlist(lapply(search_fields, function(field)
        which(grepl(r, countries_sf[[field]], ignore.case = TRUE))
      )))
    )))
    if (length(country_rows) > 0) {
      matched_countries <- countries_sf[country_rows, ]
      matched_sf_list[["countries"]] <- sf::st_geometry(matched_countries)
      message(sprintf("[latlong_region] countries/territories matched: %s",
                      paste(unique(matched_countries$name_long), collapse = ", ")))
    }
  }
  
  # Geographic regions — seas, bays, gulfs, straits, ocean basins
  if (!is.null(geo_regions_sf)) {
    geo_fields <- c("name", "name_alt", "featurecla", "scalerank")
    geo_fields <- geo_fields[geo_fields %in% names(geo_regions_sf)]
    geo_rows   <- unique(unlist(lapply(region, function(r)
      unique(unlist(lapply(geo_fields, function(field)
        which(grepl(r, geo_regions_sf[[field]], ignore.case = TRUE))
      )))
    )))
    if (length(geo_rows) > 0) {
      matched_geo <- geo_regions_sf[geo_rows, ]
      matched_sf_list[["geo_regions"]] <- sf::st_geometry(matched_geo)
      message(sprintf("[latlong_region] geographic regions matched: %s",
                      paste(unique(matched_geo$name), collapse = ", ")))
    }
  }
  
  if (length(matched_sf_list) == 0)
    stop(paste0("[latlong_region] no matching regions found -> ",
                paste(region, collapse = ", ")))
  
  # --- Combine all matched polygons ---
  all_geoms <- do.call(c, matched_sf_list)
  region_sf <- sf::st_as_sf(sf::st_union(all_geoms))
  
  # --- Convert points to sf ---
  points_sf <- sf::st_as_sf(
    dplyr::filter(data, !is.na(.data[[lat_col]]) & !is.na(.data[[lon_col]])),
    coords = c(lon_col, lat_col),
    crs    = 4326,
    remove = FALSE
  )
  
  # Ensure CRS matches
  points_sf <- sf::st_transform(points_sf, sf::st_crs(region_sf))
  
  # --- Spatial filter ---
  inside_idx  <- sf::st_within(points_sf, region_sf, sparse = FALSE)
  inside_rows <- apply(inside_idx, 1, any)
  result      <- data[inside_rows, , drop = FALSE]
  
  message(sprintf("[latlong_region] %d row(s) retained, %d row(s) excluded outside region(s)",
                  nrow(result), nrow(data) - nrow(result)))
  
  result
}