#' Check and correct taxonomic name spelling
#'
#' @description
#' Identifies and optionally corrects misspelled taxonomic names using
#' suggestions from a prior \code{\link{taxon_validate}} report, or by
#' running \code{\link{taxon_validate}} internally if no report is provided.
#' Names flagged as misspellings or phantoms with available suggestions are
#' reported and optionally applied; names with no suggestion are flagged for
#' manual review. When corrections are applied, genus columns detected by
#' \code{\link{taxon_column}} are updated automatically from the corrected
#' binomial. A spellcheck report is attached to the result as an attribute.
#'
#' @param data A data frame.
#' @param column Column name or \code{c()} of column names to check,
#'   supplied either unquoted (\code{species}) or quoted (\code{"species"}).
#' @param source Character. Taxonomic reference source passed to the internal
#'   \code{\link{taxon_validate}} call if \code{validation_report} is
#'   \code{NULL}. One of \code{"both"} (default), \code{"gbif"}, or
#'   \code{"itis"}.
#' @param update Logical. If \code{TRUE}, confirmed corrections are applied
#'   to each column in place for names with status \code{"misspelling"} or
#'   \code{"phantom"} that have a non-\code{NA} suggestion. Genus columns
#'   detected by \code{\link{taxon_column}} are updated automatically for
#'   corrected rows by deriving the genus from the first word of the
#'   corrected binomial. Default is \code{FALSE}.
#' @param parallel Logical. If \code{TRUE}, passes parallel processing to
#'   the internal \code{\link{taxon_validate}} call. Default is \code{FALSE}.
#' @param max_synonym_depth Integer. Maximum synonym redirect steps passed to
#'   the internal \code{\link{taxon_validate}} call. Default is \code{3}.
#' @param validation_report Optional. A validation report tibble from a prior
#'   \code{\link{taxon_validate}} call (i.e.
#'   \code{attr(result, "validation_report")}). If \code{NULL} (default),
#'   \code{\link{taxon_validate}} is run internally on the first column in
#'   \code{column} and its report is used.
#'
#' @return
#' The input data frame, with names in \code{column} corrected to their
#' canonical form (authorship stripped) where \code{update = TRUE} and
#' corrections were available. A spellcheck report tibble is attached as
#' \code{attr(result, "spellcheck_report")} with columns:
#' \describe{
#'   \item{\code{column}}{Name of the column checked.}
#'   \item{\code{original}}{The original name as it appeared in the data.}
#'   \item{\code{suggestion}}{The suggested canonical correction (authorship
#'     stripped), or \code{NA} if no suggestion is available.}
#'   \item{\code{confidence}}{\code{NA} in the current implementation;
#'     reserved for future use.}
#'   \item{\code{source}}{Source of the suggestion (\code{"taxon_validate"}),
#'     or \code{NA} for names requiring manual review.}
#'   \item{\code{n}}{Number of rows containing the original name.}
#'   \item{\code{status}}{One of \code{"misspelling"} (suggestion available),
#'     \code{"phantom"} (name lacks authorship or publication data with a
#'     suggestion), or \code{"unmatched"} (no match found in any source).}
#' }
#' Only names with issues appear in the report. Names confirmed as valid are
#' not included.
#'
#' @details
#' When \code{validation_report} is \code{NULL}, \code{\link{taxon_validate}}
#' is run internally on the first column in \code{column} only. Passing a
#' pre-computed report via \code{attr(validated, "validation_report")} avoids
#' redundant API calls when \code{\link{taxon_validate}} has already been run.
#'
#' Corrections are matched using \code{match()} on canonical names
#' (authorship stripped from both the input column and the suggestion before
#' comparison). Corrected values are written as canonical names without
#' authorship; use \code{\link{taxon_cite}} to append authorship after
#' correction.
#'
#' When \code{update = TRUE}, genus columns detected by
#' \code{\link{taxon_column}} are updated for corrected rows by extracting
#' the first word of the corrected binomial. This only fires for rows
#' containing valid binomial names and skips the source column itself.
#'
#' Names with status \code{"unmatched"} or phantoms without a suggestion are
#' listed separately in the console output for manual review and appear in
#' the report with \code{NA} in the \code{suggestion} column.
#'
#' @note
#' When \code{validation_report} is \code{NULL}, this function calls
#' \code{\link{taxon_validate}} internally, which queries GBIF and/or ITIS
#' web services and requires an active internet connection with reliable
#' access to those servers. To avoid network dependency, run
#' \code{\link{taxon_validate}} separately on a stable connection first and
#' pass the result via \code{attr(result, "validation_report")} to avoid
#' repeated API calls.
#'
#' Connectivity can be tested before running spellcheck:
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
#' \code{\link{taxon_validate}} for the underlying validation and synonym
#' resolution used to generate correction suggestions,
#'
#' \code{\link{taxon_cleaner}} for standardising name formatting before
#' spellchecking,
#'
#' \code{\link{taxon_column}} for detecting genus columns updated
#' automatically when \code{update = TRUE},
#'
#' \code{\link{taxon_add}} for appending higher taxonomic rank columns after
#' spellchecking,
#'
#' \code{\link{taxon_cite}} for appending authorship after corrections are
#' applied.
#'
#' @examples
#' df <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus")
#' )
#'
#' \dontrun{
#' # Check spelling and report suggestions without applying corrections
#' taxon_spellcheck(df, column = species)
#'
#' # Apply confirmed corrections to the column
#' taxon_spellcheck(df, column = species, update = TRUE)
#'
#' # Pass a pre-computed validation report to avoid re-running taxon_validate
#' validated <- taxon_validate(df, column = species)
#' taxon_spellcheck(df, column = species,
#'                  validation_report = attr(validated, "validation_report"))
#'
#' # Inspect the spellcheck report
#' result <- taxon_spellcheck(df, column = species)
#' attr(result, "spellcheck_report")
#'
#' # Check multiple columns at once
#' df2 <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo"),
#'   genus   = c("Homo", "Panthara")
#' )
#' taxon_spellcheck(df2, column = c(species, genus))
#' }
#'
#' @export






