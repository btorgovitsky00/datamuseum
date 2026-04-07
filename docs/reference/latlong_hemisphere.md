# Assign hemispheres to coordinates

Appends `NS_hemisphere` and `EW_hemisphere` columns to a data frame
based on the sign of coordinate values. Accepts either separate latitude
and longitude columns or a single combined coordinate column. Supports
decimal degree, DMS (`DDdeg MM'SS''}), and base-60 (\code{DDdeg MM'`)
coordinate formats.

## Usage

``` r
latlong_hemisphere(
  data,
  latitude = NULL,
  longitude = NULL,
  combined_col = NULL,
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
  latitude and longitude as a single comma-delimited string (e.g.
  `"51.5,-0.1"`), supplied either unquoted (`coords`) or quoted
  (`"coords"`). Required if `latitude` and `longitude` are not provided.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in either coordinate are dropped
  before hemisphere assignment. Default is `FALSE`.

## Value

The input data frame with two additional character columns appended:

- `NS_hemisphere`:

  `"North"` if latitude is greater than or equal to zero, `"South"` if
  negative, `NA` if the coordinate could not be parsed.

- `EW_hemisphere`:

  `"East"` if longitude is greater than or equal to zero, `"West"` if
  negative, `NA` if the coordinate could not be parsed.

Rows removed by `drop_na = TRUE` are attached as
`attr(result, "removed_na")` for inspection.

## Details

All coordinate formats are parsed to decimal degrees internally before
hemisphere assignment. The parser handles decimal, DMS, and base-60
formats, inferring sign from cardinal direction suffixes (`S`, `W`) or
the sign of the degree value. Zero-width and BOM characters are stripped
before parsing.

Either `combined_col` or both `latitude` and `longitude` must be
provided; supplying neither raises an error. When `drop_na = FALSE` (the
default), rows with unparseable or `NA` coordinates are retained with
`NA` in the hemisphere columns.

The combined column separator is assumed to be `","`. Use
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
to separate a combined column with a different delimiter before calling
this function.

Use
[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
to remove out-of-range coordinates before assigning hemispheres, and
[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
to verify coordinate formats in advance.

## See also

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing invalid coordinates before hemisphere assignment,

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking coordinate formats,

[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
for detecting coordinate columns in a data frame,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting DMS or base-60 columns to decimal degrees before
hemisphere assignment.

## Examples

``` r
df <- data.frame(
  id  = 1:4,
  lat = c(51.5, -33.9, 48.8, -23.5),
  lon = c(-0.1, 151.2, 2.3, -46.6)
)

# Assign hemispheres from separate latitude and longitude columns
latlong_hemisphere(df, latitude = lat, longitude = lon)
#>   id   lat   lon NS_hemisphere EW_hemisphere
#> 1  1  51.5  -0.1         North          West
#> 2  2 -33.9 151.2         South          East
#> 3  3  48.8   2.3         North          East
#> 4  4 -23.5 -46.6         South          West

# Assign hemispheres from a combined coordinate column
df_combined <- data.frame(
  id     = 1:4,
  coords = c("51.5,-0.1", "-33.9,151.2", "48.8,2.3", "-23.5,-46.6")
)
latlong_hemisphere(df_combined, combined_col = coords)
#>   id      coords NS_hemisphere EW_hemisphere
#> 1  1   51.5,-0.1         North          West
#> 2  2 -33.9,151.2         South          East
#> 3  3    48.8,2.3         North          East
#> 4  4 -23.5,-46.6         South          West

# Drop rows where either coordinate is NA
df_na <- data.frame(
  lat = c(51.5, NA, -33.9),
  lon = c(-0.1, 2.3, NA)
)
latlong_hemisphere(df_na, latitude = lat, longitude = lon, drop_na = TRUE)
#> [latlong_hemisphere] 2 NA row(s) removed
#>    lat  lon NS_hemisphere EW_hemisphere
#> 1 51.5 -0.1         North          West

# Inspect rows removed by drop_na
result <- latlong_hemisphere(df_na, latitude = lat, longitude = lon,
                             drop_na = TRUE)
#> [latlong_hemisphere] 2 NA row(s) removed
attr(result, "removed_na")
#>     lat lon
#> 2    NA 2.3
#> 3 -33.9  NA
```
