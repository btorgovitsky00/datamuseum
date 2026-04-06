# Filter rows by real-world coordinate validity

Removes rows where coordinates fall outside valid geographic ranges
(`[-90, 90]` for latitude, `[-180, 180]` for longitude). Accepts either
separate latitude and longitude columns, or a single combined coordinate
column. Supports decimal degree, DMS (`DD°MM′SS″`), and base-60
(`DD°MM′`) coordinate formats.

## Usage

``` r
latlong_filter(
  data,
  latitude = NULL,
  longitude = NULL,
  combined_col = NULL,
  sep = ",",
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- latitude:

  Optional. Column name of the latitude column, supplied either unquoted
  (`lat`) or quoted (`"lat"`). Required if `combined_col` is not
  provided.

- longitude:

  Optional. Column name of the longitude column, supplied either
  unquoted (`lon`) or quoted (`"lon"`). Required if `combined_col` is
  not provided.

- combined_col:

  Optional. Column name of a combined coordinate column containing
  latitude and longitude as a single delimited string (e.g.
  `"51.5,-0.1"`), supplied either unquoted (`coords`) or quoted
  (`"coords"`). Required if `latitude` and `longitude` are not provided.

- sep:

  Character. Separator used to split `combined_col` into latitude and
  longitude parts. Default is `","`.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in either coordinate are dropped in
  addition to out-of-range rows. Default is `FALSE`.

## Value

A data frame containing only rows with valid coordinates, with the same
columns as `data`. Removed rows are attached as
`attr(result, "invalid")` for inspection. A console message reports the
total number of rows removed.

## Details

All coordinate formats are parsed to decimal degrees internally before
range validation. The parser handles decimal, DMS, and base-60 formats,
inferring sign from cardinal direction suffixes (`S`, `W`) or the sign
of the degree value. Zero-width and BOM characters are stripped before
parsing.

Either `combined_col` or both `latitude` and `longitude` must be
provided; supplying neither raises an error. When `drop_na = FALSE` (the
default), rows with `NA` coordinates are still removed as they cannot
pass range validation, and are captured in `attr(result, "invalid")`.

Use
[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
to check coordinate formats before filtering, and
[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
to identify coordinate columns if their names are not known in advance.

## See also

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking coordinate formats before filtering,

[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
for detecting coordinate columns in a data frame,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting DMS or base-60 columns to decimal degrees before
filtering,

[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
for filtering rows to a user-defined bounding box,

[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md)
for filtering rows to named geographic regions.

## Examples

``` r
df <- data.frame(
  id  = 1:5,
  lat = c(51.5, 48.8, 91.0, -33.9, NA),
  lon = c(-0.1, 2.3, 139.7, 151.2, 37.6)
)

# Filter using separate latitude and longitude columns
latlong_filter(df, latitude = lat, longitude = lon)
#> [latlong_filter] 2 row(s) removed with invalid or out-of-range coordinates
#>   id   lat   lon
#> 1  1  51.5  -0.1
#> 2  2  48.8   2.3
#> 4  4 -33.9 151.2

# Inspect rows that were removed
result <- latlong_filter(df, latitude = lat, longitude = lon)
#> [latlong_filter] 2 row(s) removed with invalid or out-of-range coordinates
attr(result, "invalid")
#>   id lat   lon
#> 3  3  91 139.7
#> 5  5  NA  37.6

# Also drop rows where either coordinate is NA
latlong_filter(df, latitude = lat, longitude = lon, drop_na = TRUE)
#> [latlong_filter] 2 row(s) removed with invalid or out-of-range coordinates
#>   id   lat   lon
#> 1  1  51.5  -0.1
#> 2  2  48.8   2.3
#> 4  4 -33.9 151.2

# Filter using a combined coordinate column
df_combined <- data.frame(
  id     = 1:4,
  coords = c("51.5,-0.1", "91.0,2.3", "-33.9,151.2", "48.8,181.0")
)
latlong_filter(df_combined, combined_col = coords)
#> [latlong_filter] 2 row(s) removed with invalid or out-of-range coordinates
#>   id      coords
#> 1  1   51.5,-0.1
#> 3  3 -33.9,151.2

# Combined column with a custom separator
df_sep <- data.frame(
  coords = c("51.5;-0.1", "91.0;2.3", "-33.9;151.2")
)
latlong_filter(df_sep, combined_col = coords, sep = ";")
#> [latlong_filter] 1 row(s) removed with invalid or out-of-range coordinates
#>        coords
#> 1   51.5;-0.1
#> 3 -33.9;151.2
```
