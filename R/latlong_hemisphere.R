#' Assign hemispheres to coordinates
#'
#' @description
#' Appends \code{NS_hemisphere} and \code{EW_hemisphere} columns to a data
#' frame based on the sign of coordinate values. Accepts either separate
#' latitude and longitude columns or a single combined coordinate column.
#' Supports decimal degree, DMS (\code{DD°MM′SS″}), and base-60
#' (\code{DD°MM′}) coordinate formats.
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Optional. Column name of the latitude column, supplied
#'   either unquoted (\code{lat}) or quoted (\code{"lat"}). Required if
#'   \code{combined_col} is not provided.
#' @param longitude Optional. Column name of the longitude column, supplied
#'   either unquoted (\code{lon}) or quoted (\code{"lon"}). Required if
#'   \code{combined_col} is not provided.
#' @param combined_col Optional. Column name of a combined coordinate column
#'   containing latitude and longitude as a single comma-delimited string
#'   (e.g. \code{"51.5,-0.1"}), supplied either unquoted (\code{coords})
#'   or quoted (\code{"coords"}). Required if \code{latitude} and
#'   \code{longitude} are not provided.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in either
#'   coordinate are dropped before hemisphere assignment. Default is
#'   \code{FALSE}.
#'
#' @return
#' The input data frame with two additional character columns appended:
#' \describe{
#'   \item{\code{NS_hemisphere}}{\code{"North"} if latitude is greater than or
#'     equal to zero, \code{"South"} if negative, \code{NA} if the coordinate
#'     could not be parsed.}
#'   \item{\code{EW_hemisphere}}{\code{"East"} if longitude is greater than or
#'     equal to zero, \code{"West"} if negative, \code{NA} if the coordinate
#'     could not be parsed.}
#' }
#' Rows removed by \code{drop_na = TRUE} are attached as
#' \code{attr(result, "removed_na")} for inspection.
#'
#' @details
#' All coordinate formats are parsed to decimal degrees internally before
#' hemisphere assignment. The parser handles decimal, DMS, and base-60
#' formats, inferring sign from cardinal direction suffixes (\code{S},
#' \code{W}) or the sign of the degree value. Zero-width and BOM characters
#' are stripped before parsing.
#'
#' Either \code{combined_col} or both \code{latitude} and \code{longitude}
#' must be provided; supplying neither raises an error. When \code{drop_na =
#' FALSE} (the default), rows with unparseable or \code{NA} coordinates are
#' retained with \code{NA} in the hemisphere columns.
#'
#' The combined column separator is assumed to be \code{","}. Use
#' \code{\link{latlong_split}} to separate a combined column with a different
#' delimiter before calling this function.
#'
#' Use \code{\link{latlong_filter}} to remove out-of-range coordinates before
#' assigning hemispheres, and \code{\link{latlong_format}} to verify
#' coordinate formats in advance.
#'
#' @seealso
#' \code{\link{latlong_filter}} for removing invalid coordinates before
#' hemisphere assignment,
#'
#' \code{\link{latlong_format}} for checking coordinate formats,
#'
#' \code{\link{latlong_column}} for detecting coordinate columns in a data
#' frame,
#'
#' \code{\link{latlong_convert}} for converting DMS or base-60 columns to
#' decimal degrees before hemisphere assignment.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c(51.5, -33.9, 48.8, -23.5),
#'   lon = c(-0.1, 151.2, 2.3, -46.6)
#' )
#'
#' # Assign hemispheres from separate latitude and longitude columns
#' latlong_hemisphere(df, latitude = lat, longitude = lon)
#'
#' # Assign hemispheres from a combined coordinate column
#' df_combined <- data.frame(
#'   id     = 1:4,
#'   coords = c("51.5,-0.1", "-33.9,151.2", "48.8,2.3", "-23.5,-46.6")
#' )
#' latlong_hemisphere(df_combined, combined_col = coords)
#'
#' # Drop rows where either coordinate is NA
#' df_na <- data.frame(
#'   lat = c(51.5, NA, -33.9),
#'   lon = c(-0.1, 2.3, NA)
#' )
#' latlong_hemisphere(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#'
#' # Inspect rows removed by drop_na
#' result <- latlong_hemisphere(df_na, latitude = lat, longitude = lon,
#'                              drop_na = TRUE)
#' attr(result, "removed_na")
#'
#' @export
















latlong_hemisphere <- function(data,
                               latitude     = NULL,
                               longitude    = NULL,
                               combined_col = NULL,
                               drop_na      = FALSE) {
  
  # Resolve column names — bare names or quoted strings
  latitude     <- if (!is.null(substitute(latitude)))
    gsub('^"|"$', '', deparse(substitute(latitude)))     else NULL
  longitude    <- if (!is.null(substitute(longitude)))
    gsub('^"|"$', '', deparse(substitute(longitude)))    else NULL
  combined_col <- if (!is.null(substitute(combined_col)))
    gsub('^"|"$', '', deparse(substitute(combined_col))) else NULL
  
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
  
  # --- Extract and parse coordinates ---
  if (!is.null(combined_col)) {
    if (!combined_col %in% names(data))
      stop(paste0("[latlong_hemisphere] combined column not found -> ", combined_col))
    parts    <- strsplit(as.character(data[[combined_col]]), ",", fixed = TRUE)
    lat_vals <- vapply(parts, function(x)
      parse_to_decimal(if (length(x) >= 1) trimws(x[1]) else NA_character_), numeric(1))
    lon_vals <- vapply(parts, function(x)
      parse_to_decimal(if (length(x) >= 2) trimws(x[2]) else NA_character_), numeric(1))
  } else {
    if (!latitude  %in% names(data))
      stop(paste0("[latlong_hemisphere] latitude column not found -> ",  latitude))
    if (!longitude %in% names(data))
      stop(paste0("[latlong_hemisphere] longitude column not found -> ", longitude))
    lat_vals <- vapply(as.character(data[[latitude]]),  parse_to_decimal, numeric(1))
    lon_vals <- vapply(as.character(data[[longitude]]), parse_to_decimal, numeric(1))
  }
  
  # --- NA handling ---
  na_idx  <- is.na(lat_vals) | is.na(lon_vals)
  removed <- data[na_idx, , drop = FALSE]
  
  if (drop_na) {
    data     <- data[!na_idx, , drop = FALSE]
    lat_vals <- lat_vals[!na_idx]
    lon_vals <- lon_vals[!na_idx]
    message(sprintf("[latlong_hemisphere] %d NA row(s) removed", nrow(removed)))
  }
  
  # --- Assign hemispheres ---
  data[["NS_hemisphere"]] <- ifelse(is.na(lat_vals), NA_character_,
                                    ifelse(lat_vals >= 0, "North", "South"))
  data[["EW_hemisphere"]] <- ifelse(is.na(lon_vals), NA_character_,
                                    ifelse(lon_vals >= 0, "East",  "West"))
  
  attr(data, "removed_na") <- removed
  
  data
}
