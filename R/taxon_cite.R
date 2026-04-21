#' Append authorship and year to taxonomic name columns
#'
#' @description
#' Appends authorship and year to one or more taxonomic name columns using
#' GBIF (preferred) and ITIS (fallback) as reference sources. For each
#' specified column a new \code{<column>_cite} column is appended containing
#' names in the format \code{"Genus species (Author, Year)"}. Intended as
#' the final step in the \code{\link{taxon_validate}} -> \code{\link{taxon_spellcheck}}
#' workflow.
#'
#' @param data A data frame.
#' @param columns Column name or \code{c()} of column names to append
#'   authorship to, supplied either unquoted (\code{species}) or quoted
#'   (\code{"species"}).
#' @param source Character. Taxonomic reference source. One of \code{"both"}
#'   (default), \code{"gbif"}, or \code{"itis"}. When \code{"both"}, GBIF
#'   authorship is preferred and ITIS is used as a fallback when GBIF returns
#'   no valid authorship or a malformed result.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in the
#'   column are dropped before look-up. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with one additional character column appended per
#' entry in \code{columns}, named \code{<column>_cite}. Rows where
#' authorship cannot be found retain the original canonical name in the cite
#' column unchanged. A report tibble is attached as
#' \code{attr(result, "cite_report")} with columns:
#' \describe{
#'   \item{\code{column}}{Name of the column processed.}
#'   \item{\code{name}}{Canonical name for which no authorship was found.}
#'   \item{\code{n}}{Number of rows containing that name.}
#' }
#' An empty tibble is attached when authorship is found for all names.
#' A console message per column reports the number of names resolved and
#' lists any names without authorship.
#'
#' @details
#' Authorship look-up follows the same logic as pass 5 of
#' \code{\link{taxon_validate}}:
#' \itemize{
#'   \item GBIF \code{name_backbone} is queried with \code{strict = TRUE}.
#'   \item \code{HIGHERRANK} results are accepted only when the canonical
#'     name matches the input exactly.
#'   \item Malformed authorship strings starting with a comma or punctuation
#'     are rejected and treated as missing.
#'   \item Synonym chains are followed up to three steps via
#'     \code{name_usage()} to reach the accepted name authorship.
#'   \item When GBIF has no valid authorship and \code{source = "both"},
#'     ITIS \code{itis_getrecord} is queried as a fallback.
#' }
#'
#' Authorship is stripped from input values before lookup (parenthetical
#' suffixes matching \code{\\s*\\(.*\\)\\s*$} are removed), so columns
#' already containing authorship from a prior \code{\link{taxon_validate}}
#' call are handled correctly.
#'
#' Results are memoised for the duration of the session. Only unique
#' non-\code{NA} values are looked up, so performance scales with the number
#' of distinct names rather than total rows.
#'
#' Requires \pkg{rgbif} for GBIF lookups, \pkg{taxize} for ITIS lookups,
#' and \pkg{memoise}. Informative errors are raised if required packages
#' are not installed.
#'
#' @note
#' This function queries external web services (GBIF via \pkg{rgbif} and/or
#' ITIS via \pkg{taxize}) and requires an active internet connection with
#' reliable access to those servers. Performance on unstable or restricted
#' connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
#' or produce incomplete results. Results are memoised for the duration of
#' the session; running on a stable connection first and retaining the
#' session will avoid repeated API calls for the same names.
#'
#' Connectivity can be tested before appending authorship:
#' \preformatted{
#' # Test ITIS connectivity
#' taxize::get_tsn("Homo sapiens", accepted = FALSE, verbose = TRUE,
#'                 messages = TRUE, ask = FALSE)
#'
#' # Test GBIF connectivity
#' rgbif::name_backbone(name = "Homo sapiens", strict = TRUE)
#' }
#'
#' @seealso
#' \code{\link{taxon_validate}} for resolving synonyms and validating names
#' before appending authorship,
#'
#' \code{\link{taxon_spellcheck}} for correcting misspellings before
#' appending authorship,
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns
#' alongside authorship,
#'
#' \code{\link{italicize}} for formatting cited names for \pkg{ggplot2}
#' display as the final step in the workflow.
#'
#' @examples
#' df <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus")
#' )
#'
#' \donttest{
#' if (requireNamespace("rgbif", quietly = TRUE) &&
#'     requireNamespace("taxize", quietly = TRUE)) {
#' # Append authorship to a single column
#' taxon_cite(df, species)
#'
#' # Append authorship to multiple columns
#' df2 <- data.frame(
#'   genus   = c("Homo", "Panthera"),
#'   species = c("Homo sapiens", "Panthera leo")
#' )
#' taxon_cite(df2, c(genus, species))
#'
#' # Use GBIF only
#' taxon_cite(df, species, source = "gbif")
#'
#' # Inspect names where no authorship was found
#' result <- taxon_cite(df, species)
#' attr(result, "cite_report")
#'
#' # Full workflow
#' df |>
#'   taxon_validate(column = species) |>
#'   taxon_spellcheck(column = species, update = TRUE) |>
#'   taxon_add(column = species, ranks = c(family, order)) |>
#'   taxon_cite(columns = species)
#' }
#' }
#'
#' @export











