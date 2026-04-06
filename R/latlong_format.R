#' Check the format of coordinate columns
#'
#' @description
#' Detects and reports the coordinate format -- decimal degrees, DMS
#' (\code{DDdeg.MM'SS''}), or base-60 (\code{DDdeg.MM'}) -- of values in one or more
#' columns. Combined columns (latitude and longitude stored as a single
#' delimited string) are split before format detection. Results are returned
#' as a named list, one element per column.
#'
#' @param data A data frame containing coordinate columns.
#' @param columns Column name or \code{c()} of column names to check,
#'   supplied either unquoted (\code{lat}) or quoted (\code{"lat"}).
#' @param sep Character. Separator used to split combined coordinate columns
#'   before format detection. Default is \code{","}.
#' @param drop_na Logical. If \code{TRUE}, values that do not match any
#'   recognized coordinate format are excluded before summarizing results.
#'   Default is \code{TRUE}.
#'
#' @return
#' A named list with one element per column in \code{columns}. Each element
#' is itself a named list with two components:
#' \describe{
#'   \item{\code{format}}{Character vector of detected format names present in
#'     the column. One or more of \code{"decimal"}, \code{"dms"},
#'     \code{"base60"}. Returns \code{"unknown"} if no values match any
#'     recognised format (or if all values are excluded by \code{drop_na}).}
#'   \item{\code{counts}}{Integer vector of the same length as \code{format},
#'     giving the number of values matching each detected format.}
#' }
#'
#' @details
#' The three recognised coordinate formats are:
#' \itemize{
#'   \item Decimal degrees: \code{"-12.345"} or \code{"51.5"}
#'   \item DMS: \code{"12deg.34'56''N"}
#'   \item Base-60: \code{"12deg.34'N"}
#' }
#'
#' A column may return multiple formats if values are inconsistently
#' formatted -- for example, a mix of decimal and DMS entries. This is
#' reported rather than resolved, allowing the user to decide how to
#' handle mixed formats before passing columns to
#' \code{\link{latlong_combine}} or \code{\link{latlong_split}}.
#'
#' Combined columns (those containing \code{sep}) are detected automatically
#' and split before format checking, so the same \code{sep} used in
#' \code{\link{latlong_combine}} or \code{\link{latlong_split}} should be
#' passed here for consistent results.
#'
#' @seealso
#' \code{\link{latlong_column}} for detecting which columns in a data frame
#' contain coordinates,
#'
#' \code{\link{latlong_combine}} for merging separate coordinate columns into
#' one,
#'
#' \code{\link{latlong_split}} for splitting a combined coordinate column into
#' separate latitude and longitude columns,
#'
#' \code{\link{latlong_filter}} for removing invalid coordinates after checking
#' formats,
#'
#' \code{\link{latlong_convert}} for converting coordinate formats after
#' checking.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c("51.5", "48.8", "40.7", "35.6"),
#'   lon = c("-0.1", "2.3", "-74.0", "139.7")
#' )
#'
#' # Check format of a single column
#' latlong_format(df, lat)
#'
#' # Check multiple columns at once
#' latlong_format(df, c(lat, lon))
#'
#' # Mixed formats in one column
#' df_mixed <- data.frame(
#'   coords = c("51.5", "48deg.52'N", "40.7", "35deg.36'00''N")
#' )
#' latlong_format(df_mixed, coords)
#'
#' # Combined latitude-longitude column with custom separator
#' df_combined <- data.frame(
#'   latlon = c("51.5;-0.1", "48.8;2.3", "40.7;-74.0")
#' )
#' latlong_format(df_combined, latlon, sep = ";")
#'
#' # Include unknown-format values in counts
#' df_dirty <- data.frame(
#'   lat = c("51.5", "not_a_coord", "40.7", NA)
#' )
#' latlong_format(df_dirty, lat, drop_na = FALSE)
#'
#' @export
















latlong_format <- function(data, columns, sep = ",", drop_na = TRUE) {
  
  # Consistent column resolution
  col_sub <- substitute(columns)
  cols <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }
  
  # Regex patterns hoisted to function level
  decimal <- "^\\s*-?\\d+(\\.\\d+)?\\s*$"
  dms     <- "^\\s*\\d+deg.\\d+'\\d+''[NnSsEeWw]?\\s*$"
  base60  <- "^\\s*\\d+deg.\\d+'[NnSsEeWw]?\\s*$"
  
  detect_value_format <- function(x, drop_na) {
    x     <- as.character(x)
    types <- character(length(x))
    types[grepl(decimal, x)] <- "decimal"
    types[grepl(dms,     x)] <- "dms"
    types[grepl(base60,  x)] <- "base60"
    types[types == ""]       <- "unknown"
    
    if (drop_na) types <- types[types != "unknown"]
    if (length(types) == 0) return(list(format = "unknown", counts = 0L))
    
    type_counts <- table(factor(types, levels = c("decimal", "dms", "base60")))
    type_counts <- type_counts[type_counts > 0]
    list(
      format = names(type_counts),
      counts = as.integer(type_counts)
    )
  }
  
  out <- lapply(cols, function(col) {
    if (!col %in% names(data))
      stop(paste0("latlong_format: column not found -> ", col))
    
    vec <- data[[col]]
    if (drop_na) vec <- vec[!is.na(vec)]
    
    # Handle combined columns
    all_parts <- if (any(grepl(sep, vec, fixed = TRUE))) {
      unlist(lapply(strsplit(as.character(vec), sep, fixed = TRUE), trimws))
    } else {
      vec
    }
    
    detect_value_format(all_parts, drop_na)
  })
  
  setNames(out, cols)
}
