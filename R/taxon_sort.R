#' Sort columns into standard taxonomic rank order
#'
#' @description
#' Reorders data frame columns so that detected taxonomic rank columns appear
#' in standard hierarchical order, with non-taxonomic columns preserved in
#' their original relative positions. Taxonomic columns are detected
#' automatically via \code{\link{taxon_column}}, or a custom column order can
#' be specified manually via \code{manual}.
#'
#' @param data A data frame.
#' @param manual Optional. A numeric vector of at least two column indices
#'   specifying a custom sort order for those columns. The selected columns
#'   are moved to the position of the lowest index in \code{manual}, in the
#'   order supplied. If \code{FALSE} (default), standard taxonomic rank order
#'   is used via automatic detection.
#'
#' @return
#' The input data frame with taxonomic columns reordered, all other columns
#' retained in their original relative positions. A console message reports
#' the number of columns sorted, the insertion position, and the resulting
#' column order. If duplicate rank assignments are detected, a warning is
#' issued and the data frame is returned unchanged.
#'
#' @details
#' The standard rank hierarchy used for automatic sorting is, from broadest
#' to most specific: \code{kingdom}, \code{subkingdom}, \code{infrakingdom},
#' \code{superphylum}, \code{phylum}, \code{subphylum}, \code{infraphylum},
#' \code{superclass}, \code{class}, \code{subclass}, \code{infraclass},
#' \code{superorder}, \code{order}, \code{suborder}, \code{infraorder},
#' \code{superfamily}, \code{family}, \code{subfamily}, \code{tribe},
#' \code{subtribe}, \code{genus}, \code{subgenus}, \code{species},
#' \code{subspecies}, \code{variety}.
#'
#' Taxonomic columns not matching a rank in the hierarchy are appended after
#' the sorted known-rank columns. If multiple columns are detected for the
#' same rank, a warning is issued and the data frame is returned unsorted --
#' use \code{\link{taxon_column}} with \code{output = "list"} to inspect
#' assignments and either rename columns or use \code{manual} to specify the
#' desired order explicitly.
#'
#' If no taxonomic columns are detected, a message is printed and the
#' original data frame is returned unchanged.
#'
#' @seealso
#' \code{\link{taxon_column}} for detecting taxonomic columns and inspecting
#' rank assignments before sorting,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns before
#' sorting,
#'
#' \code{\link{taxon_validate}} for validating taxonomic names before sorting.
#'
#' @examples
#' df <- data.frame(
#'   id      = 1:3,
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus"),
#'   kingdom = c("Animalia", "Animalia", "Animalia"),
#'   family  = c("Hominidae", "Felidae", "Canidae"),
#'   order   = c("Primates", "Carnivora", "Carnivora")
#' )
#'
#' # Automatic sort into standard rank order
#' taxon_sort(df)
#'
#' # Manual sort by column index
#' taxon_sort(df, manual = c(3, 5, 4, 2))
#'
#' # Inspect rank assignments first if sort returns a warning
#' taxon_column(df, output = "list")
#'
#' @export
















taxon_sort <- function(data, manual = FALSE) {
  
  rank_hierarchy <- c(
    "kingdom", "subkingdom", "infrakingdom",
    "superphylum", "phylum", "subphylum", "infraphylum",
    "superclass", "class", "subclass", "infraclass",
    "superorder", "order", "suborder", "infraorder",
    "superfamily", "family", "subfamily",
    "tribe", "subtribe",
    "genus", "subgenus",
    "species", "subspecies", "variety"
  )
  
  # --- Manual column ordering ---
  if (!isFALSE(manual)) {
    
    if (!is.numeric(manual) || length(manual) < 2)
      stop("[taxon_sort] manual must be FALSE or a numeric vector of at least 2 column indices")
    if (any(manual > ncol(data) | manual < 1))
      stop(sprintf("[taxon_sort] manual indices out of range (data has %d columns)", ncol(data)))
    
    manual_cols <- names(data)[manual]
    insert_pos  <- min(manual)
    other_cols  <- names(data)[!names(data) %in% manual_cols]
    
    new_order <- c(
      if (insert_pos > 1) other_cols[seq_len(insert_pos - 1)] else character(0),
      manual_cols,
      other_cols[other_cols %in% names(data)[insert_pos:ncol(data)]]
    )
    
    data <- data[, new_order[new_order %in% names(data)], drop = FALSE]
    
    message(sprintf("[taxon_sort] %d column(s) manually sorted from position %d: %s",
                    length(manual_cols), insert_pos,
                    paste(manual_cols, collapse = " -> ")))
    
    return(data)
  }
  
  # --- Automatic taxonomic column detection ---
  detected   <- taxon_column(data, output = "list")
  duplicates <- Filter(function(x) length(x) > 1, detected)
  
  if (length(duplicates) > 0) {
    warning(sprintf(
      "[taxon_sort] multiple columns detected for the same taxonomic rank -- review before sorting: %s",
      paste(
        vapply(names(duplicates), function(rank)
          sprintf("%s (%s)", rank, paste(names(duplicates[[rank]]), collapse = ", ")),
          character(1)
        ),
        collapse = "; "
      )
    ))
    return(data)
  }
  
  taxon_cols <- unlist(lapply(detected, names))
  
  if (length(taxon_cols) == 0) {
    message("[taxon_sort] no taxonomic columns detected")
    return(data)
  }
  
  col_positions     <- which(names(data) %in% taxon_cols)
  insert_pos        <- min(col_positions)
  in_hierarchy      <- rank_hierarchy[rank_hierarchy %in% tolower(taxon_cols)]
  known_sorted      <- taxon_cols[match(in_hierarchy, tolower(taxon_cols))]
  unknown_cols      <- taxon_cols[!tolower(taxon_cols) %in% rank_hierarchy]
  sorted_taxon_cols <- c(known_sorted[!is.na(known_sorted)], unknown_cols)
  
  other_cols <- names(data)[!names(data) %in% sorted_taxon_cols]
  new_order  <- c(
    if (insert_pos > 1) other_cols[seq_len(insert_pos - 1)] else character(0),
    sorted_taxon_cols,
    other_cols[other_cols %in% names(data)[insert_pos:ncol(data)]]
  )
  
  data <- data[, new_order[new_order %in% names(data)], drop = FALSE]
  
  message(sprintf("[taxon_sort] %d taxonomic column(s) sorted from position %d: %s",
                  length(sorted_taxon_cols), insert_pos,
                  paste(sorted_taxon_cols, collapse = " -> ")))
  
  data
}
