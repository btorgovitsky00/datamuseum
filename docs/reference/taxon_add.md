# Add higher taxonomic rank columns

Looks up and appends one or more higher taxonomic rank columns to a data
frame using GBIF and/or ITIS as reference sources. Intended for use
after
[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
and
[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
to append ranks not already present in the data frame. Results are
cached to disk to speed up repeated calls.

## Usage

``` r
taxon_add(
  data,
  column,
  ranks,
  source = "both",
  author_year = FALSE,
  sort = FALSE,
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame.

- column:

  Column name of the taxonomic column to look up from, supplied either
  unquoted (`species`) or quoted (`"species"`). Should contain validated
  scientific names at a consistent rank.

- ranks:

  Rank name or [`c()`](https://rdrr.io/r/base/c.html) of rank names to
  add, supplied either unquoted (`family`) or quoted (`"family"`).
  Supported ranks are: `genus`, `family`, `order`, `class`, `phylum`,
  `kingdom`. An error is raised for any unsupported rank.

- source:

  Character. Taxonomic reference source. One of `"both"` (default),
  `"gbif"`, or `"itis"`. When `"both"`, GBIF is queried first and ITIS
  is used as a fallback if no result is returned.

- author_year:

  Logical. If `TRUE`, appends authorship and year to resolved rank names
  in the format `"Genus species (Author, Year)"`. If authorship is
  unavailable the canonical name is returned unchanged. Default is
  `FALSE`.

- sort:

  Logical. If `TRUE`, columns are sorted into standard taxonomic rank
  order after adding ranks via
  [`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md).
  If multiple columns are detected for the same rank an error is raised
  with guidance to apply
  [`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
  manually. Default is `FALSE`.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in `column` are dropped before
  lookup. Default is `FALSE`.

## Value

The input data frame with one new character column appended per entry in
`ranks`, named by rank (e.g. `family`, `order`). A report tibble is
attached as `attr(result, "add_report")` with columns:

- `column`:

  Name of the source column looked up from.

- `name`:

  Input name for which the rank could not be resolved.

- `missing_rank`:

  The rank that could not be resolved for that name.

- `n`:

  Number of rows containing that name.

An empty tibble is attached when all ranks are resolved. A console
message per rank reports the number of values resolved and lists
unresolved names.

## Details

GBIF is queried via
[`rgbif::name_backbone()`](https://docs.ropensci.org/rgbif/reference/name_backbone.html)
and
[`rgbif::name_usage()`](https://docs.ropensci.org/rgbif/reference/name_usage.html);
ITIS is queried via
[`taxize::get_tsn()`](https://docs.ropensci.org/taxize/reference/get_tsn.html)
and
[`taxize::classification()`](https://docs.ropensci.org/taxize/reference/classification.html).
Results are cached to disk using memoise and cachem in
`tools::R_user_dir("taxon_add", "cache")`, so repeated calls for the
same names are fast. Requires memoise and cachem; rgbif and/or taxize
are required depending on `source`.

Only unique non-`NA` values in `column` are looked up, so performance
scales with the number of distinct names rather than total rows.

When `author_year = TRUE`, authorship is resolved via a separate GBIF
lookup on the canonical name returned for each rank. If the resolved
name with authorship is identical to the canonical name, or produces
empty parentheses, the canonical name is returned unchanged.

Use
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
to detect existing taxonomic rank columns before adding new ones, and
[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
to reorder columns into standard rank order independently of this
function.

## Note

This function queries external web services (GBIF via rgbif and/or ITIS
via taxize) and requires an active internet connection with reliable
access to those servers. Performance on unstable or restricted
connections (e.g. public WiFi, VPN, or firewalled networks) may be slow
or produce incomplete results. Previously queried names are cached to
disk via memoise and cachem at
`tools::R_user_dir("taxon_add", "cache")`, so running on a stable
connection first will speed up subsequent calls regardless of connection
quality.

Connectivity can be tested before adding ranks:

    # Test ITIS connectivity
    taxize::get_tsn("Homo sapiens", accepted = FALSE, verbose = TRUE,
                    messages = TRUE, ask = FALSE)

    # Test GBIF connectivity
    rgbif::name_backbone(name = "Homo sapiens", strict = TRUE)

## See also

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating and resolving synonyms before adding ranks,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for correcting misspellings before adding ranks,

[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
for appending authorship and year after adding ranks,

[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
for sorting columns into standard taxonomic rank order,

[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
for detecting existing taxonomic rank columns before adding new ones.

## Examples

``` r
df <- data.frame(
  species = c("Homo sapiens", "Panthera leo", "Canis lupus")
)

# \donttest{
if (requireNamespace("rgbif", quietly = TRUE) &&
    requireNamespace("taxize", quietly = TRUE)) {
# Add a single rank
taxon_add(df, column = species, ranks = family)

# Add multiple ranks at once
taxon_add(df, column = species, ranks = c(family, order, class))

# Use GBIF only as the source
taxon_add(df, column = species, ranks = family, source = "gbif")

# Append authorship to resolved rank names
taxon_add(df, column = species, ranks = c(family, genus),
          author_year = TRUE)

# Add ranks and sort into standard taxonomic order
taxon_add(df, column = species, ranks = c(family, order, class),
          sort = TRUE)

# Inspect names where ranks could not be resolved
result <- taxon_add(df, column = species, ranks = c(family, order))
attr(result, "add_report")
}
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'order' (3 / 3 values resolved)
#> [taxon_add] added column 'class' (3 / 3 values resolved)
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'genus' (3 / 3 values resolved)
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'order' (3 / 3 values resolved)
#> [taxon_add] added column 'class' (3 / 3 values resolved)
#> [taxon_sort] 4 taxonomic column(s) sorted from position 1: class -> order -> family -> species
#> [taxon_add] added column 'family' (3 / 3 values resolved)
#> [taxon_add] added column 'order' (3 / 3 values resolved)
#> # A tibble: 0 × 4
#> # ℹ 4 variables: column <chr>, name <chr>, missing_rank <chr>, n <int>
# }
```
