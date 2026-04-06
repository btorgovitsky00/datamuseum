# ============================================================
# GBIF
# ============================================================

#' Japan-filtered GBIF Octopodoidea occurrence records
#'
#' @description
#' GBIF Octopodoidea occurrence records filtered to the Japan bounding box
#' (latitude 25--50, longitude 125--150) and standardised to the common
#' column set shared across all \pkg{datamuseum} Japan datasets. Rows with
#' \code{NA} in \code{Source}, \code{Family}, \code{Genus}, \code{SciName},
#' or \code{Year} are removed.
#'
#' @format A data frame with 798 rows and 12 variables:
#' \describe{
#'   \item{SciName}{Scientific name as recorded in GBIF, taken directly
#'     from the \code{species} field. Trailing \code{NA} strings removed.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record, from \code{year}.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country code, from \code{countryCode}.}
#'   \item{Prefecture}{State or province, from \code{stateProvince}.}
#'   \item{Precise Location}{Locality description, from \code{locality}.}
#'   \item{Source}{Institution code, from \code{institutionCode}.}
#'   \item{catalogNumber}{Museum lot identification code. Used for duplicate
#'     detection in \code{\link{museum}} via \code{\link{deduplicate}}.}
#'   \item{individualCount}{Specimen count per lot. Used for row expansion
#'     in \code{\link{museum}} via \code{\link{duplicate}}.}
#' }
#'
#' @details
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files in the package data repository. Note that those files
#' contain non-ASCII characters in locality and collector name fields,
#' reflecting the international scope of GBIF occurrence records.
#'
#' @source
#' Derived from the raw GBIF occurrence download. Full source CSVs
#' (raw, trimmed, and Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Global Biodiversity Information Facility (GBIF).
#' GBIF.org (30 March 2026) GBIF Occurrence Download.
#' \url{https://www.gbif.org}
#' \doi{10.15468/dl.2379hj}
#'
#' @seealso
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' \code{\link{museum}} for the combined dataset including these records.
"GBIF_Japan"


# ============================================================
# InvBase
# ============================================================

#' Japan-filtered InvBase Octopodoidea occurrence records
#'
#' @description
#' InvBase Octopodoidea occurrence records filtered to the Japan bounding box
#' (latitude 25--50, longitude 125--150) and standardised to the common
#' column set shared across all \pkg{datamuseum} Japan datasets.
#' \code{SciName} is constructed by combining \code{Genus} and
#' \code{specificEpithet} as no combined name field is present in the source.
#' Rows with \code{NA} in \code{Source}, \code{Family}, \code{Genus},
#' \code{specificEpithet}, or \code{Year} are removed.
#'
#' @format A data frame with 43 rows and 12 variables:
#' \describe{
#'   \item{SciName}{Scientific name constructed from \code{Genus} and
#'     \code{specificEpithet}. Trailing \code{NA} strings removed.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record, from \code{year}.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country name, from \code{country}.}
#'   \item{Prefecture}{State or province, from \code{stateProvince}.}
#'   \item{Precise Location}{County field, from \code{county}.}
#'   \item{Source}{Institution code, from \code{institutionCode}.}
#'   \item{catalogNumber}{Museum lot identification code. Used for duplicate
#'     detection in \code{\link{museum}} via \code{\link{deduplicate}}.}
#'   \item{individualCount}{Specimen count per lot. Used for row expansion
#'     in \code{\link{museum}} via \code{\link{duplicate}}.}
#' }
#'
#' @source
#' Derived from the raw InvBase occurrence download. Full source CSVs
#' (raw, trimmed, and Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Invert-E-Base.
#' Downloaded 30 March 2026. \url{https://invertebase.org}
#'
#' @seealso
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' \code{\link{museum}} for the combined dataset including these records.
"InvBase_Japan"


# ============================================================
# BISMAL
# ============================================================

