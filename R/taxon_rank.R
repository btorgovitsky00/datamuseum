#' Detect the taxonomic rank of a column
#'
#' @description
#' Infers the taxonomic rank (e.g. \code{species}, \code{genus},
#' \code{family}) of one or more columns based on column name pattern
#' matching. Returns a named character vector of detected ranks, one per
#' input column. Useful for verifying rank assignments before calling
#' \code{\link{taxon_sort}} or \code{\link{taxon_add}}.
#'
#' @param data A data frame.
#' @param columns Column name or \code{c()} of column names to check,
#'   supplied either unquoted (\code{genus}) or quoted (\code{"genus"}).
#'
#' @return
#' A named character vector the same length as \code{columns}, where names
#' are the input column names and values are the detected rank as a lowercase
#' string (e.g. \code{"family"}, \code{"genus"}). Returns \code{NA} for any
#' column whose name does not match a recognised taxonomic rank pattern.
#'
#' @details
#' Detection uses a two-tier approach applied to the lowercased column name:
#' \enumerate{
#'   \item \strong{Strong match} — the column name contains a full taxonomic
#'     keyword: \code{scientificname}, \code{species}, \code{genus},
#'     \code{family}, \code{order}, \code{class}, \code{phylum},
#'     \code{kingdom}, or \code{taxon}. Strong patterns are checked first and
#'     take priority.
#'   \item \strong{Weak match} — for columns not assigned by a strong match,
#'     substrings of length 3–5 derived from the strong keywords are checked.
#'     The first matching keyword is assigned.
#' }
#' Detection is based on column names only — column values are not inspected.
#' For content-based detection across all columns in a data frame, use
#' \code{\link{taxon_column}} instead.
#'
#' @seealso
#' \code{\link{taxon_column}} for detecting taxonomic columns across an
#' entire data frame using both name and content patterns,
#'
#' \code{\link{taxon_sort}} for sorting columns into standard taxonomic rank
#' order,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns,
#'
#' \code{\link{taxon_validate}} for validation, which uses this function
#' internally to detect column rank.
#'
#' @examples
#' df <- data.frame(
#'   genus       = character(),
#'   family_name = character(),
#'   my_order    = character(),
#'   site        = character()
#' )
#'
#' # Detect rank of a single column
#' taxon_rank(df, genus)
#'
#' # Detect ranks of multiple columns
#' taxon_rank(df, c(genus, family_name, my_order))
#'
#' # NA returned for columns with no recognisable rank pattern
#' taxon_rank(df, c(genus, site))
#'
#' @export



















taxon_rank <- function(data, columns) {

  col_sub <- substitute(columns)
  columns <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else if (is.symbol(col_sub)) {
    val <- tryCatch(eval(col_sub, parent.frame()), error = function(e) NULL)
    if (is.character(val)) val else deparse(col_sub)
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }

  strong_patterns <- c(
    "scientificname", "species", "genus", "family",
    "order", "class", "phylum", "kingdom", "taxon"
  )

  make_weak_patterns <- function(patterns, min_n = 3, max_n = 5) {
    unique(unlist(lapply(patterns, function(p) {
      n <- nchar(p)
      if (n < min_n) return(NULL)
      unlist(lapply(seq_len(n - min_n + 1), function(i)
        vapply(min_n:max_n, function(j)
          if ((i + j - 1) <= n) substr(p, i, i + j - 1) else NA_character_,
          character(1)
        )
      ))
    })))
  }

  weak_patterns <- make_weak_patterns(strong_patterns)
  col_lower     <- tolower(columns)
  col_rank      <- setNames(rep(NA_character_, length(columns)), columns)

  for (pat in strong_patterns) {
    hits <- columns[stringr::str_detect(col_lower, pat) & is.na(col_rank)]
    if (length(hits)) col_rank[hits] <- pat
  }

  unassigned <- columns[is.na(col_rank)]
  if (length(unassigned)) {
    for (col in unassigned) {
      hit <- strong_patterns[stringr::str_detect(
        tolower(col), paste(weak_patterns, collapse = "|")
      )]
      if (length(hit)) col_rank[col] <- hit[1]
    }
  }

  col_rank
}