taxon_cite <- function(data, columns, source = "both", drop_na = FALSE) {

  col_sub   <- substitute(columns)
  col_names <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }

  source <- match.arg(tolower(source), c("gbif", "itis", "both"))

  if (source %in% c("gbif", "both")) {
    if (!requireNamespace("rgbif", quietly = TRUE))
      stop("Package 'rgbif' is required. Install with: install.packages('rgbif')")
  }
  if (source %in% c("itis", "both")) {
    if (!requireNamespace("taxize", quietly = TRUE))
      stop("Package 'taxize' is required. Install with: install.packages('taxize')")
  }
  if (!requireNamespace("memoise", quietly = TRUE))
    stop("Package 'memoise' is required. Install with: install.packages('memoise')")

  safe_get <- function(expr, default = NULL)
    tryCatch(expr, error = function(e) default)

  # --- GBIF authorship lookup ---
  author_lookup <- memoise::memoise(function(canonical_name) {

    if (is.null(canonical_name) || length(canonical_name) == 0 ||
        is.na(canonical_name) || nchar(trimws(canonical_name)) == 0)
      return(canonical_name)

    gbif_author    <- NULL
    gbif_canonical <- canonical_name

    if (source %in% c("gbif", "both")) {

      res <- safe_get(rgbif::name_backbone(name = canonical_name, strict = TRUE))

      if (!is.null(res) && nrow(res) > 0 && !isTRUE(res$matchType == "NONE")) {

        canonical_check <- safe_get(res$canonicalName[1])

        higherrank_mismatch <- isTRUE(res$matchType == "HIGHERRANK") &&
          !is.null(canonical_check) && length(canonical_check) > 0 &&
          !identical(tolower(trimws(canonical_check)), tolower(trimws(canonical_name)))

        if (!higherrank_mismatch &&
            !is.null(canonical_check) &&
            length(canonical_check) > 0 &&
            identical(tolower(trimws(canonical_check)), tolower(trimws(canonical_name)))) {

          usage_key <- safe_get({
            val <- res[["acceptedUsageKey"]]
            if (!is.null(val) && length(val) > 0 && !is.na(val[1])) val[1] else {
              val2 <- res[["usageKey"]]
              if (!is.null(val2) && length(val2) > 0 && !is.na(val2[1])) val2[1] else NULL
            }
          })

          resolved <- if (!is.null(usage_key)) {
            safe_get({
              usage <- rgbif::name_usage(key = usage_key)$data
              steps <- 0
              while (steps < 3) {
                next_key <- safe_get({
                  val <- usage[["acceptedKey"]]
                  if (!is.null(val) && length(val) > 0 && !is.na(val[1]) &&
                      val[1] != usage[["key"]][1]) val[1] else NULL
                })
                if (is.null(next_key)) break
                usage <- rgbif::name_usage(key = next_key)$data
                steps <- steps + 1
              }
              usage
            })
          } else NULL

          author_raw <- safe_get({
            src <- if (!is.null(resolved)) resolved else res
            val <- src[["authorship"]]
            if (!is.null(val) && length(val) > 0 && !is.na(val[1]) &&
                nchar(trimws(val[1])) > 0)
              gsub("^\\(|\\)$", "", trimws(val[1])) else NULL
          })

          if (!is.null(author_raw) && length(author_raw) > 0 &&
              !grepl("^[,;\\s]", author_raw) &&
              nchar(trimws(author_raw)) > 0) {
            gbif_author <- author_raw
          }

          gbif_canonical <- safe_get({
            if (!is.null(resolved) && !is.null(resolved$canonicalName) &&
                length(resolved$canonicalName) > 0 &&
                !is.na(resolved$canonicalName[1])) resolved$canonicalName[1]
            else if (!is.null(canonical_check) &&
                     length(canonical_check) > 0) canonical_check
            else canonical_name
          }, canonical_name)

          if (length(gbif_canonical) == 0 || is.na(gbif_canonical))
            gbif_canonical <- canonical_name
        }
      }
    }

    # --- ITIS fallback when GBIF has no valid authorship ---
    if (is.null(gbif_author) && source == "both" &&
        requireNamespace("taxize", quietly = TRUE)) {
      itis_author <- safe_get({
        tsn <- suppressMessages(suppressWarnings(
          taxize::get_tsn(canonical_name, accepted = FALSE, verbose = FALSE,
                          messages = FALSE, ask = FALSE)
        ))
        if (is.null(tsn) || is.na(tsn[[1]])) return(NULL)
        record <- suppressMessages(taxize::itis_getrecord(tsn[[1]]))
        if (is.null(record)) return(NULL)
        auth <- record$taxonAuthor$authorship
        if (!is.null(auth) && length(auth) > 0 && !is.na(auth[1]) &&
            nchar(trimws(auth[1])) > 0)
          gsub("^\\(|\\)$", "", trimws(auth[1])) else NULL
      })
      if (!is.null(itis_author) && length(itis_author) > 0 &&
          nchar(trimws(itis_author)) > 0) {
        result <- paste0(gbif_canonical, " (", itis_author, ")")
        if (length(result) == 0) return(gbif_canonical)
        return(result)
      }
    }

    if (!is.null(gbif_author) && length(gbif_author) > 0)
      return(paste0(gbif_canonical, " (", gbif_author, ")"))

    gbif_canonical
  })

  # --- Process each column ---
  all_reports <- list()

  for (col_name in col_names) {

    if (!col_name %in% names(data)) {
      message(sprintf("[taxon_cite] column '%s' not found -- skipped", col_name))
      next
    }

    vals           <- as.character(data[[col_name]])
    vals_canonical <- trimws(sub("\\s*\\(.*\\)\\s*$", "", vals))
    unique_vals    <- unique(vals_canonical[!is.na(vals_canonical) &
                                              nchar(trimws(vals_canonical)) > 0])

    if (drop_na) {
      keep       <- !is.na(vals)
      removed_na <- sum(!keep)
      if (removed_na > 0)
        message(sprintf("[taxon_cite] %d NA row(s) removed from '%s'",
                        removed_na, col_name))
      data           <- data[keep, , drop = FALSE]
      vals           <- vals[keep]
      vals_canonical <- vals_canonical[keep]
    }

    message(sprintf("[taxon_cite] looking up authorship for %d unique name(s) in '%s'",
                    length(unique_vals), col_name))

    cite_map <- setNames(lapply(seq_along(unique_vals), function(i) {
      name <- unique_vals[i]
      if (i == 1 || i %% 25 == 0 || i == length(unique_vals))
        message(sprintf("[taxon_cite] %s: %d / %d", col_name, i, length(unique_vals)))
      result <- safe_get(author_lookup(name))
      if (is.null(result) || length(result) == 0) name else result
    }), unique_vals)

    cite_vals <- vapply(vals_canonical, function(name) {
      if (is.na(name) || nchar(trimws(name)) == 0) return(NA_character_)
      val <- cite_map[[name]]
      if (is.null(val) || length(val) == 0) return(name)
      val
    }, character(1), USE.NAMES = FALSE)

    data[[paste0(col_name, "_cite")]] <- cite_vals

    # --- Build report: names where no authorship was found ---
    no_citation <- vapply(unique_vals, function(name) {
      cited <- cite_map[[name]]
      if (is.null(cited) || length(cited) == 0) return(TRUE)
      # No authorship found if cited value equals canonical input
      identical(trimws(cited), trimws(name))
    }, logical(1))

    if (any(no_citation)) {
      missing_names <- unique_vals[no_citation]
      report_rows <- tibble::tibble(
        column = col_name,
        name   = missing_names,
        n      = vapply(missing_names, function(nm)
          as.integer(sum(vals_canonical == nm, na.rm = TRUE)), integer(1))
      )
      message(sprintf("[taxon_cite] %d name(s) in '%s' with no authorship found:",
                      nrow(report_rows), col_name))
      for (i in seq_len(nrow(report_rows)))
        message(sprintf("  \"%s\" (n = %d)",
                        report_rows$name[i], report_rows$n[i]))
    } else {
      report_rows <- tibble::tibble(
        column = character(), name = character(), n = integer()
      )
    }

    all_reports[[col_name]] <- report_rows

    resolved_n <- sum(!no_citation, na.rm = TRUE)
    message(sprintf("[taxon_cite] '%s_cite' appended -- %d / %d name(s) with authorship",
                    col_name, resolved_n, length(unique_vals)))
  }

  cite_report <- dplyr::bind_rows(all_reports)
  if (nrow(cite_report) == 0) {
    cite_report <- tibble::tibble(
      column = character(), name = character(), n = integer()
    )
  }

  attr(data, "cite_report") <- cite_report
  data
}