#' Japan-filtered BISMAL Octopodoidea occurrence records
#'
#' @description
#' BISMAL Octopodoidea occurrence records filtered to the Japan bounding box
#' (latitude 25--50, longitude 125--150) and standardised to the common
#' column set shared across all \pkg{datamuseum} Japan datasets.
#' \code{SciName} is constructed by combining \code{Genus} and
#' \code{specificEpithet} as no combined name field is present in the source.
#' Rows with \code{NA} in \code{Source}, \code{Family}, \code{Genus},
#' \code{specificEpithet}, or \code{Year} are removed.
#'
#' @format A data frame with 473 rows and 12 variables:
#' \describe{
#'   \item{SciName}{Scientific name constructed from \code{Genus} and
#'     \code{specificEpithet}. Trailing \code{NA} strings removed.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record, from \code{year}.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country name, from \code{country}.}
#'   \item{Prefecture}{State or province, from \code{stateProvince}.}
#'   \item{Precise Location}{Locality description, from \code{locality}.}
#'   \item{Source}{Institution code, from \code{institutionCode}.}
#'   \item{catalogNumber}{Museum lot identification code. Used for duplicate
#'     detection in \code{\link{museum}} via \code{\link{deduplicate}}.}
#'   \item{individualCount}{Specimen count per lot. Used for row expansion
#'     in \code{\link{museum}} via \code{\link{duplicate}}.}
#' }
#'
#' @source
#' Derived from the raw BISMAL occurrence download. Full source CSVs
#' (raw, trimmed, and Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Biological Information System for Marine Life (BISMAL).
#' Downloaded 30 March 2026. \url{https://bismal.nisc.go.jp}
#'
#' @seealso
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' \code{\link{museum}} for the combined dataset including these records.
"BISMAL_Japan"


# ============================================================
# OBIS
# ============================================================

#' Japan-filtered OBIS Octopodoidea occurrence records
#'
#' @description
#' OBIS Octopodoidea occurrence records filtered to the Japan bounding box
#' (latitude 25--50, longitude 125--150) and standardised to the common
#' column set shared across all \pkg{datamuseum} Japan datasets.
#' \code{SciName} is taken directly from the \code{species} field. Rows with
#' \code{NA} in \code{Source}, \code{Family}, \code{Genus}, \code{SciName},
#' or \code{Year} are removed.
#'
#' @format A data frame with 668 rows and 12 variables:
#' \describe{
#'   \item{SciName}{Scientific name taken directly from the \code{species}
#'     field. Trailing \code{NA} strings removed.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record, from \code{date_year}. Note
#'     this field differs from all other sources which use \code{year}.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country name, from \code{country}.}
#'   \item{Prefecture}{State or province, from \code{stateProvince}.}
#'   \item{Precise Location}{Locality description, from \code{locality}.}
#'   \item{Source}{Institution code, from \code{institutionCode}.}
#'   \item{catalogNumber}{Museum lot identification code. Used for duplicate
#'     detection in \code{\link{museum}} via \code{\link{deduplicate}}.}
#'   \item{individualCount}{Specimen count per lot. Used for row expansion
#'     in \code{\link{museum}} via \code{\link{duplicate}}.}
#' }
#'
#' @details
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files in the package data repository. Note that those files
#' contain non-ASCII characters in locality and collector name fields,
#' reflecting the international scope of OBIS occurrence records.
#'
#' @source
#' Derived from the raw OBIS occurrence download. Full source CSVs
#' (raw, trimmed, and Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Ocean Biodiversity Information System (OBIS).
#' Downloaded 30 March 2026. \url{https://obis.org}
#'
#' @seealso
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' \code{\link{museum}} for the combined dataset including these records.
"OBIS_Japan"


# ============================================================
# NSMT
# ============================================================

