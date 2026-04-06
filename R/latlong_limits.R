#' Report coordinate limits of a data frame
#'
#' @description
#' Identifies and reports the minimum and maximum latitude and longitude
#' values in a data frame. Accepts separate latitude and longitude columns,
#' a combined coordinate column, or auto-detects coordinate columns using
#' \code{\link{latlong_column}} when no columns are specified. Prints a
#' summary message and returns the data frame unchanged, making it safe to
#' use mid-pipeline. 
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Optional. Column name of the latitude column, supplied
#'   either unquoted (\code{lat}) or quoted (\code{"lat"}).
#' @param longitude Optional. Column name of the longitude column, supplied
#'   either unquoted (\code{lon}) or quoted (\code{"lon"}).
#' @param column Optional. Column name of a combined coordinate column
#'   containing latitude and longitude as a single delimited string
#'   (e.g. \code{"51.5,-0.1"}), supplied either unquoted (\code{coords})
#'   or quoted (\code{"coords"}). Supports \code{","}, \code{";"}, and
#'   whitespace as delimiters.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} coordinate
#'   values are excluded from the limit calculation. Default is \code{FALSE}.
#'
#' @return
#' The original \code{data} frame, returned invisibly and unchanged. This
#' function is called for its side effect of printing latitude and longitude
#' range messages to the console, and is safe to use within a pipeline
#' (e.g. with \code{|>}) without altering the data.
#'
#' @details
#' When none of \code{latitude}, \code{longitude}, or \code{column} are
#' provided, coordinate columns are auto-detected via
#' \code{\link{latlong_column}}. The first detected latitude, longitude, and
#' combined column are used. An error is raised if no coordinate columns are
#' found.
#'
#' Values outside valid geographic ranges (\code{[-90, 90]} for latitude,
#' \code{[-180, 180]} for longitude) are silently excluded from the limit
#' calculation. Use \code{\link{latlong_filter}} to remove such rows from the
#' data frame explicitly.
#'
#' Combined columns are split on \code{","}, \code{";"}, or whitespace before
#' parsing. Only numeric (decimal degree) values are extracted from combined
#' columns; DMS and base-60 formats in combined columns are not parsed.
#' Use \code{\link{latlong_convert}} to convert to decimal degrees first if
#' needed.
#'
#' @seealso
#' \code{\link{latlong_column}} for detecting coordinate columns
#' automatically,
#'
#' \code{\link{latlong_filter}} for removing out-of-range coordinates,
#'
#' \code{\link{latlong_range}} for filtering rows to a user-defined bounding
#' box using the limits reported by this function,
#'
#' \code{\link{latlong_convert}} for converting DMS or base-60 columns to
#' decimal before computing limits.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c(51.5, 48.8, -33.9, 40.7),
#'   lon = c(-0.1, 2.3, 151.2, -74.0)
#' )
#'
#' # Report limits from separate latitude and longitude columns
#' latlong_limits(df, latitude = lat, longitude = lon)
#'
#' # Auto-detect coordinate columns
#' latlong_limits(df)
#'
#' # Report limits from a combined coordinate column
#' df_combined <- data.frame(
#'   coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2", "40.7,-74.0")
#' )
#' latlong_limits(df_combined, column = coords)
#'
#' # Exclude NA values from the limit calculation
#' df_na <- data.frame(
#'   lat = c(51.5, NA, -33.9, 40.7),
#'   lon = c(-0.1, 2.3, 151.2, NA)
#' )
#' latlong_limits(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#'
#' # Safe to use mid-pipeline — data is returned unchanged
#' df |>
#'   latlong_limits(latitude = lat, longitude = lon) |>
#'   latlong_filter(latitude = lat, longitude = lon)
#'
#' @export



















