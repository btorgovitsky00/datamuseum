# Identify taxonomic columns

Detects columns in a data frame that contain taxonomic names based on
column name patterns and value content. Returns a summary of detected
columns and their value counts, a named list mapping taxonomic ranks to
column indices, or both. Useful as a precursor to
[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
and
[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
to identify existing rank columns before modifying the data frame.

## Usage

``` r
taxon_column(df, output = "tibble")
```

## Arguments

- df:

  A data frame.

- output:

  Character. Format of the return value. One of `"tibble"` (default),
  `"list"`, or `"both"`. See **Value** for details of each format.

## Value

Depends on `output`:

- `"tibble"`:

  A tibble with three columns — `column` (the detected column name),
  `value` (each unique non-`NA` value), and `count` (number of
  occurrences) — sorted by count descending within each column. Only
  strongly detected columns are included.

- `"list"`:

  A named list where each element corresponds to a taxonomic rank (e.g.
  `species`, `family`) and contains a named list mapping column name to
  column index in `df`. Includes both strongly and weakly detected
  columns.

- `"both"`:

  A list with two elements: `counts` (the tibble described above) and
  `candidates` (the named list described above).

## Details

Detection uses a three-tier matching system applied to column names:

1.  **Strong match** — column name contains a full taxonomic keyword
    (`taxon`, `species`, `genus`, `family`, `order`, `class`, `phylum`,
    `kingdom`, `scientificname`).

2.  **Weak match (3–5 chars)** — column name contains a substring of
    length 3–5 derived from a taxonomic keyword.

3.  **Weak match (1–2 chars)** — column name contains a very short
    substring; used only for candidate columns not already captured by
    stronger tiers.

Columns matching geographic, temporal, or location-related terms
(`latitude`, `longitude`, `country`, `date`, etc.) are excluded at each
tier. Columns where more than 70% of non-`NA` values are numeric and
fewer than 20% contain letters are also excluded as non-taxonomic.

When multiple columns match the same rank, all are assigned to that rank
in the `"list"` output. Use `output = "list"` inside
[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
with `sort = TRUE` to check for duplicate rank assignments before
sorting.

## See also

[`taxon_rank`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_rank.md)
for detecting the rank of specific columns by name,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns,

[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
for sorting columns into standard taxonomic rank order,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating detected columns using `update_related`.

## Examples

``` r
df <- data.frame(
  id      = 1:4,
  species = c("Homo sapiens", "Panthera leo", "Canis lupus", "Ursus arctos"),
  family  = c("Hominidae", "Felidae", "Canidae", "Ursidae"),
  count   = c(10, 5, 8, 3)
)

# Return a tibble of detected columns and value counts (default)
taxon_column(df)
#> # A tibble: 8 × 3
#>   column  value        count
#>   <chr>   <chr>        <int>
#> 1 species Canis lupus      1
#> 2 species Homo sapiens     1
#> 3 species Panthera leo     1
#> 4 species Ursus arctos     1
#> 5 family  Canidae          1
#> 6 family  Felidae          1
#> 7 family  Hominidae        1
#> 8 family  Ursidae          1

# Return a named list mapping ranks to column indices
taxon_column(df, output = "list")
#> $family
#> $family$family
#> [1] 3
#> 
#> 
#> $species
#> $species$species
#> [1] 2
#> 
#> 

# Return both formats
taxon_column(df, output = "both")
#> $counts
#> # A tibble: 8 × 3
#>   column  value        count
#>   <chr>   <chr>        <int>
#> 1 species Canis lupus      1
#> 2 species Homo sapiens     1
#> 3 species Panthera leo     1
#> 4 species Ursus arctos     1
#> 5 family  Canidae          1
#> 6 family  Felidae          1
#> 7 family  Hominidae        1
#> 8 family  Ursidae          1
#> 
#> $candidates
#> $candidates$family
#> $candidates$family$family
#> [1] 3
#> 
#> 
#> $candidates$species
#> $candidates$species$species
#> [1] 2
#> 
#> 
#> 

# Use list output to inspect rank assignments before taxon_add
taxon_column(df, output = "list")
#> $family
#> $family$family
#> [1] 3
#> 
#> 
#> $species
#> $species$species
#> [1] 2
#> 
#> 
```
