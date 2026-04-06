# Report coordinate limits of a data frame

Identifies and reports the minimum and maximum latitude and longitude
values in a data frame. Accepts separate latitude and longitude columns,
a combined coordinate column, or auto-detects coordinate columns using
[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
when no columns are specified. Prints a summary message and returns the
data frame unchanged, making it safe to use mid-pipeline.

## Usage

``` r
latlong_limits(
  data,
  latitude = NULL,
  longitude = NULL,
  column = NULL,
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- latitude:

  Optional. Column name of the latitude column, supplied either unquoted
  (`lat`) or quoted (`"lat"`).

- longitude:

  Optional. Column name of the longitude column, supplied either
  unquoted (`lon`) or quoted (`"lon"`).

- column:

  Optional. Column name of a combined coordinate column containing
  latitude and longitude as a single delimited string (e.g.
  `"51.5,-0.1"`), supplied either unquoted (`coords`) or quoted
  (`"coords"`). Supports `","`, `";"`, and whitespace as delimiters.

- drop_na:

  Logical. If `TRUE`, rows with `NA` coordinate values are excluded from
  the limit calculation. Default is `FALSE`.

## Value

The original `data` frame, returned invisibly and unchanged. This
function is called for its side effect of printing latitude and
longitude range messages to the console, and is safe to use within a
pipeline (e.g. with `|>`) without altering the data.

## Details

When none of `latitude`, `longitude`, or `column` are provided,
coordinate columns are auto-detected via
[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md).
The first detected latitude, longitude, and combined column are used. An
error is raised if no coordinate columns are found.

Values outside valid geographic ranges (`[-90, 90]` for latitude,
`[-180, 180]` for longitude) are silently excluded from the limit
calculation. Use
[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
to remove such rows from the data frame explicitly.

Combined columns are split on `","`, `";"`, or whitespace before
parsing. Only numeric (decimal degree) values are extracted from
combined columns; DMS and base-60 formats in combined columns are not
parsed. Use
[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
to convert to decimal degrees first if needed.

## See also

[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
for detecting coordinate columns automatically,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing out-of-range coordinates,

[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
for filtering rows to a user-defined bounding box using the limits
reported by this function,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting DMS or base-60 columns to decimal before computing
limits.

## Examples

``` r
df <- data.frame(
  id  = 1:4,
  lat = c(51.5, 48.8, -33.9, 40.7),
  lon = c(-0.1, 2.3, 151.2, -74.0)
)

# Report limits from separate latitude and longitude columns
latlong_limits(df, latitude = lat, longitude = lon)
#> [latlong_limits] latitude  — min: -33.900000, max: 51.500000
#> [latlong_limits] longitude — min: -74.000000, max: 151.200000

# Auto-detect coordinate columns
latlong_limits(df)
#> [latlong_limits] latitude  — min: 1.000000, max: 4.000000
#> [latlong_limits] longitude — min: -74.000000, max: 151.200000

# Report limits from a combined coordinate column
df_combined <- data.frame(
  coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2", "40.7,-74.0")
)
latlong_limits(df_combined, column = coords)
#> [latlong_limits] latitude  — min: -33.900000, max: 51.500000
#> [latlong_limits] longitude — min: -74.000000, max: 151.200000

# Exclude NA values from the limit calculation
df_na <- data.frame(
  lat = c(51.5, NA, -33.9, 40.7),
  lon = c(-0.1, 2.3, 151.2, NA)
)
latlong_limits(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#> [latlong_limits] latitude  — min: -33.900000, max: 51.500000
#> [latlong_limits] longitude — min: -0.100000, max: 151.200000

# Safe to use mid-pipeline — data is returned unchanged
df |>
  latlong_limits(latitude = lat, longitude = lon) |>
  latlong_filter(latitude = lat, longitude = lon)
#> [latlong_limits] latitude  — min: -33.900000, max: 51.500000
#> [latlong_limits] longitude — min: -74.000000, max: 151.200000
#> [latlong_filter] 0 row(s) removed with invalid or out-of-range coordinates
#>   id   lat   lon
#> 1  1  51.5  -0.1
#> 2  2  48.8   2.3
#> 3  3 -33.9 151.2
#> 4  4  40.7 -74.0
```
