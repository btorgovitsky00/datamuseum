#' Convert coordinate formats
#'
#' @description
#' Converts coordinate columns between decimal degrees, DMS
#' (\code{DDdeg MM'SS''}), and base-60 (\code{DDdeg MM'}) formats. Handles separate
#' latitude and longitude columns as well as combined coordinate columns.
#' Columns are converted in place; combined columns may optionally be split
#' into separate latitude and longitude columns.
#'
#' @param data A data frame containing coordinate columns.
#' @param column Column name or \code{c()} of column names to convert,
#'   supplied either unquoted (\code{lat}) or quoted (\code{"lat"}).
#' @param convert Character. Target coordinate format. One of
#'   \code{"decimal"} (default), \code{"dms"}, or \code{"base60"}.
#' @param type Character. Coordinate type used for direction suffix assignment
#'   in DMS and base-60 output. One of \code{"auto"} (default), \code{"lat"},
#'   or \code{"lon"}. When \code{"auto"}, type is inferred from the column
#'   name (matching \code{"lat"} or \code{"lon"}/\code{"lng"}/\code{"long"})
#'   or from the value range if the name is uninformative.
#' @param drop_na Logical. If \code{TRUE}, rows where any converted column
#'   contains \code{NA} are dropped after conversion. Default is \code{FALSE}.
#' @param split_combined Logical. If \code{TRUE}, combined coordinate columns
#'   are split into two new columns named \code{<column>_lat} and
#'   \code{<column>_lon} rather than kept as a single combined column.
#'   Default is \code{FALSE}.
#'
#' @return
#' The input data frame with converted coordinate columns. For non-combined
#' columns, the original column is overwritten with the converted values.
#' For combined columns, behavior depends on \code{split_combined}:
#' \itemize{
#'   \item If \code{FALSE}, the combined column is overwritten with converted
#'     values in the same delimited format.
#'   \item If \code{TRUE}, two new columns are appended — \code{<column>_lat}
#'     and \code{<column>_lon} — and the original column is retained.
#' }
#' When \code{convert = "decimal"}, output columns are numeric. For
#' \code{"dms"} and \code{"base60"}, output columns are character.
#'
#' @details
#' All input formats are first parsed to decimal degrees internally before
#' conversion. The parser handles decimal, DMS, and base-60 formats,
#' inferring sign from cardinal direction suffixes (\code{S}, \code{W}) or
#' the sign of the degree value. Zero-width and BOM characters are stripped
#' before parsing.
#'
#' Combined columns are detected automatically by the presence of two or more
#' numeric components in a single value. The separator used to split combined
#' columns is assumed to be \code{","}; use \code{\link{latlong_split}} if a
#' custom separator is needed before converting.
#'
#' Direction suffixes (\code{N}, \code{S}, \code{E}, \code{W}) are appended
#' to DMS and base-60 output when \code{type} can be determined. If
#' \code{type = "auto"} and the type cannot be inferred from the column name
#' or value range, no suffix is added.
#'
#' Use \code{\link{latlong_format}} to check input formats before conversion,
#' and \code{\link{latlong_filter}} to remove out-of-range values beforehand.
#'
#' @seealso
#' \code{\link{latlong_format}} for checking coordinate formats before
#' conversion,
#'
#' \code{\link{latlong_filter}} for removing out-of-range coordinates before
#' conversion,
#'
#' \code{\link{latlong_split}} for splitting combined columns with a custom
#' separator prior to conversion,
#'
#' \code{\link{latlong_combine}} for merging separate coordinate columns after
#' conversion,
#'
#' \code{\link{latlong_range}} for filtering to a bounding box after
#' converting to decimal degrees,
#'
#' \code{\link{latlong_region}} for filtering to named geographic regions
#' after converting to decimal degrees.
#'
#' @examples
#' df <- data.frame(
#'   id  = 1:4,
#'   lat = c(51.5, 48.8, -33.9, 40.7),
#'   lon = c(-0.1, 2.3, 151.2, -74.0)
#' )
#'
#' # Convert decimal columns to DMS
#' latlong_convert(df, c(lat, lon), convert = "dms")
#'
#' # Convert to base-60
#' latlong_convert(df, c(lat, lon), convert = "base60")
#'
#' # Convert a single column, specifying coordinate type explicitly
#' latlong_convert(df, lat, convert = "dms", type = "lat")
#'
#' # Convert a combined column and keep as single column
#' df_combined <- data.frame(
#'   coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2")
#' )
#' latlong_convert(df_combined, coords, convert = "dms")
#'
#' # Convert a combined column and split into separate lat/lon columns
#' latlong_convert(df_combined, coords, convert = "decimal",
#'                 split_combined = TRUE)
#'
#' # Drop rows that produce NA after conversion
#' df_na <- data.frame(
#'   lat = c(51.5, NA, 40.7),
#'   lon = c(-0.1, 2.3, -74.0)
#' )
#' latlong_convert(df_na, c(lat, lon), convert = "dms", drop_na = TRUE)
#'
#' @export
















