# Filter rows by coordinate range

Retains only rows where coordinates fall within specified latitude and
longitude bounds. Unlike
[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md),
which validates against absolute geographic limits, this function
filters to a user-defined bounding box. Use
[`latlong_limits`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_limits.md)
first to inspect the coordinate extent of the data and inform suitable
bound values.

## Usage

``` r
latlong_range(
  data,
  latitude,
  longitude,
  lat_min,
  lat_max,
  lon_min,
  lon_max,
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- latitude:

  Column name of the latitude column, supplied either unquoted (`lat`)
  or quoted (`"lat"`). Must contain numeric or numeric-coercible values
  in decimal degrees.

- longitude:

  Column name of the longitude column, supplied either unquoted (`lon`)
  or quoted (`"lon"`). Must contain numeric or numeric-coercible values
  in decimal degrees.

- lat_min:

  Numeric. Minimum latitude bound (inclusive). Must be in the range
  `[-90, 90]`.

- lat_max:

  Numeric. Maximum latitude bound (inclusive). Must be in the range
  `[-90, 90]`.

- lon_min:

  Numeric. Minimum longitude bound (inclusive). Must be in the range
  `[-180, 180]`.

- lon_max:

  Numeric. Maximum longitude bound (inclusive). Must be in the range
  `[-180, 180]`.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in either coordinate column are
  dropped before range filtering. Default is `FALSE`.

## Value

A data frame containing only rows where latitude falls within
`[lat_min, lat_max]` and longitude falls within `[lon_min, lon_max]`,
with the same columns as `data`. A console message reports the total
rows removed, broken down by `NA` rows and out-of-range rows.

## Details

Coordinate columns are coerced to numeric via
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) before filtering.
Non-numeric values (including DMS or base-60 strings) will produce `NA`
after coercion and be treated as out-of-range. Use
[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
to convert to decimal degrees before calling this function if columns
are not already numeric.

All bounds are inclusive. Rows with `NA` coordinates are excluded from
the retained set regardless of `drop_na`, as they cannot be evaluated
against the bounds. When `drop_na = FALSE`, `NA` rows contribute to the
out-of-range count in the console message rather than the `NA` count.

## See also

[`latlong_limits`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_limits.md)
for inspecting the coordinate extent of a data frame to inform bound
selection,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing coordinates outside absolute geographic validity ranges,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting DMS or base-60 columns to decimal degrees before
filtering,

[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
for separating a combined coordinate column into distinct latitude and
longitude columns before filtering as `latlong_range` does not function
with combined columns,

[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md)
for filtering to named geographic regions rather than a numeric bounding
box.

## Examples

``` r
df <- data.frame(
  id  = 1:6,
  lat = c(51.5, 48.8, -33.9, 40.7, 35.6, 55.8),
  lon = c(-0.1, 2.3, 151.2, -74.0, 139.7, 37.6)
)

# Retain only rows within a European bounding box
latlong_range(df, latitude = lat, longitude = lon,
              lat_min = 35, lat_max = 60,
              lon_min = -10, lon_max = 40)
#> [latlong_range] 3 row(s) removed: 0 NA, 3 out of range
#>   id  lat  lon
#> 1  1 51.5 -0.1
#> 2  2 48.8  2.3
#> 6  6 55.8 37.6

# Use latlong_limits first to inspect coordinate extent
df |>
  latlong_limits(latitude = lat, longitude = lon) |>
  latlong_range(latitude = lat, longitude = lon,
                lat_min = 35, lat_max = 60,
                lon_min = -10, lon_max = 40)
#> [latlong_limits] latitude  — min: -33.900000, max: 55.800000
#> [latlong_limits] longitude — min: -74.000000, max: 151.200000
#> [latlong_range] 3 row(s) removed: 0 NA, 3 out of range
#>   id  lat  lon
#> 1  1 51.5 -0.1
#> 2  2 48.8  2.3
#> 6  6 55.8 37.6

# Drop NA rows before filtering
df_na <- data.frame(
  lat = c(51.5, NA, -33.9, 40.7),
  lon = c(-0.1, 2.3, 151.2, NA)
)
latlong_range(df_na, latitude = lat, longitude = lon,
              lat_min = 0, lat_max = 60,
              lon_min = -10, lon_max = 40,
              drop_na = TRUE)
#> [latlong_range] 3 row(s) removed: 2 NA, 1 out of range
#>    lat  lon
#> 1 51.5 -0.1
```
