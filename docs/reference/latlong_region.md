# Filter rows by geographic region

Retains only rows whose coordinates fall within one or more named
geographic regions. Supports countries, sovereign territories, broader
geographic regions, and named marine areas including seas, bays, gulfs,
straits, and ocean basins via Natural Earth data. Region terms are
matched case-insensitively across all available name fields in both land
and marine polygon layers.

## Usage

``` r
latlong_region(
  data,
  latitude,
  longitude,
  region,
  dataset = "auto",
  drop_na = FALSE
)
```

## Arguments

- data:

  A data frame containing coordinate columns.

- latitude:

  Column name of the latitude column, supplied either unquoted (`lat`)
  or quoted (`"lat"`). Must contain numeric decimal degree values.

- longitude:

  Column name of the longitude column, supplied either unquoted (`lon`)
  or quoted (`"lon"`). Must contain numeric decimal degree values.

- region:

  Character vector of region names to match. Partial and
  case-insensitive matching is supported across country names, sovereign
  states, administrative regions, subregions, continents, and named
  marine areas such as seas, gulfs, and straits. Multiple values are
  unioned before filtering (e.g. `c("Japan", "Sea of Japan")` retains
  rows in either area).

- dataset:

  Character. Natural Earth dataset scale to use. Default is `"auto"`.

- drop_na:

  Logical. If `TRUE`, rows with `NA` in either coordinate column are
  dropped before filtering. Default is `FALSE`.

## Value

A data frame containing only rows whose coordinates fall within the
union of all matched region polygons, with the same columns as `data`.
Console messages report the matched country and geographic region names,
the number of rows retained, and the number excluded outside the
specified regions.

## Details

Two Natural Earth polygon layers are queried: country polygons covering
land territories, regions, subregions, and continents; and geographic
region polygons covering named marine and physical features. Each
`region` term is matched against all available name fields in both
layers, and all matched polygons are unioned into a single bounding
geometry before the spatial filter is applied.

Shapefiles are downloaded via
[`rnaturalearth::ne_download`](https://docs.ropensci.org/rnaturalearth/reference/ne_download.html)
on first use and cached locally — subsequent calls with the same dataset
are fast. Requires the rnaturalearth and sf packages; an informative
error is raised if either is not installed.

Coordinate columns must be in decimal degrees. Use
[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
to convert DMS or base-60 columns first. Use
[`latlong_limits`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_limits.md)
to inspect the coordinate extent of the data before choosing region
terms, and
[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
to remove invalid coordinates beforehand.

An error is raised if no polygons match any of the supplied `region`
terms across either layer.

## See also

[`latlong_limits`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_limits.md)
for inspecting coordinate extent before choosing region terms,

[`latlong_filter`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
for removing invalid coordinates before filtering,

[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
for filtering to a user-defined bounding box rather than a named region,

[`latlong_split`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
for separating a combined coordinate column into distinct latitude and
longitude columns before filtering as
[`latlong_range`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
does not function with combined columns,

[`latlong_convert`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
for converting DMS or base-60 columns to decimal degrees before
filtering.

## Examples

``` r
# \donttest{
if (requireNamespace("rnaturalearth", quietly = TRUE) &&
    requireNamespace("sf", quietly = TRUE)) {
df <- data.frame(
  id  = 1:4,
  lat = c(35.6, 34.0, 51.5, 48.8),
  lon = c(139.7, 131.0, -0.1, 2.3)
)

# Filter to a single country
latlong_region(df, latitude = lat, longitude = lon,
               region = "Japan")

# Filter to multiple regions — land and marine areas unioned
latlong_region(df, latitude = lat, longitude = lon,
               region = c("Japan", "Sea of Japan", "East China Sea"))

# Filter to a continent
latlong_region(df, latitude = lat, longitude = lon,
               region = "Europe")

# Drop NA rows before filtering
latlong_region(df, latitude = lat, longitude = lon,
               region = "Japan", drop_na = TRUE)
}
#> Reading ne_50m_geography_regions_polys.zip from naturalearth...
#> [latlong_region] countries/territories matched: Japan
#> [latlong_region] 1 row(s) retained, 3 row(s) excluded outside region(s)
#> Reading ne_50m_geography_regions_polys.zip from naturalearth...
#> [latlong_region] countries/territories matched: Japan
#> [latlong_region] 1 row(s) retained, 3 row(s) excluded outside region(s)
#> Reading ne_50m_geography_regions_polys.zip from naturalearth...
#> [latlong_region] countries/territories matched: Vatican, Jersey, Guernsey, Isle of Man, United Kingdom, Ukraine, Switzerland, Sweden, Spain, Slovakia, Slovenia, Serbia, San Marino, Russian Federation, Romania, Portugal, Poland, Norway, Netherlands, Montenegro, Moldova, Monaco, Malta, North Macedonia, Luxembourg, Lithuania, Liechtenstein, Latvia, Kosovo, Italy, Ireland, Iceland, Hungary, Greece, Germany, France, Åland Islands, Finland, Estonia, Faeroe Islands, Denmark, Czech Republic, Croatia, Bulgaria, Bosnia and Herzegovina, Belgium, Belarus, Austria, Andorra, Albania, Uzbekistan, Turkmenistan, Turkey, Tajikistan, Kyrgyzstan, Kazakhstan, Georgia, Greenland, Northern Cyprus, Cyprus, Azerbaijan, Armenia
#> [latlong_region] 2 row(s) retained, 2 row(s) excluded outside region(s)
#> [latlong_region] 0 NA row(s) removed
#> Reading ne_50m_geography_regions_polys.zip from naturalearth...
#> [latlong_region] countries/territories matched: Japan
#> [latlong_region] 1 row(s) retained, 3 row(s) excluded outside region(s)
#>   id  lat   lon
#> 1  1 35.6 139.7
# }
```
