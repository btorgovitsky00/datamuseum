# Check and correct taxonomic name spelling

Identifies and optionally corrects misspelled taxonomic names using
suggestions from a prior
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
report, or by running
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
internally if no report is provided. Names flagged as misspellings or
phantoms with available suggestions are reported and optionally applied;
names with no suggestion are flagged for manual review. When corrections
are applied, genus columns detected by
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
are updated automatically from the corrected binomial. A spellcheck
report is attached to the result as an attribute.

## Usage

``` r
taxon_spellcheck(
  data,
  column,
  source = "both",
  update = FALSE,
  parallel = FALSE,
  max_synonym_depth = 3,
  validation_report = NULL
)
```

## Arguments

- data:

  A data frame.

- column:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to check, supplied either unquoted (`species`) or quoted
  (`"species"`).

- source:

  Character. Taxonomic reference source passed to the internal
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  call if `validation_report` is `NULL`. One of `"both"` (default),
  `"gbif"`, or `"itis"`.

- update:

  Logical. If `TRUE`, confirmed corrections are applied to each column
  in place for names with status `"misspelling"` or `"phantom"` that
  have a non-`NA` suggestion. Genus columns detected by
  [`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
  are updated automatically for corrected rows by deriving the genus
  from the first word of the corrected binomial. Default is `FALSE`.

- parallel:

  Logical. If `TRUE`, passes parallel processing to the internal
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  call. Default is `FALSE`.

- max_synonym_depth:

  Integer. Maximum synonym redirect steps passed to the internal
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  call. Default is `3`.

- validation_report:

  Optional. A validation report tibble from a prior
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  call (i.e. `attr(result, "validation_report")`). If `NULL` (default),
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  is run internally on the first column in `column` and its report is
  used.

## Value

The input data frame, with names in `column` corrected to their
canonical form (authorship stripped) where `update = TRUE` and
corrections were available. A spellcheck report tibble is attached as
`attr(result, "spellcheck_report")` with columns:

- `column`:

  Name of the column checked.

- `original`:

  The original name as it appeared in the data.

- `suggestion`:

  The suggested canonical correction (authorship stripped), or `NA` if
  no suggestion is available.

- `confidence`:

  `NA` in the current implementation; reserved for future use.

- `source`:

  Source of the suggestion (`"taxon_validate"`), or `NA` for names
  requiring manual review.

- `n`:

  Number of rows containing the original name.

- `status`:

  One of `"misspelling"` (suggestion available), `"phantom"` (name lacks
  authorship or publication data with a suggestion), or `"unmatched"`
  (no match found in any source).

Only names with issues appear in the report. Names confirmed as valid
are not included.

## Details

When `validation_report` is `NULL`,
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
is run internally on the first column in `column` only. Passing a
pre-computed report via `attr(validated, "validation_report")` avoids
redundant API calls when
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
has already been run.

Corrections are matched using
[`match()`](https://rdrr.io/r/base/match.html) on canonical names
(authorship stripped from both the input column and the suggestion
before comparison). Corrected values are written as canonical names
without authorship; use
[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
to append authorship after correction.

When `update = TRUE`, genus columns detected by
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
are updated for corrected rows by extracting the first word of the
corrected binomial. This only fires for rows containing valid binomial
names and skips the source column itself.

Names with status `"unmatched"` or phantoms without a suggestion are
listed separately in the console output for manual review and appear in
the report with `NA` in the `suggestion` column.

## Note

When `validation_report` is `NULL`, this function calls
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
internally, which queries GBIF and/or ITIS web services and requires an
active internet connection with reliable access to those servers. To
avoid network dependency, run
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
separately on a stable connection first and pass the result via
`attr(result, "validation_report")` to avoid repeated API calls.

Connectivity can be tested before running spellcheck:

    # Test ITIS connectivity
    taxize::get_tsn("Homo sapiens", accepted = FALSE, verbose = TRUE,
                    messages = TRUE, ask = FALSE)

    # Test GBIF connectivity
    rgbif::name_backbone(name = "Homo sapiens", strict = TRUE)

## See also

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for the underlying validation and synonym resolution used to generate
correction suggestions,

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for standardising name formatting before spellchecking,

[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
for detecting genus columns updated automatically when `update = TRUE`,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns after spellchecking,

[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
for appending authorship after corrections are applied.

## Examples

``` r
df <- data.frame(
  species = c("Homo sapiens", "Panthera leo", "Canis lupus")
)

if (FALSE) { # \dontrun{
# Check spelling and report suggestions without applying corrections
taxon_spellcheck(df, column = species)

# Apply confirmed corrections to the column
taxon_spellcheck(df, column = species, update = TRUE)

# Pass a pre-computed validation report to avoid re-running taxon_validate
validated <- taxon_validate(df, column = species)
taxon_spellcheck(df, column = species,
                 validation_report = attr(validated, "validation_report"))

# Inspect the spellcheck report
result <- taxon_spellcheck(df, column = species)
attr(result, "spellcheck_report")

# Check multiple columns at once
df2 <- data.frame(
  species = c("Homo sapiens", "Panthera leo"),
  genus   = c("Homo", "Panthara")
)
taxon_spellcheck(df2, column = c(species, genus))
} # }
```