taxon_spellcheck <- function(data, column, source = "both", update = FALSE,
                             parallel = FALSE,
                             max_synonym_depth = 3,
                             validation_report = NULL) {
  
  col_sub   <- substitute(column)
  col_names <- if (is.call(col_sub) && deparse(col_sub[[1]]) == "c") {
    vapply(as.list(col_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(col_sub))
  }
  
  # --- Run taxon_validate internally if no report provided ---
  if (is.null(validation_report)) {
    message("[taxon_spellcheck] no validation_report provided -- running taxon_validate internally")
    data <- do.call(taxon_validate, list(
      data              = data,
      column            = as.name(col_names[1]),
      source            = source,
      parallel          = parallel,
      max_synonym_depth = max_synonym_depth
    ))
    validation_report <- attr(data, "validation_report")
    message("[taxon_spellcheck] taxon_validate complete -- applying corrections")
  }
  
  all_reports <- list()
  
  for (col_name in col_names) {
    
    if (!col_name %in% names(data)) {
      message(sprintf("[taxon_spellcheck] column '%s' not found -- skipped", col_name))
      next
    }
    
    vals           <- as.character(data[[col_name]])
    vals_canonical <- trimws(sub("\\s*\\(.*\\)\\s*$", "", vals))
    
    col_report <- validation_report[validation_report$column == col_name, ]
    
    if (nrow(col_report) == 0) {
      message(sprintf("[taxon_spellcheck] no issues found for column '%s'", col_name))
      all_reports[[col_name]] <- tibble::tibble(
        column     = character(), original   = character(),
        suggestion = character(), confidence = integer(),
        source     = character(), n          = integer(),
        status     = character()
      )
      next
    }
    
    # Names with suggestions from taxon_validate
    has_suggestion <- col_report[
      col_report$status %in% c("misspelling", "phantom") &
        !is.na(col_report$accepted), ]
    
    # Names requiring manual review
    no_suggestion <- col_report[
      col_report$status %in% c("unmatched", "phantom") &
        (is.na(col_report$accepted) | col_report$accepted == ""), ]
    
    if (nrow(has_suggestion) > 0) {
      message(sprintf("[taxon_spellcheck] %d correction(s) identified for column '%s':",
                      nrow(has_suggestion), col_name))
      for (i in seq_len(nrow(has_suggestion))) {
        row <- has_suggestion[i, ]
        canonical_suggestion <- trimws(sub("\\s*\\(.*\\)\\s*$", "", row$accepted))
        message(sprintf("  \"%s\" -> \"%s\" (n = %d, status: %s)",
                        row$original, canonical_suggestion, row$n, row$status))
      }
    }
    
    if (nrow(no_suggestion) > 0) {
      message(sprintf("[taxon_spellcheck] %d name(s) in '%s' require manual review:",
                      nrow(no_suggestion), col_name))
      for (i in seq_len(nrow(no_suggestion)))
        message(sprintf("  \"%s\" (n = %d, status: %s)",
                        no_suggestion$original[i], no_suggestion$n[i],
                        no_suggestion$status[i]))
    }
    
    if (nrow(has_suggestion) == 0 && nrow(no_suggestion) == 0)
      message(sprintf("[taxon_spellcheck] no corrections identified for column '%s'",
                      col_name))
    
    # --- Build spellcheck report for this column ---
    report_rows <- dplyr::bind_rows(
      if (nrow(has_suggestion) > 0) {
        tibble::tibble(
          column     = col_name,
          original   = has_suggestion$original,
          suggestion = trimws(sub("\\s*\\(.*\\)\\s*$", "", has_suggestion$accepted)),
          confidence = NA_integer_,
          source     = "taxon_validate",
          n          = has_suggestion$n,
          status     = has_suggestion$status
        )
      } else tibble::tibble(),
      if (nrow(no_suggestion) > 0) {
        tibble::tibble(
          column     = col_name,
          original   = no_suggestion$original,
          suggestion = NA_character_,
          confidence = NA_integer_,
          source     = NA_character_,
          n          = no_suggestion$n,
          status     = no_suggestion$status
        )
      } else tibble::tibble()
    )
    
    if (nrow(report_rows) == 0) {
      report_rows <- tibble::tibble(
        column     = character(), original   = character(),
        suggestion = character(), confidence = integer(),
        source     = character(), n          = integer(),
        status     = character()
      )
    }
    
    all_reports[[col_name]] <- report_rows
    
    # ============================================================
    # Apply corrections using match() for reliable lookup
    # Both keys and values are canonical only (authorship stripped)
    # ============================================================
    if (update && nrow(has_suggestion) > 0) {
      
      orig_canonical <- trimws(sub("\\s*\\(.*\\)\\s*$", "", has_suggestion$original))
      acc_canonical  <- trimws(sub("\\s*\\(.*\\)\\s*$", "", has_suggestion$accepted))
      
      corrected  <- vals_canonical
      to_correct <- vals_canonical %in% orig_canonical
      
      message(sprintf("[taxon_spellcheck] %d row(s) to correct in '%s'",
                      sum(to_correct), col_name))
      
      idx <- match(vals_canonical[to_correct], orig_canonical)
      corrected[to_correct] <- acc_canonical[idx]
      
      na_introduced <- sum(is.na(corrected[to_correct]))
      if (na_introduced > 0)
        message(sprintf("[taxon_spellcheck] WARNING: %d NA(s) introduced -- check alignment",
                        na_introduced))
      
      data[[col_name]] <- corrected
      message(sprintf("[taxon_spellcheck] %d unique name(s) corrected in '%s' across %d rows",
                      nrow(has_suggestion), col_name, sum(to_correct)))
      
      # --- Update genus column for corrected rows ---
      # Derive genus from first word of corrected binomial
      # Only fires when corrections were applied to binomial names
      if (any(to_correct, na.rm = TRUE)) {
        detected   <- taxon_column(data, output = "list")
        rank_cols  <- unlist(lapply(detected, names))
        genus_cols <- rank_cols[grepl("genus", tolower(rank_cols))]
        genus_cols <- setdiff(genus_cols, col_name)
        
        corrected_canonical <- as.character(data[[col_name]])
        is_binomial         <- grepl("^[A-Z][a-z]+ [a-z]+", corrected_canonical)
        
        for (g_col in genus_cols) {
          if (!g_col %in% names(data)) next
          current     <- as.character(data[[g_col]])
          update_rows <- to_correct & is_binomial
          if (any(update_rows, na.rm = TRUE)) {
            current[update_rows] <- vapply(corrected_canonical[update_rows], function(name) {
              if (is.na(name)) return(NA_character_)
              strsplit(trimws(name), "\\s+")[[1]][1]
            }, character(1))
            data[[g_col]] <- current
            message(sprintf("[taxon_spellcheck] derived '%s' from corrected '%s' for %d row(s)",
                            g_col, col_name, sum(update_rows, na.rm = TRUE)))
          }
        }
      }
      
      
    }
  }
  
  spellcheck_report <- dplyr::bind_rows(all_reports)
  if (nrow(spellcheck_report) == 0) {
    spellcheck_report <- tibble::tibble(
      column     = character(), original   = character(),
      suggestion = character(), confidence = integer(),
      source     = character(), n          = integer(),
      status     = character()
    )
  }
  
  attr(data, "spellcheck_report") <- spellcheck_report
  data
}