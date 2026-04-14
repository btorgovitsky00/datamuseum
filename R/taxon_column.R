#' Identify taxonomic columns
#'
#' @description
#' Detects columns in a data frame that contain taxonomic names based on
#' column name patterns and value content. Returns a summary of detected
#' columns and their value counts, a named list mapping taxonomic ranks to
#' column indices, or both. Useful as a precursor to \code{\link{taxon_add}}
#' and \code{\link{taxon_sort}} to identify existing rank columns before
#' modifying the data frame.
#'
#' @param df A data frame.
#' @param output Character. Format of the return value. One of
#'   \code{"tibble"} (default), \code{"list"}, or \code{"both"}.
#'   See \strong{Value} for details of each format.
#'
#' @return
#' Depends on \code{output}:
#' \describe{
#'   \item{\code{"tibble"}}{A tibble with three columns — \code{column} (the
#'     detected column name), \code{value} (each unique non-\code{NA} value),
#'     and \code{count} (number of occurrences) — sorted by count descending
#'     within each column. Only strongly detected columns are included.}
#'   \item{\code{"list"}}{A named list where each element corresponds to a
#'     taxonomic rank (e.g. \code{species}, \code{family}) and contains a
#'     named list mapping column name to column index in \code{df}. Includes
#'     both strongly and weakly detected columns.}
#'   \item{\code{"both"}}{A list with two elements: \code{counts} (the tibble
#'     described above) and \code{candidates} (the named list described
#'     above).}
#' }
#'
#' @details
#' Detection uses a three-tier matching system applied to column names:
#' \enumerate{
#'   \item \strong{Strong match} — column name contains a full taxonomic
#'     keyword (\code{taxon}, \code{species}, \code{genus}, \code{family},
#'     \code{order}, \code{class}, \code{phylum}, \code{kingdom},
#'     \code{scientificname}).
#'   \item \strong{Weak match (3–5 chars)} — column name contains a substring
#'     of length 3–5 derived from a taxonomic keyword.
#'   \item \strong{Weak match (1–2 chars)} — column name contains a very
#'     short substring; used only for candidate columns not already captured
#'     by stronger tiers.
#' }
#' Columns matching geographic, temporal, or location-related terms
#' (\code{latitude}, \code{longitude}, \code{country}, \code{date}, etc.)
#' are excluded at each tier. Columns where more than 70\% of non-\code{NA}
#' values are numeric and fewer than 20\% contain letters are also excluded
#' as non-taxonomic.
#'
#' When multiple columns match the same rank, all are assigned to that rank
#' in the \code{"list"} output. Use \code{output = "list"} inside
#' \code{\link{taxon_add}} with \code{sort = TRUE} to check for duplicate
#' rank assignments before sorting.
#'
#' @seealso
#' \code{\link{taxon_rank}} for detecting the rank of specific columns
#' by name,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns,
#'
#' \code{\link{taxon_sort}} for sorting columns into standard taxonomic rank
#' order,
#'
#' \code{\link{taxon_validate}} for validating detected columns using
#' \code{update_related}.
#'
#' @examples
#' df <- data.frame(
#'   id      = 1:4,
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus", "Ursus arctos"),
#'   family  = c("Hominidae", "Felidae", "Canidae", "Ursidae"),
#'   count   = c(10, 5, 8, 3)
#' )
#'
#' # Return a tibble of detected columns and value counts (default)
#' taxon_column(df)
#'
#' # Return a named list mapping ranks to column indices
#' taxon_column(df, output = "list")
#'
#' # Return both formats
#' taxon_column(df, output = "both")
#'
#' # Use list output to inspect rank assignments before taxon_add
#' taxon_column(df, output = "list")
#'
#' @export
















