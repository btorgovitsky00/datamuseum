#' Duplicate rows by a count column
#'
#' @description
#' Expands a data frame by repeating each row X number of times, specified
#' by a count column. Useful for reconstructing individual-level data from
#' aggregated or frequency-weighted data frames.
#'
#' @param data A data frame.
#' @param n_col Column name of the column containing duplication counts,
#'   supplied either unquoted (\code{n}) or quoted (\code{"n"}).
#'   Rows with \code{NA} counts are counted once unless
#'   \code{drop_na = TRUE}.
#' @param drop_na Logical. If \code{TRUE}, rows where \code{n_col} is
#'   \code{NA} are dropped before expansion. Default is \code{FALSE}.
#'
#' @return
#' A data frame with more rows than \code{data}, where each row \code{i}
#' appears \code{n_col[i]} times (or once if \code{n_col[i]} is \code{NA}
#' and \code{drop_na = FALSE}). Row names are not reset. The \code{n_col}
#' column is retained in the output.
#'
#' @details
#' Expansion is performed via \code{rep(seq_len(nrow(data)), times = n_col)},
#' so the original row order is preserved within each group of duplicates.
#' \code{NA} counts are replaced with \code{1} prior to expansion when
#' \code{drop_na = FALSE}.
#'
#' A console message reports the final row count of the expanded data frame.
#'
#' @seealso
#' \code{\link{deduplicate}} for the inverse operation,
#' 
#' \code{\link[base]{rep}} for the underlying row repetition mechanism.
#'
#' @examples
#' df <- data.frame(
#'   group = c("A", "B", "C"),
#'   value = c(10, 20, 30),
#'   n     = c(3, 1, 2)
#' )
#'
#' # Expand so each row repeats n times
#' duplicate(df, n_col = n)
#'
#' # NA counts default to 1 repetition
#' df_na <- data.frame(
#'   group = c("A", "B", "C"),
#'   n     = c(2, NA, 3)
#' )
#' duplicate(df_na, n_col = n)
#'
#' # Drop rows with NA counts instead
#' duplicate(df_na, n_col = n, drop_na = TRUE)
#'
#' @export
















duplicate <- function(data, n_col, drop_na = FALSE) {
  
  n_col <- gsub('^"|"$', '', deparse(substitute(n_col)))
  
  if (!n_col %in% names(data))
    stop(paste0("[duplicate] column not found -> ", n_col))
  
   # --- Optional NA removal on ID column ---
  if (drop_na) {
    keep       <- !is.na(data[[n_col]])
    removed_na <- sum(!keep)
    data       <- data[keep, , drop = FALSE]
    message(sprintf("[duplicate] %d NA row(s) removed from numbering column", removed_na))
  }
  
  data[[n_col]] <- ifelse(is.na(data[[n_col]]), 1, data[[n_col]])
  
  data <- data[rep(seq_len(nrow(data)), times = data[[n_col]]), , drop = FALSE]
  
  message(sprintf("[duplicate] dataset expanded to %d rows based on '%s'",
                  nrow(data), n_col))
  
  data
}

