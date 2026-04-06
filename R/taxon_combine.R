#' Combine genus and epithet columns into a binomial name
#'
#' @description
#' Merges separate genus and epithet columns into a single binomial scientific
#' name column, appended to the data frame. Both columns are coerced to
#' character and joined with a single space, following standard binomial
#' nomenclature formatting. The inverse of this operation is
#' \code{\link{taxon_split}}.
#'
#' @param data A data frame.
#' @param genus Column name of the genus column, supplied either unquoted
#'   (\code{genus}) or quoted (\code{"genus"}).
#' @param epithet Column name of the specific epithet column, supplied either
#'   unquoted (\code{epithet}) or quoted (\code{"epithet"}).
#' @param new_column Optional. Unquoted or quoted name for the combined output
#'   column. Default is \code{"scientific_name"}.
#'
#' @return
#' The input data frame with one additional character column appended, named
#' according to \code{new_column}, containing values of the form
#' \code{"<genus> <epithet>"}. The original genus and epithet columns are
#' retained. Rows where either input column is \code{NA} will produce
#' \code{"NA <epithet>"} or \code{"<genus> NA"} in the output column.
#'
#' @details
#' No validation of genus or epithet values is performed. Use
#' \code{\link{taxon_cleaner}} to standardize formatting and remove uncertain
#' names before combining. The resulting binomial column can be passed
#' directly to \code{\link{taxon_add}} for higher rank look-ups or to
#' \code{\link{italicize}} for formatted \pkg{ggplot2} labels.
#'
#' @seealso
#' \code{\link{taxon_split}} for splitting a binomial name column back into
#' separate genus and epithet columns,
#'
#' \code{\link{taxon_cleaner}} for standardising genus and epithet columns
#' before combining,
#'
#' \code{\link{taxon_validate}} for validating the combined binomial name
#' against ITIS and GBIF,
#'
#' \code{\link{taxon_add}} for looking up higher taxonomic ranks from the
#' combined binomial name,
#'
#' \code{\link{italicize}} for formatting the combined name for
#' \pkg{ggplot2} display.
#'
#' @examples
#' df <- data.frame(
#'   genus   = c("Homo", "Panthera", "Canis"),
#'   epithet = c("sapiens", "leo", "lupus")
#' )
#'
#' # Combine with default output column name
#' taxon_combine(df, genus = genus, epithet = epithet)
#'
#' # Use a custom output column name
#' taxon_combine(df, genus = genus, epithet = epithet,
#'               new_column = "binomial")
#'
#' # NA in either column is propagated as a string
#' df_na <- data.frame(
#'   genus   = c("Homo", NA, "Canis"),
#'   epithet = c("sapiens", "leo", NA)
#' )
#' taxon_combine(df_na, genus = genus, epithet = epithet)
#'
#' @export
















taxon_combine <- function(data, genus, epithet, new_column = NULL) {
  
  genus_name   <- gsub('^"|"$', '', deparse(substitute(genus)))
  epithet_name <- gsub('^"|"$', '', deparse(substitute(epithet)))
  col_name     <- if (!is.null(new_column)) new_column else "scientific_name"
  
  data[[col_name]] <- paste(as.character(data[[genus_name]]),
                            as.character(data[[epithet_name]]),
                            sep = " ")
  data
}