#' Japan-filtered NSMT Octopodoidea occurrence records
#'
#' @description
#' NSMT Octopodoidea occurrence records filtered to the Japan bounding box
#' (latitude 25--50, longitude 125--150) and standardised to the common
#' column set shared across all \pkg{datamuseum} Japan datasets. Unlike other
#' sources, coordinate columns were already named \code{Latitude} and
#' \code{Longitude} in the raw data and required no renaming. \code{SciName}
#' is constructed from \code{Genus}, \code{Species}, and \code{Subspecies},
#' with trailing \code{NA} strings removed to handle records without a
#' subspecies. This is the only source to incorporate a subspecies component
#' in \code{SciName}. No rows were removed by the \code{NA} filter, giving
#' the highest retention rate of all five sources at 79.9\% of raw records.
#'
#' @format A data frame with 695 rows and 12 variables:
#' \describe{
#'   \item{SciName}{Scientific name constructed from \code{Genus},
#'     \code{Species}, and \code{Subspecies} where present. Trailing
#'     \code{NA} strings removed.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.
#'     Already named \code{Latitude} in the raw data.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.
#'     Already named \code{Longitude} in the raw data.}
#'   \item{Country}{Country name.}
#'   \item{Prefecture}{Region, from \code{Region}.}
#'   \item{Precise Location}{Locality description, from \code{Previse.loc.}
#'     — note this reflects a typographic irregularity in the original NSMT
#'     data.}
#'   \item{Source}{Museum group abbreviation, from \code{Group.Abb.}.}
#'   \item{catalogNumber}{Museum lot identification code. Used for duplicate
#'     detection in \code{\link{museum}} via \code{\link{deduplicate}}.}
#'   \item{individualCount}{Specimen count per lot. Used for row expansion
#'     in \code{\link{museum}} via \code{\link{duplicate}}.}
#' }
#'
#' @source
#' Derived from data obtained directly from the National Museum of Nature
#' and Science, Japan. Full source CSVs (raw, trimmed, and Japan-filtered)
#' are available at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' National Museum of Nature and Science, Japan (NSMT).
#' Data obtained directly from the museum, early 2024.
#' \url{https://www.kahaku.go.jp}
#'
#' @seealso
#' The raw and trimmed intermediate versions of this dataset are available
#' as CSV files at \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' \code{\link{museum}} for the combined dataset including these records.
"NSMT_Japan"


# ============================================================
# Combined Japan Datasets
# ============================================================

#' Combined Japan Octopodoidea occurrence records
#'
#' @description
#' Combined Octopodoidea occurrence records for Japan produced by merging the
#' five Japan-filtered source datasets (\code{\link{GBIF_Japan}},
#' \code{\link{InvBase_Japan}}, \code{\link{BISMAL_Japan}},
#' \code{\link{OBIS_Japan}}, and \code{\link{NSMT_Japan}}) via \code{rbind}.
#' Duplicate records are removed using \code{\link{deduplicate}} on the
#' \code{catalogNumber} field, and individual-level records are reconstructed
#' from aggregated specimen counts using \code{\link{duplicate}} on the
#' \code{individualCount} field. See \code{\link{museum_taxon}} for the
#' taxonomically validated and enriched version.
#'
#' @format A data frame with 2,633 rows and 13 variables:
#' \describe{
#'   \item{SciName}{Scientific name as recorded in the source dataset.}
#'   \item{Genus}{Genus name.}
#'   \item{Family}{Family name.}
#'   \item{Year}{Year of occurrence record.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country name or code as recorded in the source dataset.}
#'   \item{Prefecture}{State, province, or region as recorded in the source
#'     dataset.}
#'   \item{Precise Location}{Locality description as recorded in the source
#'     dataset.}
#'   \item{Source}{Institution code or group abbreviation identifying the
#'     collecting institution.}
#'   \item{Data Frame}{Character. Identifies the source dataset for each row.
#'     One of \code{"GBIF"}, \code{"InvBase"}, \code{"BISMAL"},
#'     \code{"OBIS"}, or \code{"NSMT"}.}
#'   \item{catalogNumber}{Museum lot identification code used for duplicate
#'     detection. Rows with \code{NA} in this field were removed during
#'     deduplication.}
#'   \item{individualCount}{Specimen count per lot. Used to expand rows via
#'     \code{\link{duplicate}} to reconstruct individual-level records.}
#' }
#'
#' @details
#' Processing proceeds in the following steps:
#' \enumerate{
#'   \item The five Japan-filtered datasets are combined via \code{rbind}
#'     with a \code{Data Frame} column added to identify the source of each
#'     row, producing 2,707 observations.
#'   \item \code{\link{deduplicate}} is applied on \code{catalogNumber} with
#'     \code{drop_na = TRUE}, removing 608 rows with missing
#'     \code{catalogNumber} and 143 duplicate rows, leaving 1,956
#'     observations. Duplicate records are accessible via
#'     \code{attr(museum, "duplicates")}.
#'   \item \code{\link{duplicate}} is applied on \code{individualCount} to
#'     expand aggregated specimen counts to individual-level records,
#'     increasing the row count from 1,956 to 2,633.
#' }
#'
#' @source
#' Derived from \code{\link{GBIF_Japan}}, \code{\link{InvBase_Japan}},
#' \code{\link{BISMAL_Japan}}, \code{\link{OBIS_Japan}}, and
#' \code{\link{NSMT_Japan}}. Full source CSVs (raw, trimmed, and
#' Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Original sources:
#'
#' Global Biodiversity Information Facility (GBIF).
#' GBIF.org (30 March 2026) GBIF Occurrence Download.
#' \url{https://www.gbif.org} \doi{10.15468/dl.2379hj}
#'
#' Invert-E-Base. Downloaded 30 March 2026.
#' \url{https://invertebase.org}
#'
#' Biological Information System for Marine Life (BISMAL).
#' Downloaded 30 March 2026. \url{https://bismal.nisc.go.jp}
#'
#' Ocean Biodiversity Information System (OBIS).
#' Downloaded 30 March 2026. \url{https://obis.org}
#'
#' National Museum of Nature and Science, Japan (NSMT).
#' Data obtained directly from the museum, early 2024.
#' \url{https://www.kahaku.go.jp}
#'
#' @seealso
#' \code{\link{GBIF_Japan}}, \code{\link{InvBase_Japan}},
#' \code{\link{BISMAL_Japan}}, \code{\link{OBIS_Japan}},
#' \code{\link{NSMT_Japan}} for the individual source datasets,
#'
#' \code{\link{deduplicate}} for the deduplication function applied during
#' processing,
#'
#' \code{\link{duplicate}} for the row expansion function applied during
#' processing,
#'
#' \code{\link{museum_taxon}} for the taxonomically validated and enriched
#' version.
"museum"


