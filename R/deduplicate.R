#' Remove duplicate rows
#'
#' @description
#' Removes duplicate rows from a data frame based on a specified ID column,
#' retaining the most complete row (fewest \code{NA} values) per ID group.
#' A record of all duplicate groups is attached to the result as an attribute.
#'
#' @param data A data frame.
#' @param id_col Column name of the ID column to use for duplicate detection,
#'   supplied either unquoted (\code{id}) or quoted (\code{"id"}).
#' @param drop_na Logical. If \code{TRUE}, rows where the ID column is
#'   \code{NA} are dropped before de-duplication. Default is \code{FALSE}.
#'
#' @return
#' A data frame with one row retained per unique value of \code{id_col},
#' chosen by maximum row completeness (fewest \code{NA}s across all
#' columns). The original duplicate groups are accessible via
#' \code{attr(result, "duplicates")}, a data frame containing all rows that
#' were part of a duplicate group, with an additional logical column
#' \code{.kept_row} indicating which row was retained.
#'
#' @details
#' Row completeness is computed as the count of non-\code{NA} values across
#' all columns using \code{rowSums(!is.na(data))}. When multiple rows tie on
#' completeness, \code{which.max()} retains the first occurrence.
#'
#' Progress messages are printed to the console reporting the number of
#' \code{NA} ID rows removed (if \code{drop_na = TRUE}) and the total number
#' of duplicate rows removed.
#'
#' @seealso
#' \code{\link{duplicate}} for the inverse operation of expanding rows by a
#' count column,
#'
#' \code{\link[base]{duplicated}} for simple duplicate detection,
#'
#' \code{\link[dplyr]{distinct}} for dropping exact duplicate rows.
#'
#' @examples
#' df <- data.frame(
#'   id    = c(1, 2, 2, 3, 3),
#'   name  = c("A", "B", NA, "C", "C"),
#'   score = c(90, 85, 85, 78, 78)
#' )
#'
#' # Retain the most complete row per ID
#' deduplicate(df, id_col = id)
#'
#' # Inspect which rows were flagged as duplicates
#' result <- deduplicate(df, id_col = id)
#' attr(result, "duplicates")
#'
#' # Drop rows where the ID itself is NA before deduplication
#' df_na <- data.frame(
#'   id    = c(1, NA, 2, 2),
#'   value = c("a", "b", "c", "d")
#' )
#' deduplicate(df_na, id_col = id, drop_na = TRUE)
#'
#' @export
















deduplicate <- function(data, id_col, drop_na = FALSE) {
  
  id_col <- gsub('^"|"$', '', deparse(substitute(id_col)))
  
  if (!id_col %in% names(data))
    stop(paste0("[deduplicate] ID column not found -> ", id_col))
  
  # --- Optional NA removal on ID column ---
  if (drop_na) {
    keep       <- !is.na(data[[id_col]])
    removed_na <- sum(!keep)
    data       <- data[keep, , drop = FALSE]
    message(sprintf("[deduplicate] %d NA row(s) removed from ID column", removed_na))
  }
  
  # --- Compute row completeness ---
  data$.completeness <- rowSums(!is.na(data))
  
  # --- Identify and retain most complete row per ID ---
  dup_groups <- split(seq_len(nrow(data)), data[[id_col]])
  keep_rows  <- integer(0)
  dup_table  <- data.frame()
  
  for (idx in dup_groups) {
    if (length(idx) == 1) {
      keep_rows <- c(keep_rows, idx)
      next
    }
    keep_idx  <- idx[which.max(data$.completeness[idx])]
    keep_rows <- c(keep_rows, keep_idx)
    
    tmp            <- data[idx, , drop = FALSE]
    tmp$.kept_row  <- seq_len(nrow(tmp)) == which.max(data$.completeness[idx])
    dup_table      <- rbind(dup_table, tmp)
  }
  
  # --- Filter and clean ---
  filtered              <- data[keep_rows, , drop = FALSE]
  filtered$.completeness <- NULL
  if (nrow(dup_table) > 0) dup_table$.completeness <- NULL
  
  message(sprintf("[deduplicate] %d duplicate row(s) removed",
                  nrow(data) - nrow(filtered)))
  
  attr(filtered, "duplicates") <- dup_table
  
  filtered
}
