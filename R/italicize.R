#' Format taxonomic names for italic display in ggplot2
#'
#' @description
#' Converts taxonomic names in one or more columns to plotmath italic
#' expressions suitable for use in \pkg{ggplot2} axis labels or legends
#' via \code{ggplot2::label_parsed}. A new column named
#' \code{<column>_italic} is appended to the data frame for each
#' input column.
#'
#' @param data A data frame.
#' @param columns Column name or \code{c()} of column names to italicize,
#'   supplied either unquoted (\code{SciName}) or quoted (\code{"SciName"}).
#'   Each named column must contain character strings
#'   (e.g. \code{"Homo sapiens"}).
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in any of the
#'   specified columns are dropped before conversion. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with one additional character column appended per
#' entry in \code{columns}, named \code{<column>_italic}. Each new column
#' contains a plotmath expression of the form \code{"italic(Genus~species)"},
#' where spaces are replaced with \code{~} to preserve word spacing when
#' rendered. \code{NA} values in the source column remain \code{NA} in the
#' output column when \code{drop_na = FALSE}.
#'
#' @details
#' The \code{_italic} columns are intended to be mapped to a \pkg{ggplot2}
#' aesthetic (e.g. \code{aes(x = Species_italic)}) and rendered as parsed
#' expressions by passing \code{\link[ggplot2]{label_parsed}} to the
#' \code{labels} argument of the corresponding scale. This keeps names as
#' plain character data until the plot is rendered, avoiding manual
#' \code{expression()} calls.
#'
#' Authorship strings appended by \code{\link{taxon_cite}} in the format
#' \code{"Genus species (Author, Year)"} are automatically detected and
#' rendered in roman type alongside the italic canonical name, producing
#' expressions of the form \code{italic("Genus species")~"(Author, Year)"}.
#'
#' Spaces in names are replaced with \code{~} prior to wrapping in
#' \code{italic()}, which is required for plotmath to render multi-word
#' names (e.g. genus + species) correctly.
#'
#' @seealso
#' \code{\link{taxon_cleaner}} for standardising taxonomic name formatting
#' before italicising,
#'
#' \code{\link{taxon_combine}} for merging genus and epithet into a binomial
#' name before italicising,
#'
#' \code{\link{taxon_validate}} for validating taxonomic names before
#' italicising,
#'
#' \code{\link{taxon_spellcheck}} for correcting misspellings before
#' italicising,
#'
#' \code{\link{taxon_cite}} for appending authorship in the format detected
#' and rendered by this function,
#'
#' \code{\link[ggplot2]{label_parsed}} for rendering plotmath expressions in
#' \pkg{ggplot2} scales.
#'
#' @examples
#' df <- data.frame(
#'   SciName = c("Homo sapiens", "Panthera leo", "Canis lupus"),
#'   count   = c(120, 45, 78)
#' )
#'
#' # Italicize a single column
#' df <- italicize(df, SciName)
#' df$SciName_italic
#'
#' # Use in a ggplot2 axis with parsed labels
#' \dontrun{
#' ggplot(df, aes(x = SciName_italic, y = count)) +
#'   geom_col() +
#'   scale_x_discrete(labels = ggplot2::label_parsed)
#' }
#'
#' # Italicize multiple columns at once
#' df2 <- data.frame(
#'   genus   = c("Homo", "Panthera"),
#'   species = c("sapiens", "leo")
#' )
#' italicize(df2, c(genus, species))
#'
#' # Drop rows where the name column is NA
#' df_na <- data.frame(
#'   SciName = c("Homo sapiens", NA, "Canis lupus"),
#'   count   = c(10, 5, 8)
#' )
#' italicize(df_na, SciName, drop_na = TRUE)
#'
#' @export
















italicize <- function(data, columns, drop_na = FALSE) {
  
  col_sub <- substitute(columns)
  columns <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }
  
  for (col in columns) {
    if (!col %in% names(data)) next
    
    if (drop_na)
      data <- data[!is.na(data[[col]]), ]
    
    vals <- as.character(data[[col]])
    
    italic_vals <- vapply(vals, function(x) {
      if (is.na(x)) return(NA_character_)
      canonical  <- trimws(sub("\\s*\\(.*\\)\\s*$", "", x))
      authorship <- regmatches(x, regexpr("\\(.*\\)$", x))
      if (length(authorship) > 0 && nchar(authorship) > 0) {
        sprintf('italic("%s")~"%s"', canonical, authorship)
      } else {
        sprintf('italic("%s")', canonical)
      }
    }, character(1), USE.NAMES = FALSE)
    
    data[[paste0(col, "_italic")]] <- italic_vals
  }
  
  data
}
