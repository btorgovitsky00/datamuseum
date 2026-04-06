# Check the format of coordinate columns

Detects and reports the coordinate format – decimal degrees, DMS
(`DDdeg.MM'SS''}), or base-60 (\code{DDdeg.MM'`) – of values in one or
more columns. Combined columns (latitude and longitude stored as a
single delimited string) are split before format detection. Results are
returned as a named list, one element per column.

## Usage

``` r
latlong_format(data, columns, sep = ",", drop_na = TRUE)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- columns:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to check, supplied either unquoted (`lat`) or quoted (`"lat"`).

- sep:

  Character. Separator used to split combined coordinate columns before
  format detection. Default is `","`.

- drop_na:

  Logical. If `TRUE`, values that do not match any recognized coordinate
  format are excluded before summarizing results. Default is `TRUE`.

## Value

A named list with one element per column in `columns`. Each element is
itself a named list with two components:

- `format`:

  Character vector of detected format names present in the column. One
  or more of `"decimal"`, `"dms"`, `"base60"`. Returns `"unknown"` if no
  values match any recognised format (or if all values are excluded by
  `drop_na`).

- `counts`:

  Integer vector of the same length as `format`, giving the number of
  values matching each detected format.

## Details

The three recognised coordinate formats are:

- Decimal degrees: `"-12.345"` or `"51.5"`

- DMS: `"12deg.34'56''N"`

- Base-60: `"12deg.34'N"`

A column may return multiple formats if values are inconsistently
formatted – for example, a mix of decimal and DMS entries. This is
reported rather than resolved, allowing the user to decide how to handle
mixed formats before passing columns to
[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
or
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md).

Combined columns (those containing `sep`) are detected automatically and
split before format checking, so the same `sep` used in
[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
or
[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
should be passed here for consistent results.

## See also

[`latlong_column`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
for detecting which columns in a data frame contain coordinates,

[`latlong_combine`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
for merging separate coordinate columns into one,

[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
for splitting a combined coordinate column into separate latitude and
longitude columns,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing invalid coordinates after checking formats,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting coordinate formats after checking.

## Examples

``` r
df <- data.frame(
  id  = 1:4,
  lat = c("51.5", "48.8", "40.7", "35.6"),
  lon = c("-0.1", "2.3", "-74.0", "139.7")
)

# Check format of a single column
latlong_format(df, lat)
#> $lat
#> $lat$format
#> [1] "decimal"
#> 
#> $lat$counts
#> [1] 4
#> 
#> 

# Check multiple columns at once
latlong_format(df, c(lat, lon))
#> $lat
#> $lat$format
#> [1] "decimal"
#> 
#> $lat$counts
#> [1] 4
#> 
#> 
#> $lon
#> $lon$format
#> [1] "decimal"
#> 
#> $lon$counts
#> [1] 4
#> 
#> 

# Mixed formats in one column
df_mixed <- data.frame(
  coords = c("51.5", "48deg.52'N", "40.7", "35deg.36'00''N")
)
latlong_format(df_mixed, coords)
#> $coords
#> $coords$format
#> [1] "decimal" "dms"     "base60" 
#> 
#> $coords$counts
#> [1] 2 1 1
#> 
#> 

# Combined latitude-longitude column with custom separator
df_combined <- data.frame(
  latlon = c("51.5;-0.1", "48.8;2.3", "40.7;-74.0")
)
latlong_format(df_combined, latlon, sep = ";")
#> $latlon
#> $latlon$format
#> [1] "decimal"
#> 
#> $latlon$counts
#> [1] 6
#> 
#> 

# Include unknown-format values in counts
df_dirty <- data.frame(
  lat = c("51.5", "not_a_coord", "40.7", NA)
)
latlong_format(df_dirty, lat, drop_na = FALSE)
#> $lat
#> $lat$format
#> [1] "decimal"
#> 
#> $lat$counts
#> [1] 2
#> 
#> 
```
