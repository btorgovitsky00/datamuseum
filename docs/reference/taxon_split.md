# Split a binomial name column into genus and epithet

Splits a binomial scientific name column into separate genus and epithet
columns, appended to the data frame. The inverse of this operation is
[`taxon_combine`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_combine.md).
Only values matching strict binomial format (`"Genus epithet"`) are
split; non-conforming values produce `NA` in both output columns.

## Usage

``` r
taxon_split(data, column, genus = NULL, epithet = NULL, drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- column:

  Column name of the binomial name column to split, supplied either
  unquoted (`scientific_name`) or quoted (`"scientific_name"`).

- genus:

  Optional. Name for the genus output column. Default is
  `<column>_genus`.

- epithet:

  Optional. Name for the epithet output column. Default is
  `<column>_epithet`.

- drop_na:

  Logical. If `TRUE`, rows where splitting produces `NA` — including
  non-conforming names — are dropped. Default is `FALSE`.

## Value

The input data frame with two additional character columns appended,
named according to `genus` and `epithet`. The original `column` is
retained. Values that do not match the expected binomial format produce
`NA` in both output columns.

## Details

Splitting is performed by splitting on the first space. A value is
considered a valid binomial if it matches the pattern
`"^[A-Z][a-z]+ [a-z]+$"` — an initial-capitalised genus followed by a
single lowercase epithet, separated by one space. Values with
authorship, infraspecific ranks, uncertainty markers (`cf.`, `sp.`), or
extra whitespace will not match and produce `NA`. Use
[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
to standardise formatting before splitting.

## See also

[`taxon_combine`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_combine.md)
for merging separate genus and epithet columns into a binomial name,

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for standardising binomial name formatting before splitting,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating split columns against ITIS and GBIF,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns after splitting.

## Examples

``` r
df <- data.frame(
  scientific_name = c("Homo sapiens", "Panthera leo", "Canis lupus")
)

# Split with default output column names
taxon_split(df, column = scientific_name)
#>   scientific_name scientific_name_genus scientific_name_epithet
#> 1    Homo sapiens                  Homo                 sapiens
#> 2    Panthera leo              Panthera                     leo
#> 3     Canis lupus                 Canis                   lupus

# Use custom output column names
taxon_split(df, column = scientific_name,
            genus = "gen", epithet = "sp")
#>   scientific_name      gen      sp
#> 1    Homo sapiens     Homo sapiens
#> 2    Panthera leo Panthera     leo
#> 3     Canis lupus    Canis   lupus

# Non-conforming values produce NA in both output columns
df_mixed <- data.frame(
  scientific_name = c("Homo sapiens", "Canis cf. lupus",
                      "Ursus sp.", "panthera leo")
)
taxon_split(df_mixed, column = scientific_name)
#>   scientific_name scientific_name_genus scientific_name_epithet
#> 1    Homo sapiens                  Homo                 sapiens
#> 2 Canis cf. lupus                  <NA>                    <NA>
#> 3       Ursus sp.                  <NA>                    <NA>
#> 4    panthera leo                  <NA>                    <NA>

# Drop rows that fail to split
taxon_split(df_mixed, column = scientific_name, drop_na = TRUE)
#>   scientific_name scientific_name_genus scientific_name_epithet
#> 1    Homo sapiens                  Homo                 sapiens
```
