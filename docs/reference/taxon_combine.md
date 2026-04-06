# Combine genus and epithet columns into a binomial name

Merges separate genus and epithet columns into a single binomial
scientific name column, appended to the data frame. Both columns are
coerced to character and joined with a single space, following standard
binomial nomenclature formatting. The inverse of this operation is
[`taxon_split`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_split.md).

## Usage

``` r
taxon_combine(data, genus, epithet, new_column = NULL)
```

## Arguments

- data:

  A data frame.

- genus:

  Column name of the genus column, supplied either unquoted (`genus`) or
  quoted (`"genus"`).

- epithet:

  Column name of the specific epithet column, supplied either unquoted
  (`epithet`) or quoted (`"epithet"`).

- new_column:

  Optional. Unquoted or quoted name for the combined output column.
  Default is `"scientific_name"`.

## Value

The input data frame with one additional character column appended,
named according to `new_column`, containing values of the form
`"<genus> <epithet>"`. The original genus and epithet columns are
retained. Rows where either input column is `NA` will produce
`"NA <epithet>"` or `"<genus> NA"` in the output column.

## Details

No validation of genus or epithet values is performed. Use
[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
to standardize formatting and remove uncertain names before combining.
The resulting binomial column can be passed directly to
[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for higher rank look-ups or to
[`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
for formatted ggplot2 labels.

## See also

[`taxon_split`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_split.md)
for splitting a binomial name column back into separate genus and
epithet columns,

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for standardising genus and epithet columns before combining,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating the combined binomial name against ITIS and GBIF,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for looking up higher taxonomic ranks from the combined binomial name,

[`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
for formatting the combined name for ggplot2 display.

## Examples

``` r
df <- data.frame(
  genus   = c("Homo", "Panthera", "Canis"),
  epithet = c("sapiens", "leo", "lupus")
)

# Combine with default output column name
taxon_combine(df, genus = genus, epithet = epithet)
#>      genus epithet scientific_name
#> 1     Homo sapiens    Homo sapiens
#> 2 Panthera     leo    Panthera leo
#> 3    Canis   lupus     Canis lupus

# Use a custom output column name
taxon_combine(df, genus = genus, epithet = epithet,
              new_column = "binomial")
#>      genus epithet     binomial
#> 1     Homo sapiens Homo sapiens
#> 2 Panthera     leo Panthera leo
#> 3    Canis   lupus  Canis lupus

# NA in either column is propagated as a string
df_na <- data.frame(
  genus   = c("Homo", NA, "Canis"),
  epithet = c("sapiens", "leo", NA)
)
taxon_combine(df_na, genus = genus, epithet = epithet)
#>   genus epithet scientific_name
#> 1  Homo sapiens    Homo sapiens
#> 2  <NA>     leo          NA leo
#> 3 Canis    <NA>        Canis NA
```
