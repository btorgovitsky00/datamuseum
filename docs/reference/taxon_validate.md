# Validate taxonomic names against ITIS and GBIF

Validates taxonomic names in a column against ITIS and/or GBIF, updating
synonyms to accepted canonical names and resolving authorship for
matched names. Validation proceeds in up to five passes: ITIS strict and
synonym matching, ITIS substitution search, GBIF strict matching, GBIF
fuzzy matching, and authorship resolution. Authorship is stored
internally for use by
[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
but is not written to the column — validated columns contain canonical
names only. A validation report is attached to the result as an
attribute.

## Usage

``` r
taxon_validate(
  data,
  column,
  source = "both",
  update_related = FALSE,
  parallel = FALSE,
  max_synonym_depth = 3,
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame.

- column:

  Column name of the taxonomic column to validate, supplied either
  unquoted (`species`) or quoted (`"species"`). Should contain
  scientific names at a consistent rank.

- source:

  Character. Taxonomic reference source. One of `"both"` (default),
  `"gbif"`, or `"itis"`. When `"both"`, ITIS is queried first and GBIF
  is used for names unresolved by ITIS.

- update_related:

  Logical. If `TRUE`, other taxonomic columns detected by
  [`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
  are updated for rows where the primary column name actually changed.
  Genus columns are updated by deriving the genus from the first word of
  the updated binomial; all other related columns are re-validated via
  an additional `resolve_column` pass restricted to matched rows.
  Default is `FALSE`.

- parallel:

  Logical. If `TRUE`, API calls are parallelised using furrr and future
  with up to 4 workers. Default is `FALSE`.

- max_synonym_depth:

  Integer. Maximum number of synonym redirect steps to follow in GBIF
  before accepting the current name. Default is `3`.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in `column` are dropped before
  validation. Default is `FALSE`.

## Value

The input data frame with taxonomic names in `column` updated to
accepted canonical names where matches were found. Authorship is not
written to the column; use
[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
to append authorship after validation. A validation report tibble is
attached as `attr(result, "validation_report")` with columns:

- `column`:

  Name of the column validated.

- `original`:

  The original name as it appeared in the data.

- `accepted`:

  The accepted or suggested name, or `NA` if unresolved.

- `n`:

  Number of rows containing the original name.

- `status`:

  One of `"updated"` (synonym resolved to accepted name),
  `"misspelling"` (fuzzy match suggestion available), `"phantom"` (name
  lacks authorship or publication data), or `"unmatched"` (no match
  found in any source).

Only names that were updated, flagged as misspellings, identified as
phantoms, or left unmatched appear in the report. Confirmed valid names
are not reported.

## Details

Validation proceeds in five sequential passes per column:

1.  **ITIS strict and synonym** — names are looked up directly in ITIS
    via
    [`taxize::get_tsn()`](https://docs.ropensci.org/taxize/reference/get_tsn.html)
    and
    [`taxize::itis_getrecord()`](https://docs.ropensci.org/taxize/reference/itis_getrecord.html);
    synonyms are resolved to their accepted name. Only names matching
    the pattern `"^[A-Z][a-z]+"` without digits or special characters
    are submitted to ITIS.

2.  **ITIS substitution search** — for names unmatched in pass 1, genus
    and epithet substrings are compared against known values in the
    column using edit distance
    ([`adist()`](https://rdrr.io/r/utils/adist.html), threshold \\\leq
    2\\) to suggest corrections.

3.  **GBIF strict** — remaining unmatched names are looked up via
    `rgbif::name_backbone(strict = TRUE)`. Names where the genus lacks
    authorship or publication data in both GBIF and ITIS are flagged as
    phantoms.

4.  **GBIF fuzzy** — names still unmatched are looked up with
    `strict = FALSE`. Fuzzy matches differing from the input are
    reported as misspelling suggestions only and not applied
    automatically.

5.  **Authorship resolution** — all resolved canonical names are
    enriched with authorship via GBIF with ITIS as a fallback.
    Authorship is stored internally and used by
    [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md);
    it is not written to the column.

Results are memoised to disk via memoise and cachem in
`tools::R_user_dir("taxon_add", "cache")`. Repeated calls for the same
names are fast. Only unique non-`NA` values are looked up.

Required packages vary by `source`: rgbif for GBIF, taxize for ITIS, and
furrr and future for parallel execution. Informative errors are raised
if required packages are not installed.

Use
[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
to standardise name formatting before validation, and
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
to inspect related taxonomic columns that can be updated via
`update_related`.

## Note

This function queries external web services (GBIF via rgbif and/or ITIS
via taxize) and requires an active internet connection with reliable
access to those servers. Performance on unstable or restricted
connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
or produce incomplete results. Previously queried names are cached to
disk via memoise at `tools::R_user_dir("taxon_add", "cache")`, so
running on a stable connection first will speed up subsequent calls
regardless of connection quality.

Connectivity can be tested before running validation:

    # Test ITIS connectivity
    taxize::get_tsn("Homo sapiens", accepted = FALSE, verbose = TRUE,
                    messages = TRUE, ask = FALSE)

    # Test GBIF connectivity
    rgbif::name_backbone(name = "Homo sapiens", strict = TRUE)

## See also

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for standardising taxonomic name formatting before validation,

[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
for detecting related taxonomic columns updated by `update_related`,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for correcting misspellings flagged in the validation report,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher rank columns after validation,

[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
for appending authorship after validation.

## Examples

``` r
df <- data.frame(
  species = c("Homo sapiens", "Panthera leo", "Canis lupus familiaris")
)

# \donttest{
if (requireNamespace("rgbif", quietly = TRUE) &&
    requireNamespace("taxize", quietly = TRUE)) {
# Validate against both ITIS and GBIF
taxon_validate(df, column = species)

# Validate using GBIF only
taxon_validate(df, column = species, source = "gbif")

# Update related taxonomic columns for rows where names changed
df2 <- data.frame(
  species = c("Homo sapiens", "Panthera leo"),
  genus   = c("Homo", "Panthera"),
  family  = c("Hominidae", "Felidae")
)
taxon_validate(df2, column = species, update_related = TRUE)

# Inspect the validation report
result <- taxon_validate(df, column = species)
attr(result, "validation_report")

# Pass the report to taxon_spellcheck to correct misspellings
result |>
  taxon_spellcheck(column = species,
                   validation_report = attr(result, "validation_report"),
                   update = TRUE)

# Enable parallel API calls
taxon_validate(df, column = species, parallel = TRUE)
}
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (3 valid name(s))
#> [taxon_validate] ITIS: 1 / 3
#> [taxon_validate] ITIS: 3 / 3
#> [taxon_validate] ITIS: 3 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (3 resolved names)
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 3: GBIF strict (3 names)
#> [taxon_validate] GBIF strict: 1 / 3
#> [taxon_validate] GBIF strict: 3 / 3
#> [taxon_validate] GBIF strict: 1 matched, 1 phantom, 1 unmatched
#> [taxon_validate] pass 4: GBIF fuzzy (1 names)
#> [taxon_validate] GBIF fuzzy: 1 / 1
#> [taxon_validate] pass 5: authorship lookup (1 resolved names)
#> [taxon_validate] phantom: "Panthera leo" (n = 1) -- lacks authorship/publication data.
#> [taxon_validate] unmatched: "Canis lupus familiaris" (n = 1)
#> [taxon_validate] column 'species' detected rank: species -- 2 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (2 valid name(s))
#> [taxon_validate] ITIS: 1 / 2
#> [taxon_validate] ITIS: 2 / 2
#> [taxon_validate] ITIS: 2 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (2 resolved names)
#> [taxon_validate] updating 2 related column(s): family, genus
#> [taxon_validate] column 'family' detected rank: family -- 2 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (2 valid name(s))
#> [taxon_validate] ITIS: 1 / 2
#> [taxon_validate] ITIS: 2 / 2
#> [taxon_validate] ITIS: 2 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (2 resolved names)
#> [taxon_validate] column 'genus' detected rank: genus -- 2 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (2 valid name(s))
#> [taxon_validate] ITIS: 1 / 2
#> [taxon_validate] ITIS: 2 / 2
#> [taxon_validate] ITIS: 2 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (2 resolved names)
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (3 valid name(s))
#> [taxon_validate] ITIS: 1 / 3
#> [taxon_validate] ITIS: 3 / 3
#> [taxon_validate] ITIS: 3 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (3 resolved names)
#> [taxon_spellcheck] no issues found for column 'species'
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (3 valid name(s))
#> Warning: package 'future' was built under R version 4.5.2
#> [taxon_validate] ITIS: 1 / 3
#> Warning: UNRELIABLE VALUE: Future (<unnamed-1>) unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore". [future <unnamed-1> (bcb048e186d713a9a560c2715b292d08-1); on bcb048e186d713a9a560c2715b292d08@TUFGOVITSKY<10872>]
#> Warning: package 'future' was built under R version 4.5.2
#> Warning: UNRELIABLE VALUE: Future (<unnamed-2>) unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore". [future <unnamed-2> (bcb048e186d713a9a560c2715b292d08-2); on bcb048e186d713a9a560c2715b292d08@TUFGOVITSKY<10872>]
#> Warning: package 'future' was built under R version 4.5.2
#> [taxon_validate] ITIS: 3 / 3
#> Warning: UNRELIABLE VALUE: Future (<unnamed-3>) unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore". [future <unnamed-3> (bcb048e186d713a9a560c2715b292d08-3); on bcb048e186d713a9a560c2715b292d08@TUFGOVITSKY<10872>]
#> [taxon_validate] ITIS: 3 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (3 resolved names)
#>                  species
#> 1           Homo sapiens
#> 2           Panthera leo
#> 3 Canis lupus familiaris
# }
```
