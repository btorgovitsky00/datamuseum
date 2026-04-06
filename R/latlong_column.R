#' Identify coordinate columns in a data frame
#'
#' @description
#' Detects latitude, longitude, and combined coordinate columns based on
#' value ranges and format matching. Supports decimal degree, DMS
#' (\code{DD°MM′SS″}), and base-60 (\code{DD°MM′}) coordinate formats.
#' Returns a named list with elements \code{combined}, \code{latitude}, and
#' \code{longitude}, each containing the names and indices of detected columns.
#'
#' @param data A data frame to search for coordinate columns.
#' @param sep Character. Separator used to split combined coordinate columns
#'   (i.e. columns containing both latitude and longitude as a single string).
#'   Default is \code{","}.
#'
#' @return
#' A named list with three elements:
#' \describe{
#'   \item{\code{combined}}{Columns containing both latitude and longitude as
#'     a single delimited string (e.g. \code{"51.5,-0.1"}).}
#'   \item{\code{latitude}}{Columns containing latitude values only. Numeric
#'     range is constrained to \code{[-90, 90]}.}
#'   \item{\code{longitude}}{Columns containing longitude values only. Numeric
#'     range is constrained to \code{[-180, 180]}. Columns already assigned to
#'     \code{combined} or \code{latitude} are excluded.}
#' }
#' Each element is a named list mapping column name to column index in
#' \code{data}. An empty named list (\code{list()}) is returned for any
#' coordinate type not detected.
#'
#' @details
#' Detection follows this priority order: combined columns are identified
#' first, then latitude, then longitude. A column can only appear in one
#' category — latitude candidates are excluded from longitude, and combined
#' candidates are excluded from both.
#'
#' The three recognised coordinate formats are:
#' \itemize{
#'   \item Decimal degrees: \code{"-12.345"} or \code{"51.5"}
#'   \item DMS: \code{"12°34′56″N"}
#'   \item Base-60: \code{"12°34′N"}
#' }
#'
#' Detection is based on value content, not column names, so columns with
#' non-standard names (e.g. \code{"point_y"}) will still be detected provided
#' their values match a recognized coordinate format and pass the range check.
#' At least one valid coordinate value is required for a column to be
#' detected.
#'
#' @seealso
#' \code{\link{latlong_format}} for checking the coordinate format of detected
#' columns,
#'
#' \code{\link{latlong_filter}} for removing invalid coordinates from detected
#' columns.
#' 
#' \code{\link[sf]{st_as_sf}} for converting detected coordinate columns to
#' an \code{sf} spatial object,
#' 
#' \code{\link[tidygeocoder]{geocode}} for adding coordinates to a data frame
#' from address strings.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:6,
#'   lat = c(51.5, 48.8, 40.7, 35.6, -33.9, 55.8),
#'   lon = c(-0.1, 2.3, -74.0, 139.7, 151.2, 37.6)
#' )
#'
#' # Detect separate latitude and longitude columns
#' latlong_column(df)
#'
#' # Access detected column names and indices
#' result <- latlong_column(df)
#' result$latitude
#' result$longitude
#'
#' # Detect a combined coordinate column
#' df2 <- data.frame(
#'   id     = 1:6,
#'   coords = c("51.5,-0.1", "48.8,2.3", "40.7,-74.0",
#'              "35.6,139.7", "-33.9,151.2", "55.8,37.6")
#' )
#' latlong_column(df2)
#'
#' # Use a custom separator for combined columns
#' df3 <- data.frame(
#'   coords = c("51.5;-0.1", "48.8;2.3", "40.7;-74.0",
#'              "35.6;139.7", "-33.9;151.2", "55.8;37.6")
#' )
#' latlong_column(df3, sep = ";")
#'
#' @export



latlong_column <- function(data, sep = ",") {
  
  cols <- names(data)
  
  sample_vals <- function(x) {
    x <- as.character(x[!is.na(x)])
    x
  }
  
  decimal <- "^\\s*-?\\d+(\\.\\d+)?\\s*$"
  dms     <- "^\\s*\\d+\u00b0\\d+\u2032\\d+\u2033[NnSsEeWw]?\\s*$"
  base60  <- "^\\s*\\d+\u00b0\\d+\u2032[NnSsEeWw]?\\s*$"
  
  is_coord <- function(x) grepl(decimal, x) | grepl(dms, x) | grepl(base60, x)
  
  extract_nums <- function(x) {
    nums <- suppressWarnings(as.numeric(sub(".*?(-?\\d+\\.?\\d*).*", "\\1", x)))
    nums[!is.na(nums)]
  }
  
  is_combined <- function(x) {
    vals <- sample_vals(x)
    if (length(vals) == 0) return(FALSE)
    parts       <- lapply(strsplit(vals, sep, fixed = TRUE), trimws)
    valid_pairs <- sapply(parts, function(p)
      length(p) == 2 && all(is_coord(p))
    )
    sum(valid_pairs) >= 1
  }
  
  is_coord_col <- function(x, min_val, max_val) {
    vals  <- sample_vals(x)
    if (length(vals) == 0) return(FALSE)
    valid <- is_coord(vals)
    if (sum(valid) < 1) return(FALSE)
    nums  <- extract_nums(vals[valid])
    if (length(nums) == 0) return(FALSE)
    all(nums >= min_val & nums <= max_val)
  }
  
  combined_candidates <- cols[vapply(data, is_combined, logical(1))]
  
  lat_candidates <- setdiff(
    cols[vapply(data, is_coord_col, logical(1), min_val = -90,  max_val = 90)],
    combined_candidates
  )
  
  lon_candidates <- setdiff(
    cols[vapply(data, is_coord_col, logical(1), min_val = -180, max_val = 180)],
    c(combined_candidates, lat_candidates)
  )
  
  make_index_list <- function(candidates)
    setNames(as.list(which(cols %in% candidates)), candidates)
  
  list(
    combined  = make_index_list(combined_candidates),
    latitude  = make_index_list(lat_candidates),
    longitude = make_index_list(lon_candidates)
  )
}
