#' Split a binomial name column into genus and epithet
#'
#' @description
#' Splits a binomial scientific name column into separate genus and epithet
#' columns, appended to the data frame. The inverse of this operation is
#' \code{\link{taxon_combine}}. Only values matching strict binomial format
#' (\code{"Genus epithet"}) are split; non-conforming values produce
#' \code{NA} in both output columns.
#'
#' @param data A data frame.
#' @param column Column name of the binomial name column to split, supplied
#'   either unquoted (\code{scientific_name}) or quoted
#'   (\code{"scientific_name"}).
#' @param genus Optional. Name for the genus output column. Default is
#'   \code{<column>_genus}.
#' @param epithet Optional. Name for the epithet output column. Default is
#'   \code{<column>_epithet}.
#' @param drop_na Logical. If \code{TRUE}, rows where splitting produces
#'   \code{NA} — including non-conforming names — are dropped. Default is
#'   \code{FALSE}.
#'
#' @return
#' The input data frame with two additional character columns appended, named
#' according to \code{genus} and \code{epithet}. The original \code{column}
#' is retained. Values that do not match the expected binomial format produce
#' \code{NA} in both output columns.
#'
#' @details
#' Splitting is performed by splitting on the first space. A value is
#' considered a valid binomial if it matches the pattern
#' \code{"^[A-Z][a-z]+ [a-z]+$"} — an initial-capitalised genus followed by
#' a single lowercase epithet, separated by one space. Values with
#' authorship, infraspecific ranks, uncertainty markers (\code{cf.},
#' \code{sp.}), or extra whitespace will not match and produce \code{NA}.
#' Use \code{\link{taxon_cleaner}} to standardise formatting before splitting.
#'
#' @seealso
#' \code{\link{taxon_combine}} for merging separate genus and epithet columns
#' into a binomial name,
#'
#' \code{\link{taxon_cleaner}} for standardising binomial name formatting
#' before splitting,
#'
#' \code{\link{taxon_validate}} for validating split columns against ITIS
#' and GBIF,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns after
#' splitting.
#'
#' @examples
#' df <- data.frame(
#'   scientific_name = c("Homo sapiens", "Panthera leo", "Canis lupus")
#' )
#'
#' # Split with default output column names
#' taxon_split(df, column = scientific_name)
#'
#' # Use custom output column names
#' taxon_split(df, column = scientific_name,
#'             genus = "gen", epithet = "sp")
#'
#' # Non-conforming values produce NA in both output columns
#' df_mixed <- data.frame(
#'   scientific_name = c("Homo sapiens", "Canis cf. lupus",
#'                       "Ursus sp.", "panthera leo")
#' )
#' taxon_split(df_mixed, column = scientific_name)
#'
#' # Drop rows that fail to split
#' taxon_split(df_mixed, column = scientific_name, drop_na = TRUE)
#'
#' @export
















taxon_split <- function(data, column, genus = NULL, epithet = NULL, drop_na = FALSE) {
  
  col_name <- gsub('^"|"$', '', deparse(substitute(column)))
  
  vals        <- as.character(data[[col_name]])
  is_binomial <- grepl("^[A-Z][a-z]+ [a-z]+$", vals, perl = TRUE)
  
  genus_vals   <- ifelse(is_binomial, sub(" .*$",   "", vals), NA_character_)
  epithet_vals <- ifelse(is_binomial, sub("^[^ ]+ ", "", vals), NA_character_)
  
  genus_name   <- if (!is.null(genus))   genus   else paste0(col_name, "_genus")
  epithet_name <- if (!is.null(epithet)) epithet else paste0(col_name, "_epithet")
  
  data[[genus_name]]   <- genus_vals
  data[[epithet_name]] <- epithet_vals
  
  if (drop_na)
    data <- data[!is.na(data[[genus_name]]), ]
  
  data
}