latlong_limits <- function(data, latitude = NULL, longitude = NULL,
                           column = NULL, drop_na = FALSE) {
  # --- Resolve columns ---
  lat_col  <- if (!missing(latitude))  gsub('^"|"$', '', deparse(substitute(latitude)))  else NULL
  lon_col  <- if (!missing(longitude)) gsub('^"|"$', '', deparse(substitute(longitude))) else NULL
  comb_col <- if (!missing(column))    gsub('^"|"$', '', deparse(substitute(column)))    else NULL
  # Auto-detect if nothing specified
  if (is.null(lat_col) && is.null(lon_col) && is.null(comb_col)) {
    detected <- latlong_column(data)
    lat_col  <- if (length(detected$latitude)  > 0) names(detected$latitude)[1]  else NULL
    lon_col  <- if (length(detected$longitude) > 0) names(detected$longitude)[1] else NULL
    comb_col <- if (length(detected$combined)  > 0) names(detected$combined)[1]  else NULL
    if (is.null(lat_col) && is.null(lon_col) && is.null(comb_col))
      stop("[latlong_limits] no coordinate columns found \u2014 specify latitude, longitude, or column")
  }
  safe_numeric <- function(x) suppressWarnings(as.numeric(x))
  lat_vals <- lon_vals <- numeric(0)
  # --- Parse separate columns ---
  if (!is.null(lat_col) && lat_col %in% names(data)) {
    lat_vals <- safe_numeric(data[[lat_col]])
    if (drop_na) lat_vals <- lat_vals[!is.na(lat_vals)]
  }
  if (!is.null(lon_col) && lon_col %in% names(data)) {
    lon_vals <- safe_numeric(data[[lon_col]])
    if (drop_na) lon_vals <- lon_vals[!is.na(lon_vals)]
  }
  # --- Parse combined column ---
  if (!is.null(comb_col) && comb_col %in% names(data)) {
    raw <- as.character(data[[comb_col]])
    if (drop_na) raw <- raw[!is.na(raw)]
    # Handle common formats: "lat, lon" / "lat lon" / "lat; lon"
    # Also handles DMS formats by delegating to safe_numeric after splitting
    parsed <- lapply(raw, function(x) {
      if (is.na(x) || nchar(trimws(x)) == 0) return(c(NA_real_, NA_real_))
      parts <- trimws(strsplit(x, "[,;\\s]+")[[1]])
      parts <- parts[nchar(parts) > 0]
      if (length(parts) >= 2) {
        c(safe_numeric(parts[1]), safe_numeric(parts[2]))
      } else {
        c(NA_real_, NA_real_)
      }
    })
    comb_lat <- vapply(parsed, `[[`, numeric(1), 1)
    comb_lon <- vapply(parsed, `[[`, numeric(1), 2)
    lat_vals <- c(lat_vals, comb_lat)
    lon_vals <- c(lon_vals, comb_lon)
  }
  # --- Validate ranges ---
  lat_vals <- lat_vals[!is.na(lat_vals) & lat_vals >= -90  & lat_vals <= 90]
  lon_vals <- lon_vals[!is.na(lon_vals) & lon_vals >= -180 & lon_vals <= 180]
  if (length(lat_vals) == 0 && length(lon_vals) == 0)
    stop("[latlong_limits] no valid coordinate values found")
  # --- Compute and report limits ---
  if (length(lat_vals) > 0) {
    lat_min <- min(lat_vals, na.rm = TRUE)
    lat_max <- max(lat_vals, na.rm = TRUE)
    message(sprintf("[latlong_limits] latitude  \u2014 min: %s, max: %s",
                    format(lat_min, nsmall = 6), format(lat_max, nsmall = 6)))
  } else {
    message("[latlong_limits] latitude  \u2014 no valid values found")
  }
  if (length(lon_vals) > 0) {
    lon_min <- min(lon_vals, na.rm = TRUE)
    lon_max <- max(lon_vals, na.rm = TRUE)
    message(sprintf("[latlong_limits] longitude \u2014 min: %s, max: %s",
                    format(lon_min, nsmall = 6), format(lon_max, nsmall = 6)))
  } else {
    message("[latlong_limits] longitude \u2014 no valid values found")
  }
  invisible(data)
}
