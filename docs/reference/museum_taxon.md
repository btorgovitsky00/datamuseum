# Taxonomically validated and enriched Japan Octopodoidea records

The combined Japan Octopodoidea data set
([`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md))
after full taxonomic cleaning, validation, synonym resolution, rank
enrichment, authorship appending, and italic formatting. Represents the
final stage of the datamuseum workflow and is intended for direct use in
analysis and visualisation.

## Usage

``` r
museum_taxon
```

## Format

A data frame with 2,222 rows and 20 variables:

- SciName:

  Validated scientific name in accepted nomenclature, canonical form
  without authorship.

- Genus:

  Genus name, updated by
  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  where the primary name changed.

- Family:

  Family name.

- order:

  Taxonomic order, appended by
  [`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md).

- phylum:

  Taxonomic phylum, appended by
  [`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md).

- Year:

  Year of occurrence record.

- Latitude:

  Decimal latitude, filtered to `[25, 50]`.

- Longitude:

  Decimal longitude, filtered to `[125, 150]`.

- Country:

  Country name or code as recorded in the source data set.

- Prefecture:

  State, province, or region as recorded in the source data set.

- Precise Location:

  Locality description as recorded in the source data set.

- Source:

  Institution code or group abbreviation identifying the collecting
  institution.

- Data Frame:

  Character. Identifies the source data set for each row. One of
  `"GBIF"`, `"InvBase"`, `"BISMAL"`, `"OBIS"`, or `"NSMT"`.

- catalogNumber:

  Museum lot identification code.

- individualCount:

  Specimen count per lot.

- Family_cite:

  Family name with authorship appended by
  [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md).
  `Enteroctopodidae` authorship added manually as it could not be
  resolved automatically.

- Genus_cite:

  Genus name with authorship appended by
  [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md).

- SciName_cite:

  Scientific name with authorship appended by
  [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md).

- Genus_cite_italic:

  Plotmath italic expression for `Genus_cite`, suitable for use in
  ggplot2 via
  [`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md).

- SciName_cite_italic:

  Plotmath italic expression for `SciName_cite`, suitable for use in
  ggplot2 via
  [`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md).

## Source

Derived from
[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md).
Full source CSVs (raw, trimmed, and Japan-filtered) are available at
<https://github.com/btorgovitsky00/datamuseum>.

Original sources:

Global Biodiversity Information Facility (GBIF). GBIF.org (30 March
2026) GBIF Occurrence Download. <https://www.gbif.org>
[doi:10.15468/dl.2379hj](https://doi.org/10.15468/dl.2379hj)

Invert-E-Base. Downloaded 30 March 2026. <https://invertebase.org>

Biological Information System for Marine Life (BISMAL). Downloaded 30
March 2026. <https://www.godac.jamstec.go.jp/bismal/e/>

Ocean Biodiversity Information System (OBIS). Downloaded 30 March 2026.
<https://obis.org>

National Museum of Nature and Science, Japan (NSMT). Data obtained
directly from the museum, early 2024.
<https://www.kahaku.go.jp/english/>

## Details

Processing proceeds in the following steps from
[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md):

1.  [`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
    applied to `SciName` in place with `drop_na = TRUE`, removing
    uncertain names and reducing the data set from 2,633 to 2,222
    observations.

2.  *Octopus vulgaris* manually corrected to *Octopus sinensis* to
    reflect current accepted taxonomy for the Pacific form.

3.  [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
    applied to `SciName` with `update_related = TRUE` to resolve
    synonyms and update related taxonomic columns.

4.  [`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
    applied with `update = TRUE` using the pre-computed validation
    report.

5.  *Pinnoctopus* manually corrected to *Callistoctopus* across all
    columns — a generic synonym not resolved automatically by
    [`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md).

6.  [`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
    appends `order` and `phylum` with `sort = TRUE`.

7.  [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
    appends authorship to `Family`, `Genus`, and `SciName`.

8.  *Muusoctopus small in mature* removed as an informal morphospecies
    name not representing a valid taxon.

9.  `Enteroctopodidae` authorship added manually as it could not be
    resolved by
    [`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md).

10. [`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
    applied to `Genus_cite` and `SciName_cite`.

## See also

[`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
for the combined pre-validation data set,

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for the cleaning function applied during processing,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for the validation function applied during processing,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for the spellcheck function applied during processing,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for the rank enrichment function applied during processing,

[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
for the authorship appending function applied during processing,

[`italicize`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
for the italic formatting function applied during processing.
