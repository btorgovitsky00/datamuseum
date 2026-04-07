# Japan-filtered InvBase Octopodoidea occurrence records

Invert-E-Base (InvBase) Octopodoidea occurrence records filtered to the
Japan bounding box (latitude 25–50, longitude 125–150) and standardized
to the common column set shared across all datamuseum Japan data sets.
`SciName` is constructed by combining `Genus` and `specificEpithet` as
no combined name field is present in the source. Rows with `NA` in
`Source`, `Family`, `Genus`, `specificEpithet`, or `Year` are removed.

## Usage

``` r
InvBase_Japan
```

## Format

A data frame with 43 rows and 12 variables:

- SciName:

  Scientific name constructed from `Genus` and `specificEpithet`.
  Trailing `NA` strings removed.

- Genus:

  Genus name.

- Family:

  Family name.

- Year:

  Year of occurrence record, from `year`.

- Latitude:

  Decimal latitude, filtered to `[25, 50]`.

- Longitude:

  Decimal longitude, filtered to `[125, 150]`.

- Country:

  Country name, from `country`.

- Prefecture:

  State or province, from `stateProvince`.

- Precise Location:

  County field, from `county`.

- Source:

  Institution code, from `institutionCode`.

- catalogNumber:

  Museum lot identification code. Used for duplicate detection in
  [`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
  via
  [`deduplicate`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md).

- individualCount:

  Specimen count per lot. Used for row expansion in
  [`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
  via
  [`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md).

## Source

Derived from the raw InvBase occurrence download. Full source CSVs (raw,
trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Invert-E-Base. Downloaded 30 March 2026. <https://invertebase.org>

## See also

The raw and trimmed intermediate versions of this dataset are available
as CSV files at <https://github.com/btorgovitsky00/datamuseum>.

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined dataset including these records.
