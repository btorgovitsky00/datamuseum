#' Split a combined coordinate column into separate columns
#'
#' @description
#' Splits a single combined coordinate column into separate latitude and
#' longitude columns, appended to the data frame. The inverse of this
#' operation is \code{\link{latlong_combine}}. Useful as a prerequisite for
#' functions that require separate coordinate columns, such as
#' \code{\link{latlong_range}} and \code{\link{latlong_region}}.
#'
#' @param data A data frame containing a combined coordinate column.
#' @param combined_col Column name of the combined coordinate column
#'   containing latitude and longitude as a single delimited string
#'   (e.g. \code{"51.5,-0.1"}), supplied either unquoted (\code{coords})
#'   or quoted (\code{"coords"}).
#' @param latitude Column name for the new latitude column to be appended,
#'   supplied either unquoted (\code{lat}) or quoted (\code{"lat"}).
#' @param longitude Column name for the new longitude column to be appended,
#'   supplied either unquoted (\code{lon}) or quoted (\code{"lon"}).
#' @param sep Character. Separator between latitude and longitude values in
#'   \code{combined_col}. Default is \code{","}. Must match the separator
#'   used when the combined column was created.
#' @param drop_na Logical. If \code{TRUE}, rows where splitting produces
#'   \code{NA} in either new column are dropped. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with two additional character columns appended, named
#' according to \code{latitude} and \code{longitude}. The original
#' \code{combined_col} is retained. Values are returned as character strings;
#' use \code{as.numeric()} or \code{\link{latlong_convert}} if numeric decimal
#' degree values are required downstream. A console message reports the number
#' of rows removed when \code{drop_na = TRUE}.
#'
#' @details
#' Splitting is performed by \code{strsplit()} on \code{sep}, with leading
#' and trailing whitespace trimmed from each part. Rows where
#' \code{combined_col} contains fewer than two parts after splitting produce
#' \code{NA} in the longitude column. Input strings are converted to UTF-8
#' before splitting to handle encoded coordinate values.
#'
#' The new coordinate columns are character type regardless of input format.
#' Use \code{\link{latlong_format}} to verify the format of the split columns,
#' and \code{\link{latlong_convert}} to convert to a target format before
#' passing to other functions.
#'
#' @seealso
#' \code{\link{latlong_combine}} for merging separate coordinate columns into
#' a single combined column,
#'
#' \code{\link{latlong_format}} for checking the format of the split columns,
#'
#' \code{\link{latlong_convert}} for converting split columns to a target
#' coordinate format,
#'
#' \code{\link{latlong_range}} for filtering to a bounding box, which does
#' not accept combined columns,
#'
#' \code{\link{latlong_region}} for filtering to named geographic regions,
#' which does not accept combined columns.
#'
#' @examples
#' df <- data.frame(
#'   id     = 1:4,
#'   coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2", "40.7,-74.0")
#' )
#'
#' # Split into separate latitude and longitude columns
#' latlong_split(df, combined_col = coords, latitude = lat, longitude = lon)
#'
#' # Use a custom separator
#' df_sep <- data.frame(
#'   coords = c("51.5;-0.1", "48.8;2.3", "-33.9;151.2")
#' )
#' latlong_split(df_sep, combined_col = coords, latitude = lat,
#'               longitude = lon, sep = ";")
#'
#' # Drop rows where splitting produces NA
#' df_na <- data.frame(
#'   coords = c("51.5,-0.1", "48.8", NA, "40.7,-74.0")
#' )
#' latlong_split(df_na, combined_col = coords, latitude = lat,
#'               longitude = lon, drop_na = TRUE)
#'
#' # Split then filter by bounding box
#' df |>
#'   latlong_split(combined_col = coords, latitude = lat, longitude = lon) |>
#'   latlong_range(latitude = lat, longitude = lon,
#'                 lat_min = 0, lat_max = 60,
#'                 lon_min = -10, lon_max = 40)
#'
#' @export
















latlong_split <- function(data, combined_col, latitude, longitude,
                          sep = ",", drop_na = FALSE) {
  
  combined_col <- gsub('^"|"$', '', deparse(substitute(combined_col)))
  lat_col      <- gsub('^"|"$', '', deparse(substitute(latitude)))
  lon_col      <- gsub('^"|"$', '', deparse(substitute(longitude)))
  
  if (!combined_col %in% names(data))
    stop(paste0("[latlong_split] combined column not found -> ", combined_col))
  
  coords <- strsplit(enc2utf8(as.character(data[[combined_col]])), sep, fixed = TRUE)
  
  data[[lat_col]] <- vapply(coords, function(x)
    if (length(x) >= 1) trimws(x[1]) else NA_character_, character(1))
  data[[lon_col]] <- vapply(coords, function(x)
    if (length(x) >= 2) trimws(x[2]) else NA_character_, character(1))
  
  if (drop_na) {
    keep    <- stats::complete.cases(data[, c(lat_col, lon_col)])
    removed <- sum(!keep)
    data    <- data[keep, , drop = FALSE]
    message(sprintf("[latlong_split] %d NA row(s) removed", removed))
  }
  
  data
}
