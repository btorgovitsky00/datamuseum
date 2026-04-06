# Combine separate coordinate columns into one

Merges separate latitude and longitude columns into a single combined
coordinate column, appended to the data frame. The inverse of this
operation is
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md).
Note that combined columns are not accepted by the functions
[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
and
[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md);
use
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
to separate columns again before filtering.

## Usage

``` r
latlong_combine(
  data,
  latitude,
  longitude,
  new_column = "latlong",
  sep = ", ",
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- latitude:

  Column name of the latitude column, supplied either unquoted (`lat`)
  or quoted (`"lat"`). Required if `combined_col` is not provided.

- longitude:

  Column name of the longitude column, supplied either unquoted (`lon`)
  or quoted (`"lon"`). Required if `combined_col` is not provided.

- new_column:

  Column name for the new combined column, supplied either unquoted
  (`latlong`) or quoted (`"latlong"`). Default is `latlong`.

- sep:

  Character. Separator inserted between latitude and longitude values in
  the combined column. Default is `", "`. Must match the `sep` argument
  of
  [`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
  if the combined column will be split again later.

- drop_na:

  Logical. If `TRUE`, rows where either the latitude or longitude column
  is `NA` are dropped before combining. Default is `FALSE`.

## Value

The input data frame with one additional character column appended,
named according to `new_column`, containing values of the form
`"<latitude><sep><longitude>"`. The original latitude and longitude
columns are retained. If `drop_na = FALSE`, rows with `NA` in either
coordinate column will produce `"NA<sep>NA"` or `"<value><sep>NA"` in
the combined column.

## Details

Both coordinate columns are coerced to character before concatenation
via [`paste0()`](https://rdrr.io/r/base/paste.html), so numeric,
integer, and character coordinate columns are all accepted. No
validation of coordinate ranges or formats is performed; use
[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
to check column formats before combining.

A console message reports the number of rows removed when
`drop_na = TRUE`.

## See also

[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
for splitting a combined coordinate column back into separate latitude
and longitude columns,

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking coordinate formats before combining.

## Examples

``` r
df <- data.frame(
  id  = 1:4,
  lat = c(51.5, 48.8, 40.7, 35.6),
  lon = c(-0.1, 2.3, -74.0, 139.7)
)

# Combine with default separator and column name
latlong_combine(df, latitude = lat, longitude = lon)
#>   id  lat   lon     latlong
#> 1  1 51.5  -0.1  51.5, -0.1
#> 2  2 48.8   2.3   48.8, 2.3
#> 3  3 40.7 -74.0   40.7, -74
#> 4  4 35.6 139.7 35.6, 139.7

# Use a custom separator and column name
latlong_combine(df, latitude = lat, longitude = lon,
                new_column = coords, sep = ";")
#>   id  lat   lon     coords
#> 1  1 51.5  -0.1  51.5;-0.1
#> 2  2 48.8   2.3   48.8;2.3
#> 3  3 40.7 -74.0   40.7;-74
#> 4  4 35.6 139.7 35.6;139.7

# Drop rows where either coordinate is NA
df_na <- data.frame(
  lat = c(51.5, NA, 40.7),
  lon = c(-0.1, 2.3, NA)
)
latlong_combine(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#> [latlong_combine] 2 NA row(s) removed
#>    lat  lon    latlong
#> 1 51.5 -0.1 51.5, -0.1
```
