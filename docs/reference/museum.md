# Combined Japan Octopodoidea occurrence records

Combined Octopodoidea occurrence records for Japan produced by merging
the five Japan-filtered source datasets
([`GBIF_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/GBIF_Japan.md),
[`InvBase_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/InvBase_Japan.md),
[`BISMAL_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/BISMAL_Japan.md),
[`OBIS_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/OBIS_Japan.md),
and
[`NSMT_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/NSMT_Japan.md))
via `rbind`. Duplicate records are removed using
[`deduplicate`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md)
on the `catalogNumber` field, and individual-level records are
reconstructed from aggregated specimen counts using
[`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
on the `individualCount` field. See
[`museum_taxon`](https://btorgovitsky00.github.io/datamuseum/reference/museum_taxon.md)
for the taxonomically validated and enriched version.

## Usage

``` r
museum
```

## Format

A data frame with 2,633 rows and 13 variables:

- SciName:

  Scientific name as recorded in the source dataset.

- Genus:

  Genus name.

- Family:

  Family name.

- Year:

  Year of occurrence record.

- Latitude:

  Decimal latitude, filtered to `[25, 50]`.

- Longitude:

  Decimal longitude, filtered to `[125, 150]`.

- Country:

  Country name or code as recorded in the source dataset.

- Prefecture:

  State, province, or region as recorded in the source dataset.

- Precise Location:

  Locality description as recorded in the source dataset.

- Source:

  Institution code or group abbreviation identifying the collecting
  institution.

- Data Frame:

  Character. Identifies the source dataset for each row. One of
  `"GBIF"`, `"InvBase"`, `"BISMAL"`, `"OBIS"`, or `"NSMT"`.

- catalogNumber:

  Museum lot identification code used for duplicate detection. Rows with
  `NA` in this field were removed during deduplication.

- individualCount:

  Specimen count per lot. Used to expand rows via
  [`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
  to reconstruct individual-level records.

## Source

Derived from
[`GBIF_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/GBIF_Japan.md),
[`InvBase_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/InvBase_Japan.md),
[`BISMAL_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/BISMAL_Japan.md),
[`OBIS_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/OBIS_Japan.md),
and
[`NSMT_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/NSMT_Japan.md).
Full source CSVs (raw, trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Original sources:

Global Biodiversity Information Facility (GBIF). GBIF.org (30 March
2026) GBIF Occurrence Download. <https://www.gbif.org>
[doi:10.15468/dl.2379hj](https://doi.org/10.15468/dl.2379hj)

Invert-E-Base. Downloaded 30 March 2026. <https://invertebase.org>

Biological Information System for Marine Life (BISMAL). Downloaded 30
March 2026. <https://bismal.nisc.go.jp>

Ocean Biodiversity Information System (OBIS). Downloaded 30 March 2026.
<https://obis.org>

National Museum of Nature and Science, Japan (NSMT). Data obtained
directly from the museum, early 2024. <https://www.kahaku.go.jp>

## Details

Processing proceeds in the following steps:

1.  The five Japan-filtered datasets are combined via `rbind` with a
    `Data Frame` column added to identify the source of each row,
    producing 2,707 observations.

2.  [`deduplicate`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md)
    is applied on `catalogNumber` with `drop_na = TRUE`, removing 608
    rows with missing `catalogNumber` and 143 duplicate rows, leaving
    1,956 observations. Duplicate records are accessible via
    `attr(museum, "duplicates")`.

3.  [`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
    is applied on `individualCount` to expand aggregated specimen counts
    to individual-level records, increasing the row count from 1,956 to
    2,633.

## See also

[`GBIF_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/GBIF_Japan.md),
[`InvBase_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/InvBase_Japan.md),
[`BISMAL_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/BISMAL_Japan.md),
[`OBIS_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/OBIS_Japan.md),
[`NSMT_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/NSMT_Japan.md)
for the individual source datasets,

[`deduplicate`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md)
for the deduplication function applied during processing,

[`duplicate`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
for the row expansion function applied during processing,

[`museum_taxon`](https://btorgovitsky00.github.io/datamuseum/reference/museum_taxon.md)
for the taxonomically validated and enriched version.
