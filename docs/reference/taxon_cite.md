# Append authorship and year to taxonomic name columns

Appends authorship and year to one or more taxonomic name columns using
GBIF (preferred) and ITIS (fallback) as reference sources. For each
specified column a new `<column>_cite` column is appended containing
names in the format `"Genus species (Author, Year)"`. Intended as the
final step in the
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
-\>
[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
workflow.

## Usage

``` r
taxon_cite(data, columns, source = "both", drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- columns:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to append authorship to, supplied either unquoted (`species`) or
  quoted (`"species"`).

- source:

  Character. Taxonomic reference source. One of `"both"` (default),
  `"gbif"`, or `"itis"`. When `"both"`, GBIF authorship is preferred and
  ITIS is used as a fallback when GBIF returns no valid authorship or a
  malformed result.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in the column are dropped before
  look-up. Default is `FALSE`.

## Value

The input data frame with one additional character column appended per
entry in `columns`, named `<column>_cite`. Rows where authorship cannot
be found retain the original canonical name in the cite column
unchanged. A report tibble is attached as `attr(result, "cite_report")`
with columns:

- `column`:

  Name of the column processed.

- `name`:

  Canonical name for which no authorship was found.

- `n`:

  Number of rows containing that name.

An empty tibble is attached when authorship is found for all names. A
console message per column reports the number of names resolved and
lists any names without authorship.

## Details

Authorship look-up follows the same logic as pass 5 of
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md):

- GBIF `name_backbone` is queried with `strict = TRUE`.

- `HIGHERRANK` results are accepted only when the canonical name matches
  the input exactly.

- Malformed authorship strings starting with a comma or punctuation are
  rejected and treated as missing.

- Synonym chains are followed up to three steps via `name_usage()` to
  reach the accepted name authorship.

- When GBIF has no valid authorship and `source = "both"`, ITIS
  `itis_getrecord` is queried as a fallback.

Authorship is stripped from input values before lookup (parenthetical
suffixes matching `\s*\(.*\)\s*$` are removed), so columns already
containing authorship from a prior
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
call are handled correctly.

Results are memoised for the duration of the session. Only unique
non-`NA` values are looked up, so performance scales with the number of
distinct names rather than total rows.

Requires rgbif for GBIF lookups, taxize for ITIS lookups, and memoise.
Informative errors are raised if required packages are not installed.

## Note

This function queries external web services (GBIF via rgbif and/or ITIS
via taxize) and requires an active internet connection with reliable
access to those servers. Performance on unstable or restricted
connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
or produce incomplete results. Results are memoised for the duration of
the session; running on a stable connection first and retaining the
session will avoid repeated API calls for the same names.

Connectivity can be tested before appending authorship:

    # Test ITIS connectivity
    taxize::get_tsn("Homo sapiens", accepted = FALSE, verbose = TRUE,
                    messages = TRUE, ask = FALSE)

    # Test GBIF connectivity
    rgbif::name_backbone(name = "Homo sapiens", strict = TRUE)

## See also

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for resolving synonyms and validating names before appending authorship,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for correcting misspellings before appending authorship,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns alongside authorship,

[`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
for formatting cited names for ggplot2 display as the final step in the
workflow.

## Examples

``` r
df <- data.frame(
  species = c("Homo sapiens", "Panthera leo", "Canis lupus")
)

# \donttest{
if (requireNamespace("rgbif", quietly = TRUE) &&
    requireNamespace("taxize", quietly = TRUE)) {
# Append authorship to a single column
taxon_cite(df, species)

# Append authorship to multiple columns
df2 <- data.frame(
  genus   = c("Homo", "Panthera"),
  species = c("Homo sapiens", "Panthera leo")
)
taxon_cite(df2, c(genus, species))

# Use GBIF only
taxon_cite(df, species, source = "gbif")

# Inspect names where no authorship was found
result <- taxon_cite(df, species)
attr(result, "cite_report")

# Full workflow
df |>
  taxon_validate(column = species) |>
  taxon_spellcheck(column = species, update = TRUE) |>
  taxon_add(column = species, ranks = c(family, order)) |>
  taxon_cite(columns = species)
}
#> [taxon_cite] looking up authorship for 3 unique name(s) in 'species'
#> [taxon_cite] species: 1 / 3
#> [taxon_cite] species: 3 / 3
#> [taxon_cite] 'species_cite' appended -- 3 / 3 name(s) with authorship
#> [taxon_cite] looking up authorship for 2 unique name(s) in 'genus'
#> [taxon_cite] genus: 1 / 2
#> [taxon_cite] genus: 2 / 2
#> [taxon_cite] 'genus_cite' appended -- 2 / 2 name(s) with authorship
#> [taxon_cite] looking up authorship for 2 unique name(s) in 'species'
#> [taxon_cite] species: 1 / 2
#> [taxon_cite] species: 2 / 2
#> [taxon_cite] 'species_cite' appended -- 2 / 2 name(s) with authorship
#> [taxon_cite] looking up authorship for 3 unique name(s) in 'species'
#> [taxon_cite] species: 1 / 3
#> [taxon_cite] species: 3 / 3
#> [taxon_cite] 'species_cite' appended -- 3 / 3 name(s) with authorship
#> [taxon_cite] looking up authorship for 3 unique name(s) in 'species'
#> [taxon_cite] species: 1 / 3
#> [taxon_cite] species: 3 / 3
#> [taxon_cite] 'species_cite' appended -- 3 / 3 name(s) with authorship
#> [taxon_spellcheck] no validation_report provided -- running taxon_validate internally
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (3 valid name(s))
#> [taxon_validate] ITIS: 1 / 3
#> [taxon_validate] ITIS: 3 / 3
#> [taxon_validate] ITIS: 3 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (3 resolved names)
#> [taxon_validate] column 'species' detected rank: species -- 3 unique name(s) to process
#> [taxon_validate] pass 1: ITIS strict + synonym (3 valid name(s))
#> [taxon_validate] ITIS: 1 / 3
#> [taxon_validate] ITIS: 3 / 3
#> [taxon_validate] ITIS: 3 strict, 0 synonym, 0 unmatched
#> [taxon_validate] pass 5: authorship lookup (3 resolved names)
#> [taxon_spellcheck] taxon_validate complete -- applying corrections
#> [taxon_spellcheck] no issues found for column 'species'
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'order' (3 / 3 values resolved)
#> [taxon_cite] looking up authorship for 3 unique name(s) in 'species'
#> [taxon_cite] species: 1 / 3
#> [taxon_cite] species: 3 / 3
#> [taxon_cite] 'species_cite' appended -- 3 / 3 name(s) with authorship
#>        species    family     order                  species_cite
#> 1 Homo sapiens Hominidae  Primates Homo sapiens (Linnaeus, 1758)
#> 2 Panthera leo   Felidae Carnivora Panthera leo (Linnaeus, 1758)
#> 3  Canis lupus   Canidae Carnivora  Canis lupus (Linnaeus, 1758)
# }
```