taxon_column <- function(df, output = "tibble") {
  output <- match.arg(output, choices = c("tibble", "list", "both"))
  strong_patterns <- c(
    "taxon", "scientificname", "species", "genus", "family",
    "order", "class", "phylum", "kingdom"
  )
  exclude_patterns <- c(
    "latitude", "longitude", "lat", "lon",
    "country", "location", "locality", "site",
    "state", "prefecture", "city",
    "calendar", "date", "year", "month", "day"
  )
  make_weak_patterns <- function(patterns, min_n, max_n) {
    unique(unlist(lapply(patterns, function(p) {
      n <- nchar(p)
      if (n < min_n) return(NULL)
      unlist(lapply(seq_len(n - min_n + 1), function(i)
        sapply(min_n:max_n, function(j)
          if ((i + j - 1) <= n) substr(p, i, i + j - 1)
        )
      ))
    })))
  }
  weak_include_3 <- make_weak_patterns(strong_patterns,  3, 5)
  weak_include_2 <- make_weak_patterns(strong_patterns,  1, 2)
  weak_exclude_3 <- make_weak_patterns(exclude_patterns, 3, 5)
  weak_exclude_2 <- make_weak_patterns(exclude_patterns, 1, 2)
  is_mostly_numeric <- function(x) {
    x <- na.omit(x)
    if (length(x) == 0) return(TRUE)
    numeric_ratio <- mean(stringr::str_detect(x, "^\\d+(\\.\\d+)?$"))
    has_letters   <- mean(stringr::str_detect(x, "[A-Za-z]")) > 0.2
    numeric_ratio > 0.7 & !has_letters
  }
  col_names <- names(df)
  col_lower <- tolower(col_names)
  strong_match   <- stringr::str_detect(col_lower, paste(strong_patterns,  collapse = "|"))
  weak_match_3   <- stringr::str_detect(col_lower, paste(weak_include_3,   collapse = "|"))
  weak_match_2   <- stringr::str_detect(col_lower, paste(weak_include_2,   collapse = "|"))
  exclude_strong <- stringr::str_detect(col_lower, paste(exclude_patterns, collapse = "|"))
  exclude_weak_3 <- stringr::str_detect(col_lower, paste(weak_exclude_3,   collapse = "|"))
  exclude_weak_2 <- stringr::str_detect(col_lower, paste(weak_exclude_2,   collapse = "|"))
  selected_cols  <- col_names[(strong_match | weak_match_3) & !(exclude_strong | exclude_weak_3)]
  candidate_cols <- col_names[(weak_match_2 & !weak_match_3 & !strong_match) & !(exclude_strong | exclude_weak_2)]
  selected_cols  <- selected_cols[!vapply(df[selected_cols],  is_mostly_numeric, logical(1))]
  candidate_cols <- candidate_cols[!vapply(df[candidate_cols], is_mostly_numeric, logical(1))]
  # Count unique values per detected column
  count_fn <- function(col) {
    tbl <- dplyr::filter(df, !is.na(.data[[col]]))
    tbl <- dplyr::count(tbl, .data[[col]], sort = TRUE, name = "count")
    tbl <- dplyr::mutate(tbl, column = col)
    tbl <- dplyr::rename(tbl, value = !!col)
    dplyr::select(tbl, column, value, count)
  }
  result_tbl <- tibble::as_tibble(
    dplyr::bind_rows(lapply(selected_cols, count_fn))
  )
  # Score-based non-overlapping classification
  score_column <- function(col, pattern) {
    subs <- unique(unlist(lapply(seq_len(nchar(pattern)), function(i)
      sapply(1:5, function(j)
        if ((i + j - 1) <= nchar(pattern)) substr(pattern, i, i + j - 1)
      )
    )))
    matches <- subs[stringr::str_detect(tolower(col), subs)]
    if (length(matches) == 0) return(0)
    max(nchar(matches))
  }
  assign_best_pattern <- function(col, patterns) {
    scores <- vapply(patterns, function(p) score_column(col, p), numeric(1))
    if (all(scores == 0)) return(NA_character_)
    patterns[which.max(scores)]
  }
  all_relevant_cols <- unique(c(selected_cols, candidate_cols))
  assignments       <- vapply(all_relevant_cols, assign_best_pattern,
                              character(1), patterns = strong_patterns)
  result_list <- lapply(split(names(assignments), assignments), function(cols) {
    indices <- which(names(df) %in% cols)
    setNames(as.list(indices), cols)
  })
  result_list <- result_list[!is.na(names(result_list)) & lengths(result_list) > 0]
  if (output == "tibble") return(result_tbl)
  if (output == "list")   return(result_list)
  list(counts = result_tbl, candidates = result_list)
}
