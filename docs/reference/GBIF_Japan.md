# Japan-filtered GBIF Octopodoidea occurrence records

Global Biodiversity Information Facility (GBIF) Octopodoidea occurrence
records filtered to the Japan bounding box (latitude 25–50, longitude
125–150) and standardized to the common column set shared across all
datamuseum Japan datasets. Rows with `NA` in `Source`, `Family`,
`Genus`, `SciName`,or `Year` are removed.

## Usage

``` r
GBIF_Japan
```

## Format

A data frame with 798 rows and 12 variables:

- SciName:

  Scientific name as recorded in GBIF, taken directly from the `species`
  field. Trailing `NA` strings removed.

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

  Country code, from `countryCode`.

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

Derived from the raw GBIF occurrence download. Full source CSVs (raw,
trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Global Biodiversity Information Facility (GBIF). GBIF.org (30 March
2026) GBIF Occurrence Download. <https://www.gbif.org>
[doi:10.15468/dl.2379hj](https://doi.org/10.15468/dl.2379hj)

## Details

The raw and trimmed intermediate versions of this dataset are available
as CSV files in the package data repository. Note that those files
contain non-ASCII characters in locality and collector name fields,
reflecting the international scope of GBIF occurrence records.

## See also

The raw and trimmed intermediate versions of this dataset are available
as CSV files at <https://github.com/btorgovitsky00/datamuseum>.

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined dataset including these records.
