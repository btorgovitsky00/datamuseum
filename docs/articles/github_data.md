# Accessing GitHub Data

## Description

The original accessions for the data sets included within `datamuseum`
are also available on GitHub. These are from the Global Biodiversity
Information Facility (GBIF), Invert-E-Base (InvBase), the Biological
Information System for Marine Life (BISMAL), Ocean Biodiversity
Information System (OBIS), and one data set obtained by direct request
from the National Museum of Nature and Science, Japan (NSMT).

In this workflow, accessing the GBIF-sourced data directly from the
GitHub repository for `datamuseum` will be demonstrated.

``` r
library(datamuseum)
```

Due to the size of the data, the files are stored within a .zip folder.
Luckily, R is capable of downloading and unzipping the files directly
from a GitHub link!

Each data set in `datamuseum` has two associated parent files: the
actual original accession from the respective repository (denoted as
“raw”), and a version with some columns removed for improved visibility
(“trim”).

The GBIF data sets were obtained and refined from the following
occurrence download:

> Global Biodiversity Information Facility (GBIF). GBIF.org (30 March
> 2026) GBIF Occurrence Download. <https://www.gbif.org>. doi:
> [10.15468/dl.2379hj](https://doi.org/10.15468/dl.2379hj)
