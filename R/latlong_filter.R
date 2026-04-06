#' Filter rows by real-world coordinate validity
#'
#' @description
#' Removes rows where coordinates fall outside valid geographic ranges
#' (\code{[-90, 90]} for latitude, \code{[-180, 180]} for longitude).
#' Accepts either separate latitude and longitude columns, or a single combined
#' coordinate column. Supports decimal degree, DMS (\code{DD°MM′SS″}), and
#' base-60 (\code{DD°MM′}) coordinate formats.
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Optional. Column name of the latitude column, supplied
#'   either unquoted (\code{lat}) or quoted (\code{"lat"}). Required if
#'   \code{combined_col} is not provided.
#' @param longitude Optional. Column name of the longitude column, supplied
#'   either unquoted (\code{lon}) or quoted (\code{"lon"}). Required if
#'   \code{combined_col} is not provided.
#' @param combined_col Optional. Column name of a combined coordinate column
#'   containing latitude and longitude as a single delimited string
#'   (e.g. \code{"51.5,-0.1"}), supplied either unquoted (\code{coords})
#'   or quoted (\code{"coords"}). Required if \code{latitude} and
#'   \code{longitude} are not provided.
#' @param sep Character. Separator used to split \code{combined_col} into
#'   latitude and longitude parts. Default is \code{","}.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in either
#'   coordinate are dropped in addition to out-of-range rows. Default is
#'   \code{FALSE}.
#'
#' @return
#' A data frame containing only rows with valid coordinates, with the same
#' columns as \code{data}. Removed rows are attached as
#' \code{attr(result, "invalid")} for inspection. A console message reports
#' the total number of rows removed.
#'
#' @details
#' All coordinate formats are parsed to decimal degrees internally before
#' range validation. The parser handles decimal, DMS, and base-60 formats,
#' inferring sign from cardinal direction suffixes (\code{S}, \code{W}) or
#' the sign of the degree value. Zero-width and BOM characters are stripped
#' before parsing.
#'
#' Either \code{combined_col} or both \code{latitude} and \code{longitude}
#' must be provided; supplying neither raises an error. When \code{drop_na =
#' FALSE} (the default), rows with \code{NA} coordinates are still removed
#' as they cannot pass range validation, and are captured in
#' \code{attr(result, "invalid")}.
#'
#' Use \code{\link{latlong_format}} to check coordinate formats before
#' filtering, and \code{\link{latlong_column}} to identify coordinate columns
#' if their names are not known in advance.
#'
#' @seealso
#' \code{\link{latlong_format}} for checking coordinate formats before
#' filtering,
#'
#' \code{\link{latlong_column}} for detecting coordinate columns in a data
#' frame,
#'
#' \code{\link{latlong_convert}} for converting DMS or base-60 columns to
#' decimal degrees before filtering,
#'
#' \code{\link{latlong_range}} for filtering rows to a user-defined bounding
#' box,
#'
#' \code{\link{latlong_region}} for filtering rows to named geographic regions.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:5,
#'   lat = c(51.5, 48.8, 91.0, -33.9, NA),
#'   lon = c(-0.1, 2.3, 139.7, 151.2, 37.6)
#' )
#'
#' # Filter using separate latitude and longitude columns
#' latlong_filter(df, latitude = lat, longitude = lon)
#'
#' # Inspect rows that were removed
#' result <- latlong_filter(df, latitude = lat, longitude = lon)
#' attr(result, "invalid")
#'
#' # Also drop rows where either coordinate is NA
#' latlong_filter(df, latitude = lat, longitude = lon, drop_na = TRUE)
#'
#' # Filter using a combined coordinate column
#' df_combined <- data.frame(
#'   id     = 1:4,
#'   coords = c("51.5,-0.1", "91.0,2.3", "-33.9,151.2", "48.8,181.0")
#' )
#' latlong_filter(df_combined, combined_col = coords)
#'
#' # Combined column with a custom separator
#' df_sep <- data.frame(
#'   coords = c("51.5;-0.1", "91.0;2.3", "-33.9;151.2")
#' )
#' latlong_filter(df_sep, combined_col = coords, sep = ";")
#'
#' @export
















latlong_filter <- function(data,
                           latitude     = NULL,
                           longitude    = NULL,
                           combined_col = NULL,
                           sep          = ",",
                           drop_na      = FALSE) {
  
  # Resolve column names — bare names or quoted strings
  latitude     <- if (!is.null(substitute(latitude)))
    gsub('^"|"$', '', deparse(substitute(latitude)))     else NULL
  longitude    <- if (!is.null(substitute(longitude)))
    gsub('^"|"$', '', deparse(substitute(longitude)))    else NULL
  combined_col <- if (!is.null(substitute(combined_col)))
    gsub('^"|"$', '', deparse(substitute(combined_col))) else NULL
  
  # Guard against "NULL" string from substituting default NULL
  if (identical(latitude,     "NULL")) latitude     <- NULL
  if (identical(longitude,    "NULL")) longitude    <- NULL
  if (identical(combined_col, "NULL")) combined_col <- NULL
  
  if (is.null(combined_col) && (is.null(latitude) || is.null(longitude)))
    stop("Provide either 'combined_col' or both 'latitude' and 'longitude'.")
  
  # --- Internal decimal parser ---
  parse_to_decimal <- function(val) {
    if (is.na(val)) return(NA_real_)
    val  <- trimws(gsub("[\u200B-\u200D\uFEFF]", "", enc2utf8(as.character(val))))
    nums <- as.numeric(unlist(regmatches(val, gregexpr("-?\\d+\\.?\\d*", val))))
    if (length(nums) == 0) return(NA_real_)
    deg <- nums[1]
    min <- ifelse(length(nums) >= 2, nums[2], 0)
    sec <- ifelse(length(nums) >= 3, nums[3], 0)
    dec <- abs(deg) + min / 60 + sec / 3600
    if      (grepl("[Ss]|[Ww]", val)) dec <- -abs(dec)
    else if (grepl("[Nn]|[Ee]", val)) dec <-  abs(dec)
    else if (deg < 0)                 dec <- -abs(dec)
    dec
  }
  
  # --- Extract raw coordinate values ---
  if (!is.null(combined_col)) {
    parts   <- strsplit(as.character(data[[combined_col]]), sep, fixed = TRUE)
    lat_raw <- vapply(parts, function(x) if (length(x) >= 1) trimws(x[1]) else NA_character_, character(1))
    lon_raw <- vapply(parts, function(x) if (length(x) >= 2) trimws(x[2]) else NA_character_, character(1))
  } else {
    lat_raw <- as.character(data[[latitude]])
    lon_raw <- as.character(data[[longitude]])
  }
  
  lat <- vapply(lat_raw, parse_to_decimal, numeric(1))
  lon <- vapply(lon_raw, parse_to_decimal, numeric(1))
  
  # --- NA handling ---
  valid_na <- if (drop_na) !is.na(lat) & !is.na(lon) else rep(TRUE, length(lat))
  
  # --- Range validation ---
  valid_range <- !is.na(lat) & !is.na(lon) &
    lat >= -90  & lat <= 90   &
    lon >= -180 & lon <= 180
  
  keep    <- valid_na & valid_range
  removed <- data[!keep, , drop = FALSE]
  result  <- data[keep,  , drop = FALSE]
  
  attr(result, "invalid") <- removed
  
  message(sprintf("[latlong_filter] %d row(s) removed with invalid or out-of-range coordinates",
                  nrow(removed)))
  
  result
}

