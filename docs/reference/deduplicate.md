# Remove duplicate rows

Removes duplicate rows from a data frame based on a specified ID column,
retaining the most complete row (fewest `NA` values) per ID group. A
record of all duplicate groups is attached to the result as an
attribute.

## Usage

``` r
deduplicate(data, id_col, drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- id_col:

  Column name of the ID column to use for duplicate detection, supplied
  either unquoted (`id`) or quoted (`"id"`).

- drop_na:

  Logical. If `TRUE`, rows where the ID column is `NA` are dropped
  before de-duplication. Default is `FALSE`.

## Value

A data frame with one row retained per unique value of `id_col`, chosen
by maximum row completeness (fewest `NA`s across all columns). The
original duplicate groups are accessible via
`attr(result, "duplicates")`, a data frame containing all rows that were
part of a duplicate group, with an additional logical column `.kept_row`
indicating which row was retained.

## Details

Row completeness is computed as the count of non-`NA` values across all
columns using `rowSums(!is.na(data))`. When multiple rows tie on
completeness, [`which.max()`](https://rdrr.io/r/base/which.min.html)
retains the first occurrence.

Progress messages are printed to the console reporting the number of
`NA` ID rows removed (if `drop_na = TRUE`) and the total number of
duplicate rows removed.

## See also

[`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
for the inverse operation of expanding rows by a count column,

[`duplicated`](https://rdrr.io/r/base/duplicated.html) for simple
duplicate detection,

[`distinct`](https://dplyr.tidyverse.org/reference/distinct.html) for
dropping exact duplicate rows.

## Examples

``` r
df <- data.frame(
  id    = c(1, 2, 2, 3, 3),
  name  = c("A", "B", NA, "C", "C"),
  score = c(90, 85, 85, 78, 78)
)

# Retain the most complete row per ID
deduplicate(df, id_col = id)
#> [deduplicate] 2 duplicate row(s) removed
#>   id name score
#> 1  1    A    90
#> 2  2    B    85
#> 4  3    C    78

# Inspect which rows were flagged as duplicates
result <- deduplicate(df, id_col = id)
#> [deduplicate] 2 duplicate row(s) removed
attr(result, "duplicates")
#>   id name score .kept_row
#> 2  2    B    85      TRUE
#> 3  2 <NA>    85     FALSE
#> 4  3    C    78      TRUE
#> 5  3    C    78     FALSE

# Drop rows where the ID itself is NA before deduplication
df_na <- data.frame(
  id    = c(1, NA, 2, 2),
  value = c("a", "b", "c", "d")
)
deduplicate(df_na, id_col = id, drop_na = TRUE)
#> [deduplicate] 1 NA row(s) removed from ID column
#> [deduplicate] 1 duplicate row(s) removed
#>   id value
#> 1  1     a
#> 3  2     c
```
