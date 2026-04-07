# Japan-filtered NSMT Octopodoidea occurrence records

Japanese National Museum of Nature and Science (NSMT) Octopodoidea
occurrence records filtered to the Japan bounding box (latitude 25–50,
longitude 125–150) and standardized to the common column set shared
across all datamuseum Japan data sets. Unlike other sources, coordinate
columns were already named `Latitude` and `Longitude` in the raw data
and required no renaming. `SciName` is constructed from `Genus`,
`Species`, and `Subspecies`, with trailing `NA` strings removed to
handle records without a subspecies. This is the only source to
incorporate a subspecies component in `SciName`. No rows were removed by
the `NA` filter, giving the highest retention rate of all five sources
at 79.9% of raw records.

## Usage

``` r
NSMT_Japan
```

## Format

A data frame with 695 rows and 12 variables:

- SciName:

  Scientific name constructed from `Genus`, `Species`, and `Subspecies`
  where present. Trailing `NA` strings removed.

- Genus:

  Genus name.

- Family:

  Family name.

- Year:

  Year of occurrence record.

- Latitude:

  Decimal latitude, filtered to `[25, 50]`. Already named `Latitude` in
  the raw data.

- Longitude:

  Decimal longitude, filtered to `[125, 150]`. Already named `Longitude`
  in the raw data.

- Country:

  Country name.

- Prefecture:

  Region, from `Region`.

- Precise Location:

  Locality description, from `Previse.loc.` — note this reflects a
  typographic irregularity in the original NSMT data.

- Source:

  Museum group abbreviation, from `Group.Abb.`.

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

Derived from data obtained directly from the National Museum of Nature
and Science, Japan. Full source CSVs (raw, trimmed, and Japan-filtered)
are available at <https://github.com/btorgovitsky00/datamuseum>.

National Museum of Nature and Science, Japan (NSMT). Data obtained
directly from the museum, early 2024.
<https://www.kahaku.go.jp/english/>

## See also

The raw and trimmed intermediate versions of this data set are available
as CSV files at <https://github.com/btorgovitsky00/datamuseum>.

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined data set including these records.
