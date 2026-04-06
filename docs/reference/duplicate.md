# Duplicate rows by a count column

Expands a data frame by repeating each row X number of times, specified
by a count column. Useful for reconstructing individual-level data from
aggregated or frequency-weighted data frames.

## Usage

``` r
duplicate(data, n_col, drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- n_col:

  Column name of the column containing duplication counts, supplied
  either unquoted (`n`) or quoted (`"n"`). Rows with `NA` counts are
  counted once unless `drop_na = TRUE`.

- drop_na:

  Logical. If `TRUE`, rows where `n_col` is `NA` are dropped before
  expansion. Default is `FALSE`.

## Value

A data frame with more rows than `data`, where each row `i` appears
`n_col[i]` times (or once if `n_col[i]` is `NA` and `drop_na = FALSE`).
Row names are not reset. The `n_col` column is retained in the output.

## Details

Expansion is performed via `rep(seq_len(nrow(data)), times = n_col)`, so
the original row order is preserved within each group of duplicates.
`NA` counts are replaced with `1` prior to expansion when
`drop_na = FALSE`.

A console message reports the final row count of the expanded data
frame.

## See also

[`deduplicate`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md)
for the inverse operation,

[`rep`](https://rdrr.io/r/base/rep.html) for the underlying row
repetition mechanism.

## Examples

``` r
df <- data.frame(
  group = c("A", "B", "C"),
  value = c(10, 20, 30),
  n     = c(3, 1, 2)
)

# Expand so each row repeats n times
duplicate(df, n_col = n)
#> [duplicate] dataset expanded to 6 rows based on 'n'
#>     group value n
#> 1       A    10 3
#> 1.1     A    10 3
#> 1.2     A    10 3
#> 2       B    20 1
#> 3       C    30 2
#> 3.1     C    30 2

# NA counts default to 1 repetition
df_na <- data.frame(
  group = c("A", "B", "C"),
  n     = c(2, NA, 3)
)
duplicate(df_na, n_col = n)
#> [duplicate] dataset expanded to 6 rows based on 'n'
#>     group n
#> 1       A 2
#> 1.1     A 2
#> 2       B 1
#> 3       C 3
#> 3.1     C 3
#> 3.2     C 3

# Drop rows with NA counts instead
duplicate(df_na, n_col = n, drop_na = TRUE)
#> [duplicate] 1 NA row(s) removed from numbering column
#> [duplicate] dataset expanded to 5 rows based on 'n'
#>     group n
#> 1       A 2
#> 1.1     A 2
#> 3       C 3
#> 3.1     C 3
#> 3.2     C 3
```
