#' Validate taxonomic names against ITIS and GBIF
#'
#' @description
#' Validates taxonomic names in a column against ITIS and/or GBIF, updating
#' synonyms to accepted canonical names and resolving authorship for matched
#' names. Validation proceeds in up to five passes: ITIS strict and synonym
#' matching, ITIS substitution search, GBIF strict matching, GBIF fuzzy
#' matching, and authorship resolution. Authorship is stored internally for
#' use by \code{\link{taxon_cite}} but is not written to the column —
#' validated columns contain canonical names only. A validation report is
#' attached to the result as an attribute.
#'
#' @param data A data frame.
#' @param column Column name of the taxonomic column to validate, supplied
#'   either unquoted (\code{species}) or quoted (\code{"species"}). Should
#'   contain scientific names at a consistent rank.
#' @param source Character. Taxonomic reference source. One of \code{"both"}
#'   (default), \code{"gbif"}, or \code{"itis"}. When \code{"both"}, ITIS is
#'   queried first and GBIF is used for names unresolved by ITIS.
#' @param update_related Logical. If \code{TRUE}, other taxonomic columns
#'   detected by \code{\link{taxon_column}} are updated for rows where the
#'   primary column name actually changed. Genus columns are updated by
#'   deriving the genus from the first word of the updated binomial; all
#'   other related columns are re-validated via an additional
#'   \code{resolve_column} pass restricted to matched rows. Default is
#'   \code{FALSE}.
#' @param parallel Logical. If \code{TRUE}, API calls are parallelised using
#'   \pkg{furrr} and \pkg{future} with up to 4 workers. Default is
#'   \code{FALSE}.
#' @param max_synonym_depth Integer. Maximum number of synonym redirect steps
#'   to follow in GBIF before accepting the current name. Default is \code{3}.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in
#'   \code{column} are dropped before validation. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with taxonomic names in \code{column} updated to
#' accepted canonical names where matches were found. Authorship is not
#' written to the column; use \code{\link{taxon_cite}} to append authorship
#' after validation. A validation report tibble is attached as
#' \code{attr(result, "validation_report")} with columns:
#' \describe{
#'   \item{\code{column}}{Name of the column validated.}
#'   \item{\code{original}}{The original name as it appeared in the data.}
#'   \item{\code{accepted}}{The accepted or suggested name, or \code{NA} if
#'     unresolved.}
#'   \item{\code{n}}{Number of rows containing the original name.}
#'   \item{\code{status}}{One of \code{"updated"} (synonym resolved to
#'     accepted name), \code{"misspelling"} (fuzzy match suggestion
#'     available), \code{"phantom"} (name lacks authorship or publication
#'     data), or \code{"unmatched"} (no match found in any source).}
#' }
#' Only names that were updated, flagged as misspellings, identified as
#' phantoms, or left unmatched appear in the report. Confirmed valid names
#' are not reported.
#'
#' @details
#' Validation proceeds in five sequential passes per column:
#' \enumerate{
#'   \item \strong{ITIS strict and synonym} — names are looked up directly
#'     in ITIS via \code{taxize::get_tsn()} and \code{taxize::itis_getrecord()};
#'     synonyms are resolved to their accepted name. Only names matching the
#'     pattern \code{"^[A-Z][a-z]+"} without digits or special characters are
#'     submitted to ITIS.
#'   \item \strong{ITIS substitution search} — for names unmatched in pass 1,
#'     genus and epithet substrings are compared against known values in the
#'     column using edit distance (\code{adist()}, threshold \eqn{\leq 2}) to
#'     suggest corrections.
#'   \item \strong{GBIF strict} — remaining unmatched names are looked up via
#'     \code{rgbif::name_backbone(strict = TRUE)}. Names where the genus lacks
#'     authorship or publication data in both GBIF and ITIS are flagged as
#'     phantoms.
#'   \item \strong{GBIF fuzzy} — names still unmatched are looked up with
#'     \code{strict = FALSE}. Fuzzy matches differing from the input are
#'     reported as misspelling suggestions only and not applied automatically.
#'   \item \strong{Authorship resolution} — all resolved canonical names are
#'     enriched with authorship via GBIF with ITIS as a fallback. Authorship
#'     is stored internally and used by \code{\link{taxon_cite}}; it is not
#'     written to the column.
#' }
#'
#' Results are memoised to disk via \pkg{memoise} and \pkg{cachem} in
#' \code{tools::R_user_dir("taxon_add", "cache")}. Repeated calls for the
#' same names are fast. Only unique non-\code{NA} values are looked up.
#'
#' Required packages vary by \code{source}: \pkg{rgbif} for GBIF,
#' \pkg{taxize} for ITIS, and \pkg{furrr} and \pkg{future} for parallel
#' execution. Informative errors are raised if required packages are not
#' installed.
#'
#' Use \code{\link{taxon_cleaner}} to standardise name formatting before
#' validation, and \code{\link{taxon_column}} to inspect related taxonomic
#' columns that can be updated via \code{update_related}.
#'
#' @note
#' This function queries external web services (GBIF via \pkg{rgbif} and/or
#' ITIS via \pkg{taxize}) and requires an active internet connection with
#' reliable access to those servers. Performance on unstable or restricted
#' connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
#' or produce incomplete results. Previously queried names are cached to disk
#' via \pkg{memoise} at \code{tools::R_user_dir("taxon_add", "cache")}, so
#' running on a stable connection first will speed up subsequent calls
#' regardless of connection quality.
#'
#' Connectivity can be tested before running validation:
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
#' \code{\link{taxon_cleaner}} for standardising taxonomic name formatting
#' before validation,
#'
#' \code{\link{taxon_column}} for detecting related taxonomic columns updated
#' by \code{update_related},
#'
#' \code{\link{taxon_spellcheck}} for correcting misspellings flagged in the
#' validation report,
#'
#' \code{\link{taxon_add}} for appending higher rank columns after validation,
#'
#' \code{\link{taxon_cite}} for appending authorship after validation.
#'
#' @examples
#' df <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus familiaris")
#' )
#'
#' \dontrun{
#' # Validate against both ITIS and GBIF
#' taxon_validate(df, column = species)
#'
#' # Validate using GBIF only
#' taxon_validate(df, column = species, source = "gbif")
#'
#' # Update related taxonomic columns for rows where names changed
#' df2 <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo"),
#'   genus   = c("Homo", "Panthera"),
#'   family  = c("Hominidae", "Felidae")
#' )
#' taxon_validate(df2, column = species, update_related = TRUE)
#'
#' # Inspect the validation report
#' result <- taxon_validate(df, column = species)
#' attr(result, "validation_report")
#'
#' # Pass the report to taxon_spellcheck to correct misspellings
#' result |>
#'   taxon_spellcheck(column = species,
#'                    validation_report = attr(result, "validation_report"),
#'                    update = TRUE)
#'
#' # Enable parallel API calls
#' taxon_validate(df, column = species, parallel = TRUE)
#' }
#'
#' @export



