# Split a combined coordinate column into separate columns

Splits a single combined coordinate column into separate latitude and
longitude columns, appended to the data frame. The inverse of this
operation is
[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md).
Useful as a prerequisite for functions that require separate coordinate
columns, such as
[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
and
[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md).

## Usage

``` r
latlong_split(
  data,
  combined_col,
  latitude,
  longitude,
  sep = ",",
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing a combined coordinate column.

- combined_col:

  Column name of the combined coordinate column containing latitude and
  longitude as a single delimited string (e.g. `"51.5,-0.1"`), supplied
  either unquoted (`coords`) or quoted (`"coords"`).

- latitude:

  Column name for the new latitude column to be appended, supplied
  either unquoted (`lat`) or quoted (`"lat"`).

- longitude:

  Column name for the new longitude column to be appended, supplied
  either unquoted (`lon`) or quoted (`"lon"`).

- sep:

  Character. Separator between latitude and longitude values in
  `combined_col`. Default is `","`. Must match the separator used when
  the combined column was created.

- drop_na:

  Logical. If `TRUE`, rows where splitting produces `NA` in either new
  column are dropped. Default is `FALSE`.

## Value

The input data frame with two additional character columns appended,
named according to `latitude` and `longitude`. The original
`combined_col` is retained. Values are returned as character strings;
use [`as.numeric()`](https://rdrr.io/r/base/numeric.html) or
[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
if numeric decimal degree values are required downstream. A console
message reports the number of rows removed when `drop_na = TRUE`.

## Details

Splitting is performed by
[`strsplit()`](https://rdrr.io/r/base/strsplit.html) on `sep`, with
leading and trailing whitespace trimmed from each part. Rows where
`combined_col` contains fewer than two parts after splitting produce
`NA` in the longitude column. Input strings are converted to UTF-8
before splitting to handle encoded coordinate values.

The new coordinate columns are character type regardless of input
format. Use
[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
to verify the format of the split columns, and
[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
to convert to a target format before passing to other functions.

## See also

[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
for merging separate coordinate columns into a single combined column,

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking the format of the split columns,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting split columns to a target coordinate format,

[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
for filtering to a bounding box, which does not accept combined columns,

[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md)
for filtering to named geographic regions, which does not accept
combined columns.

## Examples

``` r
df <- data.frame(
  id     = 1:4,
  coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2", "40.7,-74.0")
)

# Split into separate latitude and longitude columns
latlong_split(df, combined_col = coords, latitude = lat, longitude = lon)
#>   id      coords   lat   lon
#> 1  1   51.5,-0.1  51.5  -0.1
#> 2  2    48.8,2.3  48.8   2.3
#> 3  3 -33.9,151.2 -33.9 151.2
#> 4  4  40.7,-74.0  40.7 -74.0

# Use a custom separator
df_sep <- data.frame(
  coords = c("51.5;-0.1", "48.8;2.3", "-33.9;151.2")
)
latlong_split(df_sep, combined_col = coords, latitude = lat,
              longitude = lon, sep = ";")
#>        coords   lat   lon
#> 1   51.5;-0.1  51.5  -0.1
#> 2    48.8;2.3  48.8   2.3
#> 3 -33.9;151.2 -33.9 151.2

# Drop rows where splitting produces NA
df_na <- data.frame(
  coords = c("51.5,-0.1", "48.8", NA, "40.7,-74.0")
)
latlong_split(df_na, combined_col = coords, latitude = lat,
              longitude = lon, drop_na = TRUE)
#> [latlong_split] 2 NA row(s) removed
#>       coords  lat   lon
#> 1  51.5,-0.1 51.5  -0.1
#> 4 40.7,-74.0 40.7 -74.0

# Split then filter by bounding box
df |>
  latlong_split(combined_col = coords, latitude = lat, longitude = lon) |>
  latlong_range(latitude = lat, longitude = lon,
                lat_min = 0, lat_max = 60,
                lon_min = -10, lon_max = 40)
#> [latlong_range] 2 row(s) removed: 0 NA, 2 out of range
#>   id    coords  lat  lon
#> 1  1 51.5,-0.1 51.5 -0.1
#> 2  2  48.8,2.3 48.8  2.3
```
