# Japan-filtered OBIS Octopodoidea occurrence records

Ocean Biodiversity Information System (OBIS) Octopodoidea occurrence
records filtered to the Japan bounding box (latitude 25–50, longitude
125–150) and standardized to the common column set shared across all
datamuseum Japan data sets. `SciName` is taken directly from the
`species` field. Rows with `NA` in `Source`, `Family`, `Genus`,
`SciName`, or `Year` are removed.

## Usage

``` r
OBIS_Japan
```

## Format

A data frame with 668 rows and 12 variables:

- SciName:

  Scientific name taken directly from the `species` field. Trailing `NA`
  strings removed.

- Genus:

  Genus name.

- Family:

  Family name.

- Year:

  Year of occurrence record, from `date_year`. Note this field differs
  from all other sources which use `year`.

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

Derived from the raw OBIS occurrence download. Full source CSVs (raw,
trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Ocean Biodiversity Information System (OBIS). Downloaded 30 March 2026.
<https://obis.org>

## Details

The raw and trimmed intermediate versions of this data set are available
as CSV files in the package data repository. Note that those files
contain non-ASCII characters in locality and collector name fields,
reflecting the international scope of OBIS occurrence records.

## See also

The raw and trimmed intermediate versions of this data set are available
as CSV files at <https://github.com/btorgovitsky00/datamuseum>.

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined data set including these records.
