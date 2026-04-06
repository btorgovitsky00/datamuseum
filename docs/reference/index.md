# Package index

## latlong

Functions for managing latitude and longitude data.

- [`latlong_column()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_column.md)
  : Identify coordinate columns in a data frame
- [`latlong_convert()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_convert.md)
  : Convert coordinate formats
- [`latlong_combine()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_combine.md)
  : Combine separate coordinate columns into one
- [`latlong_filter()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_filter.md)
  : Filter rows by real-world coordinate validity
- [`latlong_format()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_format.md)
  : Check the format of coordinate columns
- [`latlong_limits()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_limits.md)
  : Report coordinate limits of a data frame
- [`latlong_hemisphere()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_hemisphere.md)
  : Assign hemispheres to coordinates
- [`latlong_range()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_range.md)
  : Filter rows by coordinate range
- [`latlong_region()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_region.md)
  : Filter rows by geographic region
- [`latlong_split()`](https://btorgovitsky00.github.io/datamuseum/reference/latlong_split.md)
  : Split a combined coordinate column into separate columns

## taxon

Functions for managing taxonomic data.

- [`taxon_add()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
  : Add higher taxonomic rank columns
- [`taxon_cite()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
  : Append authorship and year to taxonomic name columns
- [`taxon_cleaner()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
  : Clean taxonomic name formatting
- [`taxon_column()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
  : Identify taxonomic columns
- [`taxon_columntype()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_columntype.md)
  : Detect the taxonomic rank of a column
- [`taxon_combine()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_combine.md)
  : Combine genus and epithet columns into a binomial name
- [`taxon_spellcheck()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
  : Check and correct taxonomic name spelling
- [`taxon_split()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_split.md)
  : Split a binomial name column into genus and epithet
- [`taxon_sort()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
  : Sort columns into standard taxonomic rank order
- [`taxon_validate()`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
  : Validate taxonomic names against ITIS and GBIF

## Utilities

General-purpose functions for data set management.

- [`deduplicate()`](https://btorgovitsky00.github.io/datamuseum/reference/deduplicate.md)
  : Remove duplicate rows
- [`duplicate()`](https://btorgovitsky00.github.io/datamuseum/reference/duplicate.md)
  : Duplicate rows by a count column
- [`italicize()`](https://btorgovitsky00.github.io/datamuseum/reference/italicize.md)
  : Format taxonomic names for italic display in ggplot2

## Example Data

Octopodoidea occurrence datasets for Japan compiled from five museum and
biodiversity sources, then compiled and refined with taxon functions.

- [`GBIF_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/GBIF_Japan.md)
  : Japan-filtered GBIF Octopodoidea occurrence records
- [`InvBase_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/InvBase_Japan.md)
  : Japan-filtered InvBase Octopodoidea occurrence records
- [`BISMAL_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/BISMAL_Japan.md)
  : Japan-filtered BISMAL Octopodoidea occurrence records
- [`OBIS_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/OBIS_Japan.md)
  : Japan-filtered OBIS Octopodoidea occurrence records
- [`NSMT_Japan`](https://btorgovitsky00.github.io/datamuseum/reference/NSMT_Japan.md)
  : Japan-filtered NSMT Octopodoidea occurrence records
- [`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.md)
  : Combined Japan Octopodoidea occurrence records
- [`museum_taxon`](https://btorgovitsky00.github.io/datamuseum/reference/museum_taxon.md)
  : Taxonomically validated and enriched Japan Octopodoidea records