latlong_convert <- function(data, column, convert = "decimal",
                            type = "auto", drop_na = FALSE,
                            split_combined = FALSE) {

  col_sub <- substitute(column)
  cols <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }

  # --- Parse any format to decimal (direction-aware) ---
  parse_to_decimal <- function(val) {

    if (is.numeric(val)) return(val)

    val <- trimws(gsub("[\u200B-\u200D\uFEFF]", "", enc2utf8(as.character(val))))

    if (is.na(val) || nchar(val) == 0 || val == "NA") return(NA_real_)

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

  # --- Detect coordinate type from name or range ---
  detect_type <- function(name, values) {
    name <- tolower(name)
    if (grepl("lat",          name)) return("lat")
    if (grepl("lon|lng|long", name)) return("lon")
    rng <- range(values, na.rm = TRUE)
    if (all(rng >= -90  & rng <= 90))  return("lat")
    if (all(rng >= -180 & rng <= 180)) return("lon")
    return(NA)
  }

  # --- Direction suffix ---
  add_direction <- function(val, type) {
    if (is.na(val)) return("")
    if (type == "lat") return(ifelse(val < 0, "S", "N"))
    if (type == "lon") return(ifelse(val < 0, "W", "E"))
    return("")
  }

  # --- Formatters ---
  decimal_to_dms <- function(x, type) {
    if (is.na(x)) return(NA_character_)
    x_abs    <- abs(x)
    deg      <- floor(x_abs)
    min_full <- (x_abs - deg) * 60
    min      <- floor(min_full)
    sec      <- round((min_full - min) * 60)
    paste0(deg, "\u00b0", min, "\u2032", sec, "\u2033", add_direction(x, type))
  }

  decimal_to_base60 <- function(x, type) {
    if (is.na(x)) return(NA_character_)
    x_abs <- abs(x)
    deg   <- floor(x_abs)
    min   <- round((x_abs - deg) * 60)
    paste0(deg, "\u00b0", min, "\u2032", add_direction(x, type))
  }

  # --- Detect combined coordinate column ---
  is_combined <- function(val) {
    if (is.na(val)) return(FALSE)
    length(unlist(regmatches(as.character(val),
                             gregexpr("-?\\d+\\.?\\d*", as.character(val))))) >= 2
  }

  # --- Process a single vector ---
  process_vector <- function(vec, name) {

    vec_chr <- as.character(vec)

    if (any(vapply(vec_chr, is_combined, logical(1)), na.rm = TRUE)) {

      split_vals <- strsplit(vec_chr, ",")
      lat        <- vapply(split_vals, function(x) parse_to_decimal(x[1]), numeric(1))
      lon        <- vapply(split_vals, function(x) {
        if (length(x) < 2) return(NA_real_)
        parse_to_decimal(x[2])
      }, numeric(1))

      if (convert == "decimal") {
        if (split_combined) return(data.frame(lat = lat, lon = lon))
        return(paste(lat, lon, sep = ", "))
      }
      if (convert == "dms") {
        lat_fmt <- vapply(lat, decimal_to_dms,    character(1), type = "lat")
        lon_fmt <- vapply(lon, decimal_to_dms,    character(1), type = "lon")
        if (split_combined) return(data.frame(lat = lat_fmt, lon = lon_fmt))
        return(paste(lat_fmt, lon_fmt, sep = ", "))
      }
      if (convert == "base60") {
        lat_fmt <- vapply(lat, decimal_to_base60, character(1), type = "lat")
        lon_fmt <- vapply(lon, decimal_to_base60, character(1), type = "lon")
        if (split_combined) return(data.frame(lat = lat_fmt, lon = lon_fmt))
        return(paste(lat_fmt, lon_fmt, sep = ", "))
      }
    }

    parsed   <- vapply(vec_chr, parse_to_decimal, numeric(1))
    col_type <- if (type == "auto") detect_type(name, parsed) else type

    if (convert == "decimal") return(parsed)
    if (convert == "dms")     return(vapply(parsed, decimal_to_dms,    character(1), type = col_type))
    if (convert == "base60")  return(vapply(parsed, decimal_to_base60, character(1), type = col_type))
  }

  # --- Apply to each column ---
  out <- data

  for (col in cols) {
    if (!col %in% names(data))
      stop(paste0("[latlong_convert] column not found -> ", col))

    result <- process_vector(data[[col]], col)

    if (is.data.frame(result)) {
      out[[paste0(col, "_lat")]] <- result[[1]]
      out[[paste0(col, "_lon")]] <- result[[2]]
    } else {
      out[[col]] <- result
    }
  }

  # --- Drop NA rows ---
  na_removed <- 0
  if (drop_na) {
    keep       <- stats::complete.cases(out[, cols, drop = FALSE])
    na_removed <- sum(!keep)
    out        <- out[keep, , drop = FALSE]
  }

  message(sprintf("[latlong_convert] NA rows removed: %d", na_removed))

  return(out)
}
