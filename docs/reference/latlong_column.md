# Identify coordinate columns in a data frame

Detects latitude, longitude, and combined coordinate columns based on
value ranges and format matching. Supports decimal degree, DMS
(`DD°MM′SS″`), and base-60 (`DD°MM′`) coordinate formats. Returns a
named list with elements `combined`, `latitude`, and `longitude`, each
containing the names and indices of detected columns.

## Usage

``` r
latlong_column(data, sep = ",")
```

## Arguments

- data:

  A data frame to search for coordinate columns.

- sep:

  Character. Separator used to split combined coordinate columns (i.e.
  columns containing both latitude and longitude as a single string).
  Default is `","`.

## Value

A named list with three elements:

- `combined`:

  Columns containing both latitude and longitude as a single delimited
  string (e.g. `"51.5,-0.1"`).

- `latitude`:

  Columns containing latitude values only. Numeric range is constrained
  to `[-90, 90]`.

- `longitude`:

  Columns containing longitude values only. Numeric range is constrained
  to `[-180, 180]`. Columns already assigned to `combined` or `latitude`
  are excluded.

Each element is a named list mapping column name to column index in
`data`. An empty named list
([`list()`](https://rdrr.io/r/base/list.html)) is returned for any
coordinate type not detected.

## Details

Detection follows this priority order: combined columns are identified
first, then latitude, then longitude. A column can only appear in one
category — latitude candidates are excluded from longitude, and combined
candidates are excluded from both.

The three recognised coordinate formats are:

- Decimal degrees: `"-12.345"` or `"51.5"`

- DMS: `"12°34′56″N"`

- Base-60: `"12°34′N"`

Detection is based on value content, not column names, so columns with
non-standard names (e.g. `"point_y"`) will still be detected provided
their values match a recognized coordinate format and pass the range
check. At least one valid coordinate value is required for a column to
be detected.

## See also

[`latlong_format`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
for checking the coordinate format of detected columns,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing invalid coordinates from detected columns.

[`st_as_sf`](https://r-spatial.github.io/sf/reference/st_as_sf.html) for
converting detected coordinate columns to an `sf` spatial object,

[`geocode`](https://jessecambon.github.io/tidygeocoder/reference/geocode.html)
for adding coordinates to a data frame from address strings.

## Examples

``` r
df <- data.frame(
  id  = 1:6,
  lat = c(51.5, 48.8, 40.7, 35.6, -33.9, 55.8),
  lon = c(-0.1, 2.3, -74.0, 139.7, 151.2, 37.6)
)

# Detect separate latitude and longitude columns
latlong_column(df)
#> $combined
#> named list()
#> 
#> $latitude
#> $latitude$id
#> [1] 1
#> 
#> $latitude$lat
#> [1] 2
#> 
#> 
#> $longitude
#> $longitude$lon
#> [1] 3
#> 
#> 

# Access detected column names and indices
result <- latlong_column(df)
result$latitude
#> $id
#> [1] 1
#> 
#> $lat
#> [1] 2
#> 
result$longitude
#> $lon
#> [1] 3
#> 

# Detect a combined coordinate column
df2 <- data.frame(
  id     = 1:6,
  coords = c("51.5,-0.1", "48.8,2.3", "40.7,-74.0",
             "35.6,139.7", "-33.9,151.2", "55.8,37.6")
)
latlong_column(df2)
#> $combined
#> $combined$coords
#> [1] 2
#> 
#> 
#> $latitude
#> $latitude$id
#> [1] 1
#> 
#> 
#> $longitude
#> named list()
#> 

# Use a custom separator for combined columns
df3 <- data.frame(
  coords = c("51.5;-0.1", "48.8;2.3", "40.7;-74.0",
             "35.6;139.7", "-33.9;151.2", "55.8;37.6")
)
latlong_column(df3, sep = ";")
#> $combined
#> $combined$coords
#> [1] 1
#> 
#> 
#> $latitude
#> named list()
#> 
#> $longitude
#> named list()
#> 
```
