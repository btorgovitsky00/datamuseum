# Clean taxonomic name formatting

Standardises taxonomic name formatting by removing extra whitespace,
stripping control characters, and flagging uncertain names containing
`cf.`, `sp.`, or `?` as `NA`. Cleaned values are either appended as a
new `<column>_clean` column or used to replace the original column in
place.

## Usage

``` r
taxon_cleaner(data, columns, in_place = FALSE, drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- columns:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to clean, supplied either unquoted (`species`) or quoted
  (`"species"`).

- in_place:

  Logical. If `TRUE`, the original column is overwritten with cleaned
  values. If `FALSE` (default), a new column named `<column>_clean` is
  inserted immediately after the original column.

- drop_na:

  Logical. If `TRUE`, rows where the cleaned column contains `NA` —
  including those flagged as uncertain — are dropped. Applied per column
  independently. Default is `FALSE`.

## Value

The input data frame with cleaned taxonomic columns. When
`in_place = FALSE`, one new character column is inserted per entry in
`columns`, named `<column>_clean` and positioned immediately after the
source column. A console message per column reports the number of `NA`
values and the number of uncertain names flagged before cleaning.

## Details

Standardizes taxonomic name formatting by removing extra whitespace,
fixing capitalization, and flagging uncertain names (cf., sp., ?).

Clean taxonomic name formatting

Cleaning applies the following steps in order to each column:

1.  Leading and trailing whitespace is removed via
    [`stringr::str_trim()`](https://stringr.tidyverse.org/reference/str_trim.html).

2.  Internal runs of whitespace are collapsed to a single space.

3.  Control characters are stripped.

4.  Values matching `cf.`, `sp.`, or `?` ( case-insensitive, whole-word)
    are replaced with `NA`.

Uncertain name detection is reported before flagging, so the console
message reflects the count in the original values rather than after
replacement. When multiple columns are supplied, `drop_na` is applied
independently to each column in sequence, so row counts may differ
across columns.

Capitalisation is not modified; names are returned with the same case as
the input after whitespace normalisation.

## See also

[`taxon_combine`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_combine.md)
for merging genus and epithet columns after cleaning,

[`taxon_split`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_split.md)
for splitting a binomial name column before cleaning individual parts,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating cleaned names against ITIS and GBIF,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for identifying and correcting misspellings after cleaning,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns,

[`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
for formatting taxonomic names for ggplot2 display.

## Examples

``` r
df <- data.frame(
  species = c("Homo sapiens", "Panthera  leo", "Canis cf. lupus",
              "Ursus sp.", NA)
)

# Append a cleaned column (default)
taxon_cleaner(df, species)
#> [taxon_cleaner] 'species': 1 NA row(s), 2 uncertain row(s) (cf./sp./?)
#>           species species_clean
#> 1    Homo sapiens  Homo sapiens
#> 2   Panthera  leo  Panthera leo
#> 3 Canis cf. lupus          <NA>
#> 4       Ursus sp.          <NA>
#> 5            <NA>          <NA>

# Clean in place
taxon_cleaner(df, in_place = TRUE, columns = species)
#> [taxon_cleaner] 'species': 1 NA row(s), 2 uncertain row(s) (cf./sp./?)
#>        species
#> 1 Homo sapiens
#> 2 Panthera leo
#> 3         <NA>
#> 4         <NA>
#> 5         <NA>

# Drop rows flagged as uncertain or NA after cleaning
taxon_cleaner(df, species, drop_na = TRUE)
#> [taxon_cleaner] 'species': 1 NA row(s), 2 uncertain row(s) (cf./sp./?)
#>         species species_clean
#> 1  Homo sapiens  Homo sapiens
#> 2 Panthera  leo  Panthera leo

# Clean multiple columns at once
df2 <- data.frame(
  genus   = c("Homo", "Panthera", "Canis cf.", NA),
  species = c("sapiens", "leo  ", "lupus", "arctos")
)
taxon_cleaner(df2, c(genus, species))
#> [taxon_cleaner] 'genus': 1 NA row(s), 1 uncertain row(s) (cf./sp./?)
#> [taxon_cleaner] 'species': 0 NA row(s), 0 uncertain row(s) (cf./sp./?)
#>       genus genus_clean species species_clean
#> 1      Homo        Homo sapiens       sapiens
#> 2  Panthera    Panthera   leo             leo
#> 3 Canis cf.        <NA>   lupus         lupus
#> 4      <NA>        <NA>  arctos        arctos
```
