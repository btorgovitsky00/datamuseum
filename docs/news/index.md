# Changelog

## datamuseum 0.1.0

Initial release of `datamuseum` to GitHub.

- Functions for managing latitude and longitude data (`latlong_*`).
- Functions for managing taxonomic data (`taxon_*`).
- Utility functions for data set management (`deduplicate`, `duplicate`,
  `italicize`).
- Example Octopodoidea occurrence datasets for Japan from the [Global
  Biodiversity Information Facility (GBIF)](https://www.gbif.org),
  [Invert-E-Base (InvBase)](https://invertebase.org), the [Biological
  Information System for Marine Life
  (BISMAL)](https://www.godac.jamstec.go.jp/bismal/e/), the [Ocean
  Biodiversity Information System (OBIS)](https://obis.org), and one
  dataset obtained by direct request from the [National Museum of Nature
  and Science, Japan (NSMT)](https://www.kahaku.go.jp/english/).
- Example workflow for `datamuseum` with the article [Octopodoidea in
  Japan](https://btorgovitsky00.github.io/datamuseum/articles/octopodoidea_japan.html).
  Shows the pipeline for combining the accessioned datasets into one
  combined dataset
  [`museum`](https://btorgovitsky00.github.io/datamuseum/reference/museum.html)
  and processing that data further with various `datamuseum` functions
  into the included dataset
  [`museum_taxon`](https://btorgovitsky00.github.io/datamuseum/reference/museum_taxon.html).
- Article added demonstrating how to access the raw and trimmed source
  datasets from the `datamuseum` GitHub repository: [Accessing GitHub
  Data](https://btorgovitsky00.github.io/datamuseum/articles/github_data.html).
