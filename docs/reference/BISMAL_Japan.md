# Japan-filtered BISMAL Octopodoidea occurrence records

Biological Information System for Marine Life (BISMAL) Octopodoidea
occurrence records filtered to the Japan bounding box (latitude 25–50,
longitude 125–150) and standardized to the common column set shared
across all datamuseum Japan data sets. `SciName` is constructed by
combining `Genus` and `specificEpithet` as no combined name field is
present in the source. Rows with `NA` in `Source`, `Family`, `Genus`,
`specificEpithet`, or `Year` are removed.

## Usage

``` r
BISMAL_Japan
```

## Format

A data frame with 473 rows and 12 variables:

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

  Locality description, from `locality`.

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

Derived from the raw BISMAL occurrence download. Full source CSVs (raw,
trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Biological Information System for Marine Life (BISMAL). Downloaded 30
March 2026. <https://www.godac.jamstec.go.jp/bismal/e/>

## See also

The raw and trimmed intermediate versions of this dataset are available
as CSV files at <https://github.com/btorgovitsky00/datamuseum>.

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined dataset including these records.
