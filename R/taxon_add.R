#' Add higher taxonomic rank columns
#'
#' @description
#' Looks up and appends one or more higher taxonomic rank columns to a data
#' frame using GBIF and/or ITIS as reference sources. Intended for use after
#' \code{\link{taxon_validate}} and \code{\link{taxon_spellcheck}} to append
#' ranks not already present in the data frame. Results are cached to disk
#' to speed up repeated calls.
#'
#' @param data A data frame.
#' @param column Column name of the taxonomic column to look up from,
#'   supplied either unquoted (\code{species}) or quoted (\code{"species"}).
#'   Should contain validated scientific names at a consistent rank.
#' @param ranks Rank name or \code{c()} of rank names to add, supplied
#'   either unquoted (\code{family}) or quoted (\code{"family"}).
#'   Supported ranks are: \code{genus}, \code{family}, \code{order},
#'   \code{class}, \code{phylum}, \code{kingdom}. An error is raised for
#'   any unsupported rank.
#' @param source Character. Taxonomic reference source. One of \code{"both"}
#'   (default), \code{"gbif"}, or \code{"itis"}. When \code{"both"}, GBIF
#'   is queried first and ITIS is used as a fallback if no result is returned.
#' @param author_year Logical. If \code{TRUE}, appends authorship and year
#'   to resolved rank names in the format \code{"Genus species (Author,
#'   Year)"}. If authorship is unavailable the canonical name is returned
#'   unchanged. Default is \code{FALSE}.
#' @param sort Logical. If \code{TRUE}, columns are sorted into standard
#'   taxonomic rank order after adding ranks via \code{\link{taxon_sort}}.
#'   If multiple columns are detected for the same rank an error is raised
#'   with guidance to apply \code{\link{taxon_sort}} manually. Default is
#'   \code{FALSE}.
#' @param drop_na Logical. If \code{TRUE}, rows with \code{NA} in
#'   \code{column} are dropped before lookup. Default is \code{FALSE}.
#'
#' @return
#' The input data frame with one new character column appended per entry in
#' \code{ranks}, named by rank (e.g. \code{family}, \code{order}). A report
#' tibble is attached as \code{attr(result, "add_report")} with columns:
#' \describe{
#'   \item{\code{column}}{Name of the source column looked up from.}
#'   \item{\code{name}}{Input name for which the rank could not be resolved.}
#'   \item{\code{missing_rank}}{The rank that could not be resolved for that
#'     name.}
#'   \item{\code{n}}{Number of rows containing that name.}
#' }
#' An empty tibble is attached when all ranks are resolved. A console message
#' per rank reports the number of values resolved and lists unresolved names.
#'
#' @details
#' GBIF is queried via \code{rgbif::name_backbone()} and
#' \code{rgbif::name_usage()}; ITIS is queried via \code{taxize::get_tsn()}
#' and \code{taxize::classification()}. Results are cached to disk using
#' \pkg{memoise} and \pkg{cachem} in
#' \code{tools::R_user_dir("taxon_add", "cache")}, so repeated calls for
#' the same names are fast. Requires \pkg{memoise} and \pkg{cachem};
#' \pkg{rgbif} and/or \pkg{taxize} are required depending on \code{source}.
#'
#' Only unique non-\code{NA} values in \code{column} are looked up, so
#' performance scales with the number of distinct names rather than total
#' rows.
#'
#' When \code{author_year = TRUE}, authorship is resolved via a separate
#' GBIF lookup on the canonical name returned for each rank. If the resolved
#' name with authorship is identical to the canonical name, or produces empty
#' parentheses, the canonical name is returned unchanged.
#'
#' Use \code{\link{taxon_column}} to detect existing taxonomic rank columns
#' before adding new ones, and \code{\link{taxon_sort}} to reorder columns
#' into standard rank order independently of this function.
#'
#' @note
#' This function queries external web services (GBIF via \pkg{rgbif} and/or
#' ITIS via \pkg{taxize}) and requires an active internet connection with
#' reliable access to those servers. Performance on unstable or restricted
#' connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
#' or produce incomplete results. Previously queried names are cached to disk
#' via \pkg{memoise} and \pkg{cachem} at
#' \code{tools::R_user_dir("taxon_add", "cache")}, so running on a stable
#' connection first will speed up subsequent calls regardless of connection
#' quality.
#'
#' Connectivity can be tested before adding ranks:
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
#' \code{\link{taxon_validate}} for validating and resolving synonyms before
#' adding ranks,
#'
#' \code{\link{taxon_spellcheck}} for correcting misspellings before adding
#' ranks,
#'
#' \code{\link{taxon_cite}} for appending authorship and year after adding
#' ranks,
#'
#' \code{\link{taxon_sort}} for sorting columns into standard taxonomic rank
#' order,
#'
#' \code{\link{taxon_column}} for detecting existing taxonomic rank columns
#' before adding new ones.
#'
#' @examples
#' df <- data.frame(
#'   species = c("Homo sapiens", "Panthera leo", "Canis lupus")
#' )
#'
#' \donttest{
#' if (requireNamespace("rgbif", quietly = TRUE) &&
#'     requireNamespace("taxize", quietly = TRUE)) {
#' # Add a single rank
#' taxon_add(df, column = species, ranks = family)
#'
#' # Add multiple ranks at once
#' taxon_add(df, column = species, ranks = c(family, order, class))
#'
#' # Use GBIF only as the source
#' taxon_add(df, column = species, ranks = family, source = "gbif")
#'
#' # Append authorship to resolved rank names
#' taxon_add(df, column = species, ranks = c(family, genus),
#'           author_year = TRUE)
#'
#' # Add ranks and sort into standard taxonomic order
#' taxon_add(df, column = species, ranks = c(family, order, class),
#'           sort = TRUE)
#'
#' # Inspect names where ranks could not be resolved
#' result <- taxon_add(df, column = species, ranks = c(family, order))
#' attr(result, "add_report")
#' }
#' }
#'
#' @export






