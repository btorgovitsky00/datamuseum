#' Combine separate coordinate columns into one
#'
#' @description
#' Merges separate latitude and longitude columns into a single combined
#' coordinate column, appended to the data frame. The inverse of this
#' operation is \code{\link{latlong_split}}. Note that combined columns are
#' not accepted by the functions \code{\link{latlong_range}} and
#' \code{\link{latlong_region}}; use \code{\link{latlong_split}} to separate
#' columns again before filtering.
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Column name of the latitude column, supplied either
#'   unquoted (\code{lat}) or quoted (\code{"lat"}). Required if
#'   \code{combined_col} is not provided.
#' @param longitude Column name of the longitude column, supplied either
#'   unquoted (\code{lon}) or quoted (\code{"lon"}). Required if
#'   \code{combined_col} is not provided.
#' @param new_column Column name for the new combined column, supplied either
#'   unquoted (\code{latlong}) or quoted (\code{"latlong"}).
#'   Default is \code{latlong}.
#' @param sep Character. Separator inserted between latitude and longitude
#'   values in the combined column. Default is \code{", "}. Must match the
#'   \code{sep} argument of \code{\link{latlong_split}} if the combined column
#'   will be split again later.
#' @param drop_na Logical. If \code{TRUE}, rows where either the latitude or
#'   longitude column is \code{NA} are dropped before combining. Default is
#'   \code{FALSE}.
#'
#' @return
#' The input data frame with one additional character column appended, named
#' according to \code{new_column}, containing values of the form
#' \code{"<latitude><sep><longitude>"}. The original latitude and longitude
#' columns are retained. If \code{drop_na = FALSE}, rows with \code{NA} in
#' either coordinate column will produce \code{"NA<sep>NA"} or
#' \code{"<value><sep>NA"} in the combined column.
#'
#' @details
#' Both coordinate columns are coerced to character before concatenation via
#' \code{paste0()}, so numeric, integer, and character coordinate columns are
#' all accepted. No validation of coordinate ranges or formats is performed;
#' use \code{\link{latlong_format}} to check column formats before combining.
#'
#' A console message reports the number of rows removed when
#' \code{drop_na = TRUE}.
#'
#' @seealso
#' \code{\link{latlong_split}} for splitting a combined coordinate column back
#' into separate latitude and longitude columns,
#'
#' \code{\link{latlong_format}} for checking coordinate formats before
#' combining.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c(51.5, 48.8, 40.7, 35.6),
#'   lon = c(-0.1, 2.3, -74.0, 139.7)
#' )
#'
#' # Combine with default separator and column name
#' latlong_combine(df, latitude = lat, longitude = lon)
#'
#' # Use a custom separator and column name
#' latlong_combine(df, latitude = lat, longitude = lon,
#'                 new_column = coords, sep = ";")
#'
#' # Drop rows where either coordinate is NA
#' df_na <- data.frame(
#'   lat = c(51.5, NA, 40.7),
#'   lon = c(-0.1, 2.3, NA)
#' )
#' latlong_combine(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#'
#' @export
















latlong_combine <- function(data, latitude, longitude, new_column = "latlong",
                            sep = ", ", drop_na = FALSE) {
  
  lat_col    <- gsub('^"|"$', '', deparse(substitute(latitude)))
  lon_col    <- gsub('^"|"$', '', deparse(substitute(longitude)))
  new_column <- gsub('^"|"$', '', deparse(substitute(new_column)))
  
  if (!lat_col %in% names(data))
    stop(paste0("[latlong_combine] latitude column not found -> ",  lat_col))
  if (!lon_col %in% names(data))
    stop(paste0("[latlong_combine] longitude column not found -> ", lon_col))
  
  if (drop_na) {
    keep     <- stats::complete.cases(data[, c(lat_col, lon_col)])
    removed  <- sum(!keep)
    data     <- data[keep, , drop = FALSE]
    message(sprintf("[latlong_combine] %d NA row(s) removed", removed))
  }
  
  data[[new_column]] <- paste0(as.character(data[[lat_col]]), sep,
                               as.character(data[[lon_col]]))
  data
}
