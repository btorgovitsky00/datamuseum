# Convert coordinate formats

Converts coordinate columns between decimal degrees, DMS (`DD°MM′SS″`),
and base-60 (`DD°MM′`) formats. Handles separate latitude and longitude
columns as well as combined coordinate columns. Columns are converted in
place; combined columns may optionally be split into separate latitude
and longitude columns.

## Usage

``` r
latlong_convert(
  data,
  column,
  convert = "decimal",
  type = "auto",
  drop_na = FALSE,
  split_combined = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- column:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to convert, supplied either unquoted (`lat`) or quoted (`"lat"`).

- convert:

  Character. Target coordinate format. One of `"decimal"` (default),
  `"dms"`, or `"base60"`.

- type:

  Character. Coordinate type used for direction suffix assignment in DMS
  and base-60 output. One of `"auto"` (default), `"lat"`, or `"lon"`.
  When `"auto"`, type is inferred from the column name (matching `"lat"`
  or `"lon"`/`"lng"`/`"long"`) or from the value range if the name is
  uninformative.

- drop_na:

  Logical. If `TRUE`, rows where any converted column contains `NA` are
  dropped after conversion. Default is `FALSE`.

- split_combined:

  Logical. If `TRUE`, combined coordinate columns are split into two new
  columns named `<column>_lat` and `<column>_lon` rather than kept as a
  single combined column. Default is `FALSE`.

## Value

The input data frame with converted coordinate columns. For non-combined
columns, the original column is overwritten with the converted values.
For combined columns, behavior depends on `split_combined`:

- If `FALSE`, the combined column is overwritten with converted values
  in the same delimited format.

- If `TRUE`, two new columns are appended — `<column>_lat` and
  `<column>_lon` — and the original column is retained.

When `convert = "decimal"`, output columns are numeric. For `"dms"` and
`"base60"`, output columns are character.

## Details

All input formats are first parsed to decimal degrees internally before
conversion. The parser handles decimal, DMS, and base-60 formats,
inferring sign from cardinal direction suffixes (`S`, `W`) or the sign
of the degree value. Zero-width and BOM characters are stripped before
parsing.

Combined columns are detected automatically by the presence of two or
more numeric components in a single value. The separator used to split
combined columns is assumed to be `","`; use
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
if a custom separator is needed before converting.

Direction suffixes (`N`, `S`, `E`, `W`) are appended to DMS and base-60
output when `type` can be determined. If `type = "auto"` and the type
cannot be inferred from the column name or value range, no suffix is
added.

Use
[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
to check input formats before conversion, and
[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
to remove out-of-range values beforehand.

## See also

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking coordinate formats before conversion,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing out-of-range coordinates before conversion,

[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
for splitting combined columns with a custom separator prior to
conversion,

[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
for merging separate coordinate columns after conversion,

[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
for filtering to a bounding box after converting to decimal degrees,

[`latlong_region`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md)
for filtering to named geographic regions after converting to decimal
degrees.

## Examples

``` r
df <- data.frame(
  id  = 1:4,
  lat = c(51.5, 48.8, -33.9, 40.7),
  lon = c(-0.1, 2.3, 151.2, -74.0)
)

# Convert decimal columns to DMS
latlong_convert(df, c(lat, lon), convert = "dms")
#> [latlong_convert] NA rows removed: 0
#>   id        lat         lon
#> 1  1  51°30′0″N     0°6′0″W
#> 2  2 48°47′60″N   2°17′60″E
#> 3  3 33°53′60″S 151°11′60″E
#> 4  4  40°42′0″N    74°0′0″W

# Convert to base-60
latlong_convert(df, c(lat, lon), convert = "base60")
#> [latlong_convert] NA rows removed: 0
#>   id     lat      lon
#> 1  1 51°30′N    0°6′W
#> 2  2 48°48′N   2°18′E
#> 3  3 33°54′S 151°12′E
#> 4  4 40°42′N   74°0′W

# Convert a single column, specifying coordinate type explicitly
latlong_convert(df, lat, convert = "dms", type = "lat")
#> [latlong_convert] NA rows removed: 0
#>   id        lat   lon
#> 1  1  51°30′0″N  -0.1
#> 2  2 48°47′60″N   2.3
#> 3  3 33°53′60″S 151.2
#> 4  4  40°42′0″N -74.0

# Convert a combined column and keep as single column
df_combined <- data.frame(
  coords = c("51.5,-0.1", "48.8,2.3", "-33.9,151.2")
)
latlong_convert(df_combined, coords, convert = "dms")
#> [latlong_convert] NA rows removed: 0
#>                    coords
#> 1      51°30′0″N, 0°6′0″W
#> 2   48°47′60″N, 2°17′60″E
#> 3 33°53′60″S, 151°11′60″E

# Convert a combined column and split into separate lat/lon columns
latlong_convert(df_combined, coords, convert = "decimal",
                split_combined = TRUE)
#> [latlong_convert] NA rows removed: 0
#>        coords coords_lat coords_lon
#> 1   51.5,-0.1       51.5       -0.1
#> 2    48.8,2.3       48.8        2.3
#> 3 -33.9,151.2      -33.9      151.2

# Drop rows that produce NA after conversion
df_na <- data.frame(
  lat = c(51.5, NA, 40.7),
  lon = c(-0.1, 2.3, -74.0)
)
latlong_convert(df_na, c(lat, lon), convert = "dms", drop_na = TRUE)
#> [latlong_convert] NA rows removed: 1
#>         lat      lon
#> 1 51°30′0″N  0°6′0″W
#> 3 40°42′0″N 74°0′0″W
```
