#' Filter rows by coordinate range
#'
#' @description
#' Retains only rows where coordinates fall within specified latitude and
#' longitude bounds. Unlike \code{\link{latlong_filter}}, which validates
#' against absolute geographic limits, this function filters to a
#' user-defined bounding box. Use \code{\link{latlong_limits}} first to
#' inspect the coordinate extent of the data and inform suitable bound values.
#'
#' @param data A data frame containing coordinate columns.
#' @param latitude Column name of the latitude column, supplied either
#'   unquoted (\code{lat}) or quoted (\code{"lat"}). Must contain numeric
#'   or numeric-coercible values in decimal degrees.
#' @param longitude Column name of the longitude column, supplied either
#'   unquoted (\code{lon}) or quoted (\code{"lon"}). Must contain numeric
#'   or numeric-coercible values in decimal degrees.
#' @param lat_min Numeric. Minimum latitude bound (inclusive). Must be in the
#'   range \code{[-90, 90]}.
#' @param lat_max Numeric. Maximum latitude bound (inclusive). Must be in the
#'   range \code{[-90, 90]}.
#' @param lon_min Numeric. Minimum longitude bound (inclusive). Must be in the
#'   range \code{[-180, 180]}.
#' @param lon_max Numeric. Maximum longitude bound (inclusive). Must be in the
#'   range \code{[-180, 180]}.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in either
#'   coordinate column are dropped before range filtering. Default is
#'   \code{FALSE}.
#'
#' @return
#' A data frame containing only rows where latitude falls within
#' \code{[lat_min, lat_max]} and longitude falls within
#' \code{[lon_min, lon_max]}, with the same columns as \code{data}. A console
#' message reports the total rows removed, broken down by \code{NA} rows and
#' out-of-range rows.
#'
#' @details
#' Coordinate columns are coerced to numeric via \code{as.numeric()} before
#' filtering. Non-numeric values (including DMS or base-60 strings) will
#' produce \code{NA} after coercion and be treated as out-of-range. Use
#' \code{\link{latlong_convert}} to convert to decimal degrees before calling
#' this function if columns are not already numeric.
#'
#' All bounds are inclusive. Rows with \code{NA} coordinates are excluded from
#' the retained set regardless of \code{drop_na}, as they cannot be evaluated
#' against the bounds. When \code{drop_na = FALSE}, \code{NA} rows contribute
#' to the out-of-range count in the console message rather than the \code{NA}
#' count.
#'
#' @seealso
#' \code{\link{latlong_limits}} for inspecting the coordinate extent of a
#' data frame to inform bound selection,
#'
#' \code{\link{latlong_filter}} for removing coordinates outside absolute
#' geographic validity ranges,
#'
#' \code{\link{latlong_convert}} for converting DMS or base-60 columns to
#' decimal degrees before filtering,
#'
#' \code{\link{latlong_split}} for separating a combined coordinate column
#' into distinct latitude and longitude columns before filtering as
#' \code{\link{latlong_range}} does not function with combined columns,
#'
#' \code{\link{latlong_region}} for filtering to named geographic regions
#' rather than a numeric bounding box.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:6,
#'   lat = c(51.5, 48.8, -33.9, 40.7, 35.6, 55.8),
#'   lon = c(-0.1, 2.3, 151.2, -74.0, 139.7, 37.6)
#' )
#'
#' # Retain only rows within a European bounding box
#' latlong_range(df, latitude = lat, longitude = lon,
#'               lat_min = 35, lat_max = 60,
#'               lon_min = -10, lon_max = 40)
#'
#' # Use latlong_limits first to inspect coordinate extent
#' df |>
#'   latlong_limits(latitude = lat, longitude = lon) |>
#'   latlong_range(latitude = lat, longitude = lon,
#'                 lat_min = 35, lat_max = 60,
#'                 lon_min = -10, lon_max = 40)
#'
#' # Drop NA rows before filtering
#' df_na <- data.frame(
#'   lat = c(51.5, NA, -33.9, 40.7),
#'   lon = c(-0.1, 2.3, 151.2, NA)
#' )
#' latlong_range(df_na, latitude = lat, longitude = lon,
#'               lat_min = 0, lat_max = 60,
#'               lon_min = -10, lon_max = 40,
#'               drop_na = TRUE)
#'
#' @export















latlong_range <- function(data, latitude, longitude,
                          lat_min, lat_max,
                          lon_min, lon_max,
                          drop_na = FALSE) {
  
  lat_col <- gsub('^"|"$', '', deparse(substitute(latitude)))
  lon_col <- gsub('^"|"$', '', deparse(substitute(longitude)))
  
  if (!lat_col %in% names(data))
    stop(paste0("[latlong_range] latitude column not found -> ", lat_col))
  if (!lon_col %in% names(data))
    stop(paste0("[latlong_range] longitude column not found -> ", lon_col))
  
  lat_vals <- suppressWarnings(as.numeric(data[[lat_col]]))
  lon_vals <- suppressWarnings(as.numeric(data[[lon_col]]))
  
  na_removed <- 0
  if (drop_na) {
    keep       <- !is.na(lat_vals) & !is.na(lon_vals)
    na_removed <- sum(!keep)
    data       <- data[keep, , drop = FALSE]
    lat_vals   <- lat_vals[keep]
    lon_vals   <- lon_vals[keep]
  }
  
  in_range <- !is.na(lat_vals) & !is.na(lon_vals) &
    lat_vals >= lat_min & lat_vals <= lat_max &
    lon_vals >= lon_min & lon_vals <= lon_max
  
  result <- data[in_range, , drop = FALSE]
  
  message(sprintf("[latlong_range] %d row(s) removed: %d NA, %d out of range",
                  nrow(data) - nrow(result) + na_removed,
                  na_removed,
                  nrow(data) - nrow(result)))
  
  result
}