#' Taxonomically validated and enriched Japan Octopodoidea records
#'
#' @description
#' The combined Japan Octopodoidea dataset (\code{\link{museum}}) after full
#' taxonomic cleaning, validation, synonym resolution, rank enrichment,
#' authorship appending, and italic formatting. Represents the final stage
#' of the \pkg{datamuseum} workflow and is intended for direct use in
#' analysis and visualisation.
#'
#' @format A data frame with 2,222 rows and 20 variables:
#' \describe{
#'   \item{SciName}{Validated scientific name in accepted nomenclature,
#'     canonical form without authorship.}
#'   \item{Genus}{Genus name, updated by \code{\link{taxon_validate}} where
#'     the primary name changed.}
#'   \item{Family}{Family name.}
#'   \item{order}{Taxonomic order, appended by \code{\link{taxon_add}}.}
#'   \item{phylum}{Taxonomic phylum, appended by \code{\link{taxon_add}}.}
#'   \item{Year}{Year of occurrence record.}
#'   \item{Latitude}{Decimal latitude, filtered to \code{[25, 50]}.}
#'   \item{Longitude}{Decimal longitude, filtered to \code{[125, 150]}.}
#'   \item{Country}{Country name or code as recorded in the source dataset.}
#'   \item{Prefecture}{State, province, or region as recorded in the source
#'     dataset.}
#'   \item{Precise Location}{Locality description as recorded in the source
#'     dataset.}
#'   \item{Source}{Institution code or group abbreviation identifying the
#'     collecting institution.}
#'   \item{Data Frame}{Character. Identifies the source dataset for each row.
#'     One of \code{"GBIF"}, \code{"InvBase"}, \code{"BISMAL"},
#'     \code{"OBIS"}, or \code{"NSMT"}.}
#'   \item{catalogNumber}{Museum lot identification code.}
#'   \item{individualCount}{Specimen count per lot.}
#'   \item{Family_cite}{Family name with authorship appended by
#'     \code{\link{taxon_cite}}. \code{Enteroctopodidae} authorship added
#'     manually as it could not be resolved automatically.}
#'   \item{Genus_cite}{Genus name with authorship appended by
#'     \code{\link{taxon_cite}}.}
#'   \item{SciName_cite}{Scientific name with authorship appended by
#'     \code{\link{taxon_cite}}.}
#'   \item{Genus_cite_italic}{Plotmath italic expression for
#'     \code{Genus_cite}, suitable for use in \pkg{ggplot2} via
#'     \code{\link{italicize}}.}
#'   \item{SciName_cite_italic}{Plotmath italic expression for
#'     \code{SciName_cite}, suitable for use in \pkg{ggplot2} via
#'     \code{\link{italicize}}.}
#' }
#'
#' @details
#' Processing proceeds in the following steps from \code{\link{museum}}:
#' \enumerate{
#'   \item \code{\link{taxon_cleaner}} applied to \code{SciName} in place
#'     with \code{drop_na = TRUE}, removing uncertain names and reducing
#'     the dataset from 2,633 to 2,222 observations.
#'   \item \emph{Octopus vulgaris} manually corrected to
#'     \emph{Octopus sinensis} to reflect current accepted taxonomy for
#'     the Pacific form.
#'   \item \code{\link{taxon_validate}} applied to \code{SciName} with
#'     \code{update_related = TRUE} to resolve synonyms and update related
#'     taxonomic columns.
#'   \item \code{\link{taxon_spellcheck}} applied with \code{update = TRUE}
#'     using the pre-computed validation report.
#'   \item \emph{Pinnoctopus} manually corrected to \emph{Callistoctopus}
#'     across all columns — a generic synonym not resolved automatically by
#'     \code{\link{taxon_validate}}.
#'   \item \code{\link{taxon_add}} appends \code{order} and \code{phylum}
#'     with \code{sort = TRUE}.
#'   \item \code{\link{taxon_cite}} appends authorship to \code{Family},
#'     \code{Genus}, and \code{SciName}.
#'   \item \emph{Muusoctopus small in mature} removed as an informal
#'     morphospecies name not representing a valid taxon.
#'   \item \code{Enteroctopodidae} authorship added manually as it could
#'     not be resolved by \code{\link{taxon_cite}}.
#'   \item \code{\link{italicize}} applied to \code{Genus_cite} and
#'     \code{SciName_cite}.
#' }
#'
#' @source
#' Derived from \code{\link{museum}}. Full source CSVs (raw, trimmed, and
#' Japan-filtered) are available at
#' \url{https://github.com/btorgovitsky00/datamuseum}.
#'
#' Original sources:
#'
#' Global Biodiversity Information Facility (GBIF).
#' GBIF.org (30 March 2026) GBIF Occurrence Download.
#' \url{https://www.gbif.org} \doi{10.15468/dl.2379hj}
#'
#' Invert-E-Base. Downloaded 30 March 2026.
#' \url{https://invertebase.org}
#'
#' Biological Information System for Marine Life (BISMAL).
#' Downloaded 30 March 2026. \url{https://bismal.nisc.go.jp}
#'
#' Ocean Biodiversity Information System (OBIS).
#' Downloaded 30 March 2026. \url{https://obis.org}
#'
#' National Museum of Nature and Science, Japan (NSMT).
#' Data obtained directly from the museum, early 2024.
#' \url{https://www.kahaku.go.jp}
#'
#' @seealso
#' \code{\link{museum}} for the combined pre-validation dataset,
#'
#' \code{\link{taxon_cleaner}} for the cleaning function applied during
#' processing,
#'
#' \code{\link{taxon_validate}} for the validation function applied during
#' processing,
#'
#' \code{\link{taxon_spellcheck}} for the spellcheck function applied during
#' processing,
#'
#' \code{\link{taxon_add}} for the rank enrichment function applied during
#' processing,
#'
#' \code{\link{taxon_cite}} for the authorship appending function applied
#' during processing,
#'
#' \code{\link{italicize}} for the italic formatting function applied during
#' processing.
"museum_taxon"