taxon_validate <- function(data, column, source = "both",
                           update_related = FALSE, parallel = FALSE,
                           max_synonym_depth = 3, drop_na = FALSE) {
  
  col_name <- gsub('^"|"$', '', deparse(substitute(column)))
  source   <- match.arg(tolower(source), c("gbif", "itis", "both"))
  
  if (source %in% c("gbif", "both")) {
    if (!requireNamespace("rgbif",   quietly = TRUE))
      stop("Package 'rgbif' is required. Install with: install.packages('rgbif')")
  }
  if (source %in% c("itis", "both")) {
    if (!requireNamespace("taxize",  quietly = TRUE))
      stop("Package 'taxize' is required. Install with: install.packages('taxize')")
  }
  if (!requireNamespace("memoise", quietly = TRUE))
    stop("Package 'memoise' is required. Install with: install.packages('memoise')")
  if (parallel) {
    if (!requireNamespace("furrr",  quietly = TRUE))
      stop("Package 'furrr' is required. Install with: install.packages('furrr')")
    if (!requireNamespace("future", quietly = TRUE))
      stop("Package 'future' is required. Install with: install.packages('future')")
  }
  
  validation_report <- tibble::tibble(
    column   = character(),
    original = character(),
    accepted = character(),
    n        = integer(),
    status   = character()
  )
  
  rank_map <- c(
    "scientificname" = "species", "species" = "species",
    "genus"          = "genus",   "family"  = "family",
    "order"          = "order",   "class"   = "class",
    "phylum"         = "phylum",  "kingdom" = "kingdom"
  )
  
  is_valid_taxon_name <- function(name) {
    grepl("^[A-Z][a-z]+", name) &&
      !grepl("[0-9]", name) &&
      !grepl("[^a-zA-Z \\-]", name)
  }
  
  safe_get <- function(expr, default = NULL)
    tryCatch(expr, error = function(e) default)
  
  resolve_column <- function(data, col, matched_idx = NULL) {
    
    if (!col %in% names(data)) {
      message(sprintf("[taxon_validate] column '%s' not found -- skipped", col))
      return(list(data = data, matched_idx = matched_idx, report = tibble::tibble()))
    }
    
    if (drop_na) data <- data[!is.na(data[[col]]), ]
    
    vals           <- as.character(data[[col]])
    vals_canonical <- trimws(sub("\\s*\\(.*\\)\\s*$", "", vals))
    unique_vals    <- unique(vals_canonical[!is.na(vals_canonical)])
    
    if (length(vals) == 0 || length(unique_vals) == 0) {
      message(sprintf("[taxon_validate] column '%s' has no non-NA values -- skipped", col))
      return(list(data = data, matched_idx = matched_idx, report = tibble::tibble()))
    }
    
    col_rank           <- taxon_columntype(data, columns = col)[[1]]
    expected_gbif_rank <- if (!is.na(col_rank) && col_rank %in% names(rank_map))
      rank_map[[col_rank]] else NULL
    
    message(sprintf("[taxon_validate] column '%s' detected rank: %s -- %d unique name(s) to process",
                    col, if (is.null(expected_gbif_rank)) "unknown" else expected_gbif_rank,
                    length(unique_vals)))
    
    valid_for_itis <- unique_vals[vapply(unique_vals, is_valid_taxon_name, logical(1))]
    invalid_names  <- setdiff(unique_vals, valid_for_itis)
    if (length(invalid_names) > 0)
      message(sprintf("[taxon_validate] %d name(s) skipped for ITIS (invalid format)",
                      length(invalid_names)))
    
    known_genera <- unique(vapply(unique_vals, function(n) {
      parts <- strsplit(trimws(n), "\\s+")[[1]]
      if (length(parts) >= 1) parts[1] else NA_character_
    }, character(1)))
    known_genera <- known_genera[!is.na(known_genera) & known_genera != "" &
                                   vapply(known_genera, function(g)
                                     !is.na(g) && is_valid_taxon_name(g), logical(1))]
    
    known_epithets <- unique(unlist(lapply(unique_vals, function(n) {
      parts <- strsplit(trimws(n), "\\s+")[[1]]
      if (length(parts) >= 2) parts[length(parts)] else NA_character_
    })))
    known_epithets <- known_epithets[!is.na(known_epithets) & known_epithets != ""]
    
    genus_distance_cache <- if (length(known_genera) > 0) {
      unique_input_genera <- unique(vapply(valid_for_itis, function(n) {
        parts <- strsplit(trimws(n), "\\s+")[[1]]
        if (length(parts) >= 1) parts[1] else NA_character_
      }, character(1)))
      unique_input_genera <- unique_input_genera[!is.na(unique_input_genera)]
      setNames(lapply(unique_input_genera, function(input_genus) {
        distances <- adist(tolower(input_genus), tolower(known_genera))[1, ]
        close_idx <- which(distances > 0 & distances <= 2)
        if (length(close_idx) == 0) return(character(0))
        known_genera[close_idx][order(distances[close_idx])]
      }), unique_input_genera)
    } else list()
    
    gbif_author_lookup <- if (source %in% c("gbif", "both")) {
      memoise::memoise(function(canonical_name) {
        
        if (is.null(canonical_name) || length(canonical_name) == 0 ||
            is.na(canonical_name) || nchar(trimws(canonical_name)) == 0)
          return(NA_character_)
        
        res <- safe_get(rgbif::name_backbone(name = canonical_name, strict = TRUE))
        
        gbif_author    <- NULL
        gbif_canonical <- canonical_name
        
        if (!is.null(res) && nrow(res) > 0 && !isTRUE(res$matchType == "NONE")) {
          
          canonical_check <- safe_get(res$canonicalName[1])
          
          higherrank_mismatch <- isTRUE(res$matchType == "HIGHERRANK") &&
            !is.null(canonical_check) &&
            length(canonical_check) > 0 &&
            !identical(tolower(trimws(canonical_check)), tolower(trimws(canonical_name)))
          
          if (!higherrank_mismatch &&
              !is.null(canonical_check) &&
              length(canonical_check) > 0 &&
              identical(tolower(trimws(canonical_check)), tolower(trimws(canonical_name)))) {
            
            gbif_rank <- safe_get(tolower(res[["rank"]][1]))
            rank_ok   <- is.null(expected_gbif_rank) || is.null(gbif_rank) ||
              gbif_rank == expected_gbif_rank ||
              (expected_gbif_rank == "species" && gbif_rank == "genus")
            
            if (rank_ok) {
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
                  while (steps < max_synonym_depth) {
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
              
              if (!is.null(author_raw) &&
                  length(author_raw) > 0 &&
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
    }
    
    gbif_genus_check <- if (source %in% c("gbif", "both")) {
      memoise::memoise(function(genus_name) {
        res <- safe_get(rgbif::name_backbone(name = genus_name, strict = TRUE))
        if (is.null(res) || nrow(res) == 0 || isTRUE(res$matchType == "NONE"))
          return(TRUE)
        has_authorship <- safe_get({
          val <- res[["authorship"]]
          !is.null(val) && length(val) > 0 && !is.na(val[1]) && nchar(trimws(val[1])) > 0
        }, FALSE)
        if (has_authorship) return(TRUE)
        verify_key <- safe_get({
          v <- res[["usageKey"]]
          if (!is.null(v) && length(v) > 0 && !is.na(v[1])) v[1] else NULL
        })
        if (!is.null(verify_key)) {
          safe_get({
            usage_check <- rgbif::name_usage(key = verify_key)$data
            val <- usage_check[["publishedIn"]]
            !is.null(val) && length(val) > 0 &&
              !is.na(val[1]) && nchar(trimws(val[1])) > 0
          }, TRUE)
        } else FALSE
      })
    }
    
    itis_lookup <- memoise::memoise(function(name) {
      if (!is_valid_taxon_name(name))
        return(list(matched = FALSE, canonical = NA_character_, synonym = FALSE))
      tsn <- safe_get(suppressMessages(suppressWarnings(
        taxize::get_tsn(name, accepted = FALSE, verbose = FALSE,
                        messages = FALSE, ask = FALSE)
      )))
      if (is.null(tsn) || is.na(tsn[[1]]))
        return(list(matched = FALSE, canonical = NA_character_, synonym = FALSE))
      record <- safe_get(suppressMessages(taxize::itis_getrecord(tsn[[1]])))
      if (is.null(record))
        return(list(matched = FALSE, canonical = NA_character_, synonym = FALSE))
      canonical <- safe_get(trimws(record$scientificName$combinedName))
      if (is.null(canonical) || length(canonical) == 0 ||
          is.na(canonical) || nchar(canonical) == 0)
        return(list(matched = FALSE, canonical = NA_character_, synonym = FALSE))
      input_words     <- length(strsplit(trimws(name),      "\\s+")[[1]])
      canonical_words <- length(strsplit(trimws(canonical), "\\s+")[[1]])
      if (canonical_words != input_words)
        return(list(matched = FALSE, canonical = NA_character_, synonym = FALSE))
      list(matched  = TRUE,
           canonical = canonical,
           synonym   = !identical(tolower(trimws(canonical)), tolower(trimws(name))))
    })
    
    itis_epithet_search <- memoise::memoise(function(name) {
      name_parts  <- strsplit(trimws(name), "\\s+")[[1]]
      input_words <- length(name_parts)
      
      if (input_words == 1) {
        if (length(known_genera) == 0) return(NULL)
        distances        <- adist(tolower(name), tolower(known_genera))[1, ]
        close_idx        <- which(distances > 0 & distances <= 2)
        if (length(close_idx) == 0) return(NULL)
        close_candidates <- head(known_genera[close_idx][order(distances[close_idx])], 5)
        for (candidate in close_candidates) {
          tsn <- safe_get(suppressMessages(suppressWarnings(
            taxize::get_tsn(candidate, accepted = FALSE, verbose = FALSE,
                            messages = FALSE, ask = FALSE)
          )))
          if (is.null(tsn) || is.na(tsn[[1]])) next
          record    <- safe_get(suppressMessages(taxize::itis_getrecord(tsn[[1]])))
          if (is.null(record)) next
          canonical <- safe_get(trimws(record$scientificName$combinedName))
          if (is.null(canonical) || length(canonical) == 0 ||
              is.na(canonical) || nchar(canonical) == 0) next
          if (length(strsplit(trimws(canonical), "\\s+")[[1]]) != 1) next
          if (identical(tolower(trimws(canonical)), tolower(name))) next
          return(canonical)
        }
        return(NULL)
      }
      
      input_genus   <- name_parts[1]
      input_epithet <- name_parts[length(name_parts)]
      
      close_genera <- if (!is.null(genus_distance_cache[[input_genus]])) {
        head(genus_distance_cache[[input_genus]], 5)
      } else {
        distances <- adist(tolower(input_genus), tolower(known_genera))[1, ]
        close_idx <- which(distances > 0 & distances <= 2)
        if (length(close_idx) > 0)
          head(known_genera[close_idx][order(distances[close_idx])], 5)
        else character(0)
      }
      
      for (genus in close_genera) {
        candidate <- paste(c(genus, name_parts[-1]), collapse = " ")
        tsn <- safe_get(suppressMessages(suppressWarnings(
          taxize::get_tsn(candidate, accepted = FALSE, verbose = FALSE,
                          messages = FALSE, ask = FALSE)
        )))
        if (is.null(tsn) || is.na(tsn[[1]])) next
        record    <- safe_get(suppressMessages(taxize::itis_getrecord(tsn[[1]])))
        if (is.null(record)) next
        canonical <- safe_get(trimws(record$scientificName$combinedName))
        if (is.null(canonical) || length(canonical) == 0 ||
            is.na(canonical) || nchar(canonical) == 0) next
        canonical_parts <- strsplit(trimws(canonical), "\\s+")[[1]]
        if (length(canonical_parts) != input_words) next
        if (!identical(tolower(canonical_parts[length(canonical_parts)]),
                       tolower(input_epithet))) next
        if (identical(tolower(trimws(canonical)), tolower(trimws(name)))) next
        return(canonical)
      }
      
      epithet_distances <- adist(tolower(input_epithet), tolower(known_epithets))[1, ]
      close_idx         <- which(epithet_distances > 0 & epithet_distances <= 2)
      close_epithets    <- if (length(close_idx) > 0)
        head(known_epithets[close_idx][order(epithet_distances[close_idx])], 5)
      else character(0)
      
      for (epithet in close_epithets) {
        candidate_parts                          <- name_parts
        candidate_parts[length(candidate_parts)] <- epithet
        candidate                                <- paste(candidate_parts, collapse = " ")
        tsn <- safe_get(suppressMessages(suppressWarnings(
          taxize::get_tsn(candidate, accepted = FALSE, verbose = FALSE,
                          messages = FALSE, ask = FALSE)
        )))
        if (is.null(tsn) || is.na(tsn[[1]])) next
        record    <- safe_get(suppressMessages(taxize::itis_getrecord(tsn[[1]])))
        if (is.null(record)) next
        canonical <- safe_get(trimws(record$scientificName$combinedName))
        if (is.null(canonical) || length(canonical) == 0 ||
            is.na(canonical) || nchar(canonical) == 0) next
        canonical_parts <- strsplit(trimws(canonical), "\\s+")[[1]]
        if (length(canonical_parts) != input_words) next
        if (!identical(tolower(canonical_parts[1]), tolower(input_genus))) next
        if (identical(tolower(trimws(canonical)), tolower(trimws(name)))) next
        return(canonical)
      }
      
      NULL
    })
    
    gbif_strict <- if (source %in% c("gbif", "both")) {
      memoise::memoise(function(name) {
        res <- safe_get(rgbif::name_backbone(name = name, strict = TRUE))
        if (is.null(res) || nrow(res) == 0 || isTRUE(res$matchType == "NONE"))
          return(list(matched = FALSE, canonical = NA_character_,
                      usage_key = NULL, reason = "no_match"))
        
        canonical_check <- safe_get(res$canonicalName[1])
        if (is.null(canonical_check) || length(canonical_check) == 0 ||
            !identical(tolower(trimws(canonical_check)), tolower(trimws(name))))
          return(list(matched = FALSE, canonical = NA_character_,
                      usage_key = NULL, reason = "no_match"))
        
        gbif_rank <- safe_get(tolower(res[["rank"]][1]))
        if (!is.null(expected_gbif_rank) && !is.null(gbif_rank) &&
            gbif_rank != expected_gbif_rank)
          return(list(matched = FALSE, canonical = NA_character_,
                      usage_key = NULL, reason = "no_match"))
        
        if (length(strsplit(trimws(canonical_check), "\\s+")[[1]]) > 1) {
          genus_part       <- strsplit(trimws(canonical_check), "\\s+")[[1]][1]
          genus_legitimate <- if (!is.null(gbif_genus_check)) gbif_genus_check(genus_part) else TRUE
          if (!genus_legitimate)
            return(list(matched = FALSE, canonical = NA_character_,
                        usage_key = NULL, reason = "phantom"))
          
          # ITIS genus check only runs when GBIF genus check is suspicious
          # i.e. GBIF accepted the genus but without strong legitimacy signals
          # This catches GBIF misentries like Scaerugus without rejecting
          # valid Indo-Pacific genera absent from ITIS
          if (!genus_legitimate && source == "both" &&
              requireNamespace("taxize", quietly = TRUE)) {
            itis_genus_legitimate <- safe_get({
              tsn <- suppressMessages(suppressWarnings(
                taxize::get_tsn(genus_part, accepted = TRUE, verbose = FALSE,
                                messages = FALSE, ask = FALSE)
              ))
              !is.null(tsn) && !is.na(tsn[[1]])
            }, TRUE)
            if (!itis_genus_legitimate)
              return(list(matched = FALSE, canonical = NA_character_,
                          usage_key = NULL, reason = "phantom"))
          }
        }
        
        has_authorship <- safe_get({
          val <- res[["authorship"]]
          !is.null(val) && length(val) > 0 && !is.na(val[1]) && nchar(trimws(val[1])) > 0
        }, FALSE)
        
        usage_key <- safe_get({
          val <- res[["acceptedUsageKey"]]
          if (!is.null(val) && length(val) > 0 && !is.na(val[1])) val[1] else {
            val2 <- res[["usageKey"]]
            if (!is.null(val2) && length(val2) > 0 && !is.na(val2[1])) val2[1] else NULL
          }
        })
        
        if (!has_authorship) {
          published <- if (!is.null(usage_key)) {
            safe_get({
              usage_check <- rgbif::name_usage(key = usage_key)$data
              val <- usage_check[["publishedIn"]]
              !is.null(val) && length(val) > 0 &&
                !is.na(val[1]) && nchar(trimws(val[1])) > 0
            }, FALSE)
          } else FALSE
          if (!published)
            return(list(matched = FALSE, canonical = NA_character_,
                        usage_key = NULL, reason = "phantom"))
        }
        
        list(matched = TRUE, canonical = canonical_check,
             usage_key = usage_key, reason = "matched")
      })
    }
    
    gbif_fuzzy <- if (source %in% c("gbif", "both")) {
      memoise::memoise(function(name) {
        input_words <- length(strsplit(trimws(name), "\\s+")[[1]])
        res <- safe_get(rgbif::name_backbone(name = name, strict = FALSE))
        if (is.null(res) || nrow(res) == 0 || isTRUE(res$matchType == "NONE"))
          return(NULL)
        canonical_fuzzy <- safe_get(res$canonicalName[1])
        if (is.null(canonical_fuzzy) || length(canonical_fuzzy) == 0) return(NULL)
        if (identical(tolower(trimws(canonical_fuzzy)), tolower(name))) return(NULL)
        if (length(strsplit(trimws(canonical_fuzzy), "\\s+")[[1]]) != input_words) return(NULL)
        gbif_rank <- safe_get(tolower(res[["rank"]][1]))
        if (!is.null(expected_gbif_rank) && !is.null(gbif_rank) &&
            gbif_rank != expected_gbif_rank) return(NULL)
        has_authorship <- safe_get({
          val <- res[["authorship"]]
          !is.null(val) && length(val) > 0 && !is.na(val[1]) && nchar(trimws(val[1])) > 0
        }, FALSE)
        if (!has_authorship) return(NULL)
        canonical_fuzzy
      })
    }
    
    map_fn <- if (parallel) {
      future::plan(future::multisession,
                   workers = min(4, parallel::detectCores() - 1))
      furrr::future_map
    } else {
      lapply
    }
    
    # ============================================================
    # PASS 1 -- ITIS strict + synonym
    # ============================================================
    itis_results         <- setNames(
      lapply(unique_vals, function(x)
        list(matched = FALSE, canonical = NA_character_, synonym = FALSE)),
      unique_vals)
    itis_matched         <- character(0)
    itis_synonym_matched <- character(0)
    
    if (source %in% c("itis", "both") && length(valid_for_itis) > 0) {
      message(sprintf("[taxon_validate] pass 1: ITIS strict + synonym (%d valid name(s))",
                      length(valid_for_itis)))
      if (parallel) future::plan(future::multisession,
                                 workers = min(4, parallel::detectCores() - 1))
      itis_list <- setNames(map_fn(seq_along(valid_for_itis), function(i) {
        name <- valid_for_itis[i]
        if (i == 1 || i %% 25 == 0 || i == length(valid_for_itis))
          message(sprintf("[taxon_validate] ITIS: %d / %d", i, length(valid_for_itis)))
        itis_lookup(name)
      }), valid_for_itis)
      if (parallel) future::plan(future::sequential)
      
      for (name in valid_for_itis)
        itis_results[[name]] <- itis_list[[name]]
      
      itis_matched <- valid_for_itis[vapply(valid_for_itis, function(n)
        isTRUE(itis_results[[n]]$matched) && !isTRUE(itis_results[[n]]$synonym), logical(1))]
      itis_synonym_matched <- valid_for_itis[vapply(valid_for_itis, function(n)
        isTRUE(itis_results[[n]]$matched) && isTRUE(itis_results[[n]]$synonym), logical(1))]
      
      message(sprintf("[taxon_validate] ITIS: %d strict, %d synonym, %d unmatched",
                      length(itis_matched), length(itis_synonym_matched),
                      length(valid_for_itis) - length(itis_matched) -
                        length(itis_synonym_matched)))
    }
    
    itis_all_matched <- c(itis_matched, itis_synonym_matched)
    itis_unmatched   <- setdiff(unique_vals, itis_all_matched)
    
    # ============================================================
    # PASS 2 -- ITIS substitution search
    # ============================================================
    itis_epithet_results <- list()
    epithet_candidates   <- intersect(itis_unmatched, valid_for_itis)
    
    if (source %in% c("itis", "both") && length(epithet_candidates) > 0) {
      message(sprintf("[taxon_validate] pass 2: ITIS substitution (%d name(s))",
                      length(epithet_candidates)))
      if (parallel) future::plan(future::multisession,
                                 workers = min(4, parallel::detectCores() - 1))
      itis_epithet_results <- setNames(map_fn(seq_along(epithet_candidates), function(i) {
        name <- epithet_candidates[i]
        if (i == 1 || i %% 25 == 0 || i == length(epithet_candidates))
          message(sprintf("[taxon_validate] ITIS substitution: %d / %d",
                          i, length(epithet_candidates)))
        itis_epithet_search(name)
      }), epithet_candidates)
      if (parallel) future::plan(future::sequential)
    }
    
    itis_epithet_matched <- names(itis_epithet_results)[vapply(names(itis_epithet_results),
                                                               function(n) !is.null(itis_epithet_results[[n]]), logical(1))]
    still_unmatched <- setdiff(itis_unmatched, itis_epithet_matched)
    
    # ============================================================
    # PASS 3 -- GBIF strict
    # ============================================================
    gbif_strict_results <- list()
    gbif_phantom        <- character(0)
    
    if (source %in% c("gbif", "both") && length(still_unmatched) > 0) {
      message(sprintf("[taxon_validate] pass 3: GBIF strict (%d names)",
                      length(still_unmatched)))
      if (parallel) future::plan(future::multisession,
                                 workers = min(4, parallel::detectCores() - 1))
      gbif_strict_results <- setNames(map_fn(seq_along(still_unmatched), function(i) {
        name <- still_unmatched[i]
        if (i == 1 || i %% 25 == 0 || i == length(still_unmatched))
          message(sprintf("[taxon_validate] GBIF strict: %d / %d",
                          i, length(still_unmatched)))
        gbif_strict(name)
      }), still_unmatched)
      if (parallel) future::plan(future::sequential)
      
      gbif_phantom <- still_unmatched[vapply(still_unmatched, function(n)
        !isTRUE(gbif_strict_results[[n]]$matched) &&
          identical(gbif_strict_results[[n]]$reason, "phantom"), logical(1))]
      
      gbif_strict_matched_n <- sum(vapply(still_unmatched, function(n)
        isTRUE(gbif_strict_results[[n]]$matched), logical(1)))
      message(sprintf("[taxon_validate] GBIF strict: %d matched, %d phantom, %d unmatched",
                      gbif_strict_matched_n, length(gbif_phantom),
                      length(still_unmatched) - gbif_strict_matched_n - length(gbif_phantom)))
    }
    
    gbif_matched   <- names(gbif_strict_results)[vapply(names(gbif_strict_results),
                                                        function(n) isTRUE(gbif_strict_results[[n]]$matched), logical(1))]
    gbif_unmatched <- setdiff(still_unmatched, c(gbif_matched, gbif_phantom))
    
    # ============================================================
    # PASS 4 -- GBIF fuzzy
    # ============================================================
    gbif_fuzzy_results <- list()
    fuzzy_candidates   <- setdiff(gbif_unmatched, gbif_phantom)
    
    if (source %in% c("gbif", "both") && length(fuzzy_candidates) > 0) {
      message(sprintf("[taxon_validate] pass 4: GBIF fuzzy (%d names)",
                      length(fuzzy_candidates)))
      if (parallel) future::plan(future::multisession,
                                 workers = min(4, parallel::detectCores() - 1))
      gbif_fuzzy_results <- setNames(map_fn(seq_along(fuzzy_candidates), function(i) {
        name <- fuzzy_candidates[i]
        if (i == 1 || i %% 25 == 0 || i == length(fuzzy_candidates))
          message(sprintf("[taxon_validate] GBIF fuzzy: %d / %d",
                          i, length(fuzzy_candidates)))
        gbif_fuzzy(name)
      }), fuzzy_candidates)
      if (parallel) future::plan(future::sequential)
    }
    
    gbif_fuzzy_matched <- names(gbif_fuzzy_results)[vapply(names(gbif_fuzzy_results),
                                                           function(n) !is.null(gbif_fuzzy_results[[n]]), logical(1))]
    
    # ============================================================
    # PASS 5 -- authorship lookup (internal use only)
    # Not written to column -- stored in author_map for internal use
    # ============================================================
    resolved_canonicals <- unique(c(
      vapply(itis_matched,         function(n) itis_results[[n]]$canonical,         character(1)),
      vapply(itis_synonym_matched, function(n) itis_results[[n]]$canonical,         character(1)),
      vapply(itis_epithet_matched, function(n) itis_epithet_results[[n]],           character(1)),
      vapply(gbif_matched,         function(n) gbif_strict_results[[n]]$canonical,  character(1)),
      vapply(gbif_fuzzy_matched,   function(n) gbif_fuzzy_results[[n]],             character(1))
    ))
    resolved_canonicals <- resolved_canonicals[
      !is.na(resolved_canonicals) & nchar(resolved_canonicals) > 0]
    
    author_map <- if (source %in% c("gbif", "both") &&
                      length(resolved_canonicals) > 0) {
      message(sprintf("[taxon_validate] pass 5: authorship lookup (%d resolved names)",
                      length(resolved_canonicals)))
      setNames(lapply(resolved_canonicals, function(canonical) {
        result <- if (!is.null(gbif_author_lookup)) gbif_author_lookup(canonical) else canonical
        if (is.null(result) || length(result) == 0) canonical else result
      }), resolved_canonicals)
    } else {
      setNames(as.list(resolved_canonicals), resolved_canonicals)
    }
    
    get_accepted <- function(canonical) {
      if (is.null(canonical) || length(canonical) == 0 || is.na(canonical))
        return(NA_character_)
      result <- author_map[[canonical]]
      if (is.null(result) || length(result) == 0) return(canonical)
      result
    }
    
    # ============================================================
    # Assemble final results
    # ============================================================
    results <- setNames(lapply(unique_vals, function(name) {
      
      if (name %in% itis_matched)
        return(list(matched          = "ITIS",
                    accepted         = get_accepted(itis_results[[name]]$canonical),
                    fuzzy_suggestion = NULL,
                    is_phantom       = FALSE))
      
      if (name %in% itis_synonym_matched)
        return(list(matched          = "ITIS",
                    accepted         = get_accepted(itis_results[[name]]$canonical),
                    fuzzy_suggestion = NULL,
                    is_phantom       = FALSE))
      
      if (name %in% itis_epithet_matched)
        return(list(matched          = NA_character_,
                    accepted         = name,
                    fuzzy_suggestion = get_accepted(itis_epithet_results[[name]]),
                    is_phantom       = FALSE))
      
      if (name %in% gbif_matched)
        return(list(matched          = "GBIF",
                    accepted         = get_accepted(gbif_strict_results[[name]]$canonical),
                    fuzzy_suggestion = NULL,
                    is_phantom       = FALSE))
      
      if (name %in% gbif_fuzzy_matched)
        return(list(matched          = NA_character_,
                    accepted         = name,
                    fuzzy_suggestion = get_accepted(gbif_fuzzy_results[[name]]),
                    is_phantom       = name %in% gbif_phantom))
      
      if (name %in% gbif_phantom)
        return(list(matched          = NA_character_,
                    accepted         = name,
                    fuzzy_suggestion = NULL,
                    is_phantom       = TRUE))
      
      list(matched          = NA_character_,
           accepted         = name,
           fuzzy_suggestion = NULL,
           is_phantom       = FALSE)
      
    }), unique_vals)
    
    # ============================================================
    # Build accepted_vec
    # Canonical names only written to column
    # Full authorship preserved in results for taxon_cite use
    # ============================================================
    is_matched <- vapply(vals_canonical, function(name) {
      if (is.na(name)) return(FALSE)
      !is.na(results[[name]]$matched)
    }, logical(1))
    
    if (!is.null(matched_idx)) {
      if (length(matched_idx) != length(vals_canonical))
        matched_idx <- matched_idx[seq_along(vals_canonical)]
      is_matched <- is_matched & matched_idx
    }
    
    accepted_vec <- vals
    accepted_vec[is_matched] <- vapply(vals_canonical[is_matched], function(name) {
      val <- tryCatch({
        res <- results[[name]]$accepted
        if (is.null(res) || length(res) == 0 || is.na(res)) return(name)
        if (nchar(trimws(res)) == 0) return(name)
        trimws(sub("\\s*\\(.*\\)\\s*$", "", res))
      }, error = function(e) name)
      if (length(val) == 0) name else val
    }, character(1))
    
    data[[col]] <- accepted_vec
    
    # ============================================================
    # Build report
    # ============================================================
    report_rows <- dplyr::bind_rows(Filter(Negate(is.null), lapply(unique_vals, function(name) {
      res <- results[[name]]
      n   <- as.integer(sum(vals_canonical == name, na.rm = TRUE))
      
      if (is.na(res$matched)) {
        status <- if (isTRUE(res$is_phantom) && is.null(res$fuzzy_suggestion)) "phantom"
        else if (!is.null(res$fuzzy_suggestion)) "misspelling"
        else "unmatched"
        return(tibble::tibble(
          column   = col,
          original = name,
          accepted = if (!is.null(res$fuzzy_suggestion) &&
                         length(res$fuzzy_suggestion) > 0)
            res$fuzzy_suggestion else NA_character_,
          n        = n,
          status   = status
        ))
      }
      
      canonical_accepted <- trimws(sub("\\s*\\(.*\\)\\s*$", "", res$accepted))
      is_updated <- !grepl(paste0("^", canonical_accepted), name, ignore.case = TRUE) &&
        !grepl(paste0("^", name), canonical_accepted, ignore.case = TRUE)
      
      if (is_updated)
        return(tibble::tibble(column = col, original = name,
                              accepted = res$accepted, n = n, status = "updated"))
      NULL
    })))
    
    # ============================================================
    # Messages
    # ============================================================
    if (is.null(matched_idx)) {
      for (name in unique_vals) {
        res <- results[[name]]
        
        if (is.na(res$matched)) {
          if (isTRUE(res$is_phantom) && is.null(res$fuzzy_suggestion)) {
            message(sprintf(
              "[taxon_validate] phantom: \"%s\" (n = %d) -- lacks authorship/publication data.",
              name, sum(vals_canonical == name, na.rm = TRUE)))
          } else if (isTRUE(res$is_phantom) && !is.null(res$fuzzy_suggestion)) {
            message(sprintf(
              "[taxon_validate] phantom: \"%s\" (n = %d) -- possible correction: \"%s\"",
              name, sum(vals_canonical == name, na.rm = TRUE), res$fuzzy_suggestion))
          } else if (!is.null(res$fuzzy_suggestion)) {
            message(sprintf(
              "[taxon_validate] possible misspelling: \"%s\" (n = %d) -- did you mean \"%s\"?",
              name, sum(vals_canonical == name, na.rm = TRUE), res$fuzzy_suggestion))
          } else {
            message(sprintf(
              "[taxon_validate] unmatched: \"%s\" (n = %d)",
              name, sum(vals_canonical == name, na.rm = TRUE)))
          }
          next
        }
        
        canonical_accepted <- trimws(sub("\\s*\\(.*\\)\\s*$", "", res$accepted))
        if (!grepl(paste0("^", canonical_accepted), name, ignore.case = TRUE) &&
            !grepl(paste0("^", name), canonical_accepted, ignore.case = TRUE)) {
          n_rows  <- sum(vals_canonical == name, na.rm = TRUE)
          n_final <- sum(accepted_vec == trimws(sub("\\s*\\(.*\\)\\s*$", "",
                                                    res$accepted)), na.rm = TRUE)
          message(sprintf(
            "[taxon_validate] updated: \"%s\" -> \"%s\" (%d updated, final count = %d)",
            name, trimws(sub("\\s*\\(.*\\)\\s*$", "", res$accepted)),
            n_rows, n_final))
        }
      }
    }
    
    list(data = data, matched_idx = is_matched, report = report_rows)
  }
  
  # Capture original values before primary column is updated
  taxon_column_original <- data[[col_name]]
  
  primary_result    <- resolve_column(data, col_name, matched_idx = NULL)
  data              <- primary_result$data
  matched_idx       <- primary_result$matched_idx
  validation_report <- dplyr::bind_rows(validation_report, primary_result$report)
  
  if (update_related && any(matched_idx, na.rm = TRUE)) {
    
    detected     <- taxon_column(data, output = "list")
    rank_cols    <- unlist(lapply(detected, names))
    related_cols <- setdiff(rank_cols, col_name)
    
    if (length(related_cols) > 0) {
      message(sprintf("[taxon_validate] updating %d related column(s): %s",
                      length(related_cols), paste(related_cols, collapse = ", ")))
      
      original_canonical <- trimws(sub("\\s*\\(.*\\)\\s*$", "",
                                       as.character(taxon_column_original)))
      updated_canonical  <- trimws(sub("\\s*\\(.*\\)\\s*$", "",
                                       as.character(data[[col_name]])))
      actually_changed   <- matched_idx &
        !is.na(original_canonical) & !is.na(updated_canonical) &
        (original_canonical != updated_canonical)
      
      for (rel_col in related_cols) {
        if (!rel_col %in% names(data)) next
        
        if (grepl("genus", tolower(rel_col)) && any(actually_changed, na.rm = TRUE)) {
          # Genus: derive directly from first word of updated primary binomial
          current     <- as.character(data[[rel_col]])
          is_binomial <- grepl("^[A-Z][a-z]+ [a-z]+", updated_canonical)
          update_rows <- actually_changed & is_binomial
          if (any(update_rows, na.rm = TRUE)) {
            current[update_rows] <- vapply(updated_canonical[update_rows], function(name) {
              if (is.na(name)) return(NA_character_)
              strsplit(trimws(name), "\\s+")[[1]][1]
            }, character(1))
            data[[rel_col]] <- current
            message(sprintf("[taxon_validate] derived '%s' from '%s' for %d row(s)",
                            rel_col, col_name, sum(update_rows, na.rm = TRUE)))
          }
        } else {
          rel_result        <- resolve_column(data, rel_col, matched_idx = matched_idx)
          data              <- rel_result$data
          validation_report <- dplyr::bind_rows(validation_report, rel_result$report)
        }
      }
    }
  }
  
  attr(data, "validation_report") <- validation_report
  data
}