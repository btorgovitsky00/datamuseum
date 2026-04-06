#' Clean taxonomic name formatting
#'
#' Standardizes taxonomic name formatting by removing extra whitespace,
#' fixing capitalization, and flagging uncertain names (cf., sp., ?).
#'
#' Clean taxonomic name formatting
#'
#' @description
#' Standardises taxonomic name formatting by removing extra whitespace,
#' stripping control characters, and flagging uncertain names containing
#' \code{cf.}, \code{sp.}, or \code{?} as \code{NA}. Cleaned values are
#' either appended as a new \code{<column>_clean} column or used to replace
#' the original column in place.
#'
#' @param data A data frame.
#' @param columns Column name or \code{c()} of column names to clean,
#'   supplied either unquoted (\code{species}) or quoted (\code{"species"}).
#' @param in_place Logical. If \code{TRUE}, the original column is overwritten
#'   with cleaned values. If \code{FALSE} (default), a new column named
#'   \code{<column>_clean} is inserted immediately after the original column.
#' @param drop_na Logical. If \code{TRUE}, rows where the cleaned column
#'   contains \code{NA} — including those flagged as uncertain — are dropped.
#'   Applied per column independently. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with cleaned taxonomic columns. When
#' \code{in_place = FALSE}, one new character column is inserted per entry in
#' \code{columns}, named \code{<column>_clean} and positioned immediately
#' after the source column. A console message per column reports the number
#' of \code{NA} values and the number of uncertain names flagged before
#' cleaning.
#'
#' @details
#' Cleaning applies the following steps in order to each column:
#' \enumerate{
#'   \item Leading and trailing whitespace is removed via
#'     \code{stringr::str_trim()}.
#'   \item Internal runs of whitespace are collapsed to a single space.
#'   \item Control characters are stripped.
#'   \item Values matching \code{cf.}, \code{sp.}, or \code{?} (
#'     case-insensitive, whole-word) are replaced with \code{NA}.
#' }
#'
#' Uncertain name detection is reported before flagging, so the console
#' message reflects the count in the original values rather than after
#' replacement. When multiple columns are supplied, \code{drop_na} is applied
#' independently to each column in sequence, so row counts may differ across
#' columns.
#'
#' Capitalisation is not modified; names are returned with the same case as
#' the input after whitespace normalisation.
#'
#' @seealso
#' \code{\link{taxon_combine}} for merging genus and epithet columns after
#' cleaning,
#'
#' \code{\link{taxon_split}} for splitting a binomial name column before
#' cleaning individual parts,
#'
#' \code{\link{taxon_validate}} for validating cleaned names against ITIS
#' and GBIF,
#'
#' \code{\link{taxon_spellcheck}} for identifying and correcting misspellings
#' after cleaning,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns,
#'
#' \code{\link{italicize}} for formatting taxonomic names for
#' \pkg{ggplot2} display.
#'
#' @examples
#' df <- data.frame(
#'   species = c("Homo sapiens", "Panthera  leo", "Canis cf. lupus",
#'               "Ursus sp.", NA)
#' )
#'
#' # Append a cleaned column (default)
#' taxon_cleaner(df, species)
#'
#' # Clean in place
#' taxon_cleaner(df, in_place = TRUE, columns = species)
#'
#' # Drop rows flagged as uncertain or NA after cleaning
#' taxon_cleaner(df, species, drop_na = TRUE)
#'
#' # Clean multiple columns at once
#' df2 <- data.frame(
#'   genus   = c("Homo", "Panthera", "Canis cf.", NA),
#'   species = c("sapiens", "leo  ", "lupus", "arctos")
#' )
#' taxon_cleaner(df2, c(genus, species))
#'
#' @export
















taxon_cleaner <- function(data, columns, in_place = FALSE, drop_na = FALSE) {
  
  col_sub <- substitute(columns)
  columns <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }
  
  cleaned       <- data
  insert_offset <- 0
  
  for (col in columns) {
    if (!col %in% names(cleaned)) next
    
    vals <- as.character(cleaned[[col]])
    vals <- stringr::str_trim(vals)
    vals <- gsub("\\s+", " ", vals)
    vals <- gsub("[[:cntrl:]]", "", vals)
    
    message(sprintf("[taxon_cleaner] '%s': %d NA row(s), %d uncertain row(s) (cf./sp./?)",
                    col,
                    sum(is.na(vals)),
                    sum(!is.na(vals) & grepl("\\b(cf|sp)\\b|\\?", vals, ignore.case = TRUE))))
    
    uncertain_idx       <- !is.na(vals) & grepl("\\b(cf|sp)\\b|\\?", vals, ignore.case = TRUE)
    vals[uncertain_idx] <- NA_character_
    
    if (in_place) {
      cleaned[[col]] <- vals
    } else {
      col_index <- which(names(cleaned) == col) + insert_offset
      clean_col <- paste0(col, "_clean")
      cleaned <- if (col_index >= ncol(cleaned)) {
        cleaned[[clean_col]] <- vals
        cleaned
      } else {
        cbind(
          cleaned[1:col_index],
          setNames(list(vals), clean_col),
          cleaned[(col_index + 1):ncol(cleaned)]
        )
      }
      insert_offset <- insert_offset + 1
    }
    
    # drop_na applies independently of in_place — drops on the relevant column
    if (drop_na) {
      target_col <- if (in_place) col else paste0(col, "_clean")
      cleaned    <- cleaned[!is.na(cleaned[[target_col]]), ]
    }
  }
  
  cleaned
}