taxon_add <- function(data, column, ranks, source = "both",
                      author_year = FALSE, sort = FALSE, drop_na = FALSE) {

  col_name <- gsub('^"|"$', '', deparse(substitute(column)))

  rank_sub <- substitute(ranks)
  ranks <- if (is.call(rank_sub) && deparse(rank_sub[[1]]) == "c") {
    vapply(as.list(rank_sub)[-1], function(x) gsub('^"|"$', '', deparse(x)), character(1))
  } else {
    gsub('^"|"$', '', deparse(rank_sub))
  }

  source <- match.arg(tolower(source), c("gbif", "itis", "both"))

  supported_ranks <- c("genus", "family", "order", "class", "phylum", "kingdom")
  unsupported     <- ranks[!ranks %in% supported_ranks]
  if (length(unsupported) > 0)
    stop(sprintf(
      "[taxon_add] unsupported rank(s): %s. Supported: %s",
      paste(unsupported, collapse = ", "),
      paste(supported_ranks, collapse = ", ")
    ))

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
  if (!requireNamespace("cachem",  quietly = TRUE))
    stop("Package 'cachem' is required. Install with: install.packages('cachem')")

  if (sort) {
    detected   <- taxon_column(data, output = "list")
    duplicates <- Filter(function(x) length(x) > 1, detected)
    if (length(duplicates) > 0) {
      stop(sprintf(
        paste0(
          "[taxon_add] multiple columns detected for the same taxonomic rank -- ",
          "review before sorting: %s\n",
          "Apply taxon_sort() separately based on a manually set series of columns."
        ),
        paste(
          sapply(names(duplicates), function(rank)
            sprintf("%s (%s)", rank, paste(names(duplicates[[rank]]), collapse = ", "))
          ),
          collapse = "; "
        )
      ))
    }
  }

  cache_dir <- tools::R_user_dir("taxon_add", which = "cache")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  safe_get <- function(expr, default = NULL)
    tryCatch(expr, error = function(e) default)

  gbif_author <- if (author_year && source %in% c("gbif", "both")) {
    if (!requireNamespace("rgbif", quietly = TRUE))
      stop("Package 'rgbif' is required. Install with: install.packages('rgbif')")
    gbif_author_cache <- cachem::cache_disk(file.path(cache_dir, "gbif_author"))
    memoise::memoise(function(canonical_name) {
      res <- safe_get(rgbif::name_backbone(name = canonical_name, strict = TRUE))
      if (is.null(res) || nrow(res) == 0 || isTRUE(res$matchType == "NONE"))
        return(canonical_name)
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
      author <- safe_get({
        src <- if (!is.null(resolved)) resolved else res
        val <- src[["authorship"]]
        if (!is.null(val) && length(val) > 0 && !is.na(val[1]) &&
            nchar(trimws(val[1])) > 0)
          gsub("^\\(|\\)$", "", trimws(val[1])) else NULL
      })
      canonical <- safe_get({
        if (!is.null(resolved) && !is.null(resolved$canonicalName) &&
            !is.na(resolved$canonicalName[1])) resolved$canonicalName[1]
        else if (!is.null(res$canonicalName) && !is.na(res$canonicalName[1]))
          res$canonicalName[1]
        else canonical_name
      }, canonical_name)
      if (!is.null(author) && nchar(trimws(author)) > 0)
        paste0(canonical, " (", author, ")")
      else
        canonical
    }, cache = gbif_author_cache)
  }

  gbif_lookup <- if (source %in% c("gbif", "both")) {
    gbif_cache <- cachem::cache_disk(file.path(cache_dir, "gbif"))
    memoise::memoise(function(name) {
      res <- safe_get(rgbif::name_backbone(name = name, strict = TRUE))
      if (is.null(res) || nrow(res) == 0 || isTRUE(res$matchType == "NONE"))
        return(NULL)
      usage_key <- safe_get({
        v <- res[["usageKey"]]
        if (!is.null(v) && length(v) > 0 && !is.na(v[1])) v[1] else NULL
      })
      parents <- if (!is.null(usage_key)) {
        safe_get(rgbif::name_usage(key = usage_key, data = "parents")$data)
      } else NULL
      list(backbone = as.list(res), parents = parents)
    }, cache = gbif_cache)
  }

  itis_lookup <- if (source %in% c("itis", "both")) {
    itis_cache <- cachem::cache_disk(file.path(cache_dir, "itis"))
    memoise::memoise(function(name) {
      tsn <- safe_get(suppressMessages(suppressWarnings(
        taxize::get_tsn(name, accepted = FALSE, verbose = FALSE,
                        messages = FALSE, ask = FALSE)
      )))
      if (is.null(tsn) || is.na(tsn[[1]])) return(NULL)
      safe_get(suppressMessages(
        taxize::classification(tsn[[1]], db = "itis", verbose = FALSE)
      ))
    }, cache = itis_cache)
  }

  resolve_rank <- function(name, rank) {

    canonical_val <- NULL

    if (!is.null(gbif_lookup)) {
      res <- gbif_lookup(name)
      if (!is.null(res)) {
        val <- safe_get({
          v <- res$backbone[[rank]]
          if (!is.null(v) && length(v) > 0 && !is.na(v[1])) v[1] else NULL
        })
        if (!is.null(val)) {
          canonical_val <- val
        } else {
          parents <- res$parents
          if (!is.null(parents) && is.data.frame(parents) &&
              "rank" %in% names(parents)) {
            match_row <- parents[tolower(parents$rank) == tolower(rank), ]
            if (nrow(match_row) > 0) {
              val <- safe_get(
                if (!is.null(match_row$canonicalName) &&
                    !is.na(match_row$canonicalName[1]))
                  match_row$canonicalName[1]
                else if (!is.null(match_row$scientificName) &&
                         !is.na(match_row$scientificName[1]))
                  match_row$scientificName[1]
                else NULL
              )
              if (!is.null(val)) canonical_val <- val
            }
          }
        }
      }
    }

    if (is.null(canonical_val) && !is.null(itis_lookup)) {
      cls <- itis_lookup(name)
      if (!is.null(cls) && is.list(cls) && length(cls) > 0) {
        cls_df <- cls[[1]]
        if (is.data.frame(cls_df) && "rank" %in% names(cls_df)) {
          match_row <- cls_df[grepl(rank, cls_df$rank, ignore.case = TRUE), ]
          if (nrow(match_row) > 0) canonical_val <- match_row$name[1]
        }
      }
    }

    if (is.null(canonical_val)) return(NA_character_)

    if (author_year && !is.null(gbif_author)) {
      with_author <- safe_get(gbif_author(canonical_val))
      if (!is.null(with_author) &&
          !identical(with_author, canonical_val) &&
          !grepl("\\(\\s*\\)$", with_author)) {
        return(with_author)
      }
    }

    canonical_val
  }

  if (drop_na) {
    keep    <- !is.na(data[[col_name]])
    removed <- sum(!keep)
    data    <- data[keep, , drop = FALSE]
    if (removed > 0)
      message(sprintf("[taxon_add] %d NA row(s) removed from '%s'", removed, col_name))
  }

  vals        <- as.character(data[[col_name]])
  unique_vals <- unique(vals[!is.na(vals)])

  rank_results <- setNames(
    lapply(unique_vals, function(name) {
      setNames(
        lapply(ranks, function(rank) resolve_rank(name, rank)),
        ranks
      )
    }),
    unique_vals
  )

  # --- Build report: names where rank could not be resolved ---
  all_reports <- list()

  for (rank in ranks) {
    col_vals <- vapply(vals, function(name) {
      if (is.na(name)) return(NA_character_)
      val <- rank_results[[name]][[rank]]
      if (is.null(val)) NA_character_ else val
    }, character(1))

    data[[rank]] <- col_vals

    resolved_n   <- sum(!is.na(col_vals))
    unresolved_n <- sum(is.na(col_vals) & !is.na(vals))
    message(sprintf("[taxon_add] added column '%s' (%d / %d values resolved)",
                    rank, resolved_n, length(col_vals)))

    # Names with no resolved value for this rank
    no_result <- unique_vals[vapply(unique_vals, function(name) {
      val <- rank_results[[name]][[rank]]
      is.null(val) || is.na(val)
    }, logical(1))]

    if (length(no_result) > 0) {
      report_rows <- tibble::tibble(
        column       = col_name,
        name         = no_result,
        missing_rank = rank,
        n            = vapply(no_result, function(nm)
          as.integer(sum(vals == nm, na.rm = TRUE)), integer(1))
      )
      message(sprintf("[taxon_add] %d name(s) unresolved for rank '%s':",
                      length(no_result), rank))
      for (i in seq_len(nrow(report_rows)))
        message(sprintf("  \"%s\" (n = %d)", report_rows$name[i], report_rows$n[i]))
    } else {
      report_rows <- tibble::tibble(
        column = character(), name = character(),
        missing_rank = character(), n = integer()
      )
    }

    all_reports[[rank]] <- report_rows
  }

  add_report <- dplyr::bind_rows(all_reports)
  if (nrow(add_report) == 0) {
    add_report <- tibble::tibble(
      column = character(), name = character(),
      missing_rank = character(), n = integer()
    )
  }

  if (sort) data <- taxon_sort(data)

  attr(data, "add_report") <- add_report
  data
}
