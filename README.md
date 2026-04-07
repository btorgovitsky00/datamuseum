# datamuseum <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/datamuseum)](https://CRAN.R-project.org/package=datamuseum)
<!-- badges: end -->

## Overview

`datamuseum` provides functions and practice data sets for the management
and refinement of biological specimens with geographic and/or taxonomic
information.

The package contents are organized into four main categories:

- **Coordinate functions** (`latlong_*`) — refine geographic information
  associated with biological specimens
  
- **Taxonomic functions** (`taxon_*`) — clean and validate taxonomies
  against the Global Biodiversity Information Facility (via
  [`rgbif`](https://CRAN.R-project.org/package=rgbif)) and the Integrated
  Taxonomic Information System (ITIS, via
  [`taxize`](https://CRAN.R-project.org/package=taxize))
  
- **Utilities** — miscellaneous functions for data set management and
  improved graphical outputs
  
- **Example data** — Japan-filtered occurrence records for specimens
  belonging to Superfamily Octopodoidea, compiled from the Global
  Biodiversity Information Facility
  ([GBIF](https://www.gbif.org)), Invert-E-Base
  ([InvBase](https://invertebase.org)), the Biological Information System
  for Marine Life ([BISMAL](https://www.godac.jamstec.go.jp/bismal/e/)), the Ocean
  Biodiversity Information System ([OBIS](https://obis.org)), and the
  National Museum of Nature and Science, Japan
  ([NSMT](https://www.kahaku.go.jp/english/)), as well as the compiled data sets
  processed through `datamuseum`

## Installation

Install the released version from CRAN:
```r
install.packages("datamuseum")
```

Or install the development version from GitHub:
```r
# install.packages("devtools")
devtools::install_github("btorgovitsky00/datamuseum")
```

## Usage

`datamuseum` serves as a tool for researchers of all levels and backgrounds,
as well as a pathway for improved data access from legacy sources like museum
collections.

```r
library(datamuseum)

# Remove duplicate catalogue numbers
df <- deduplicate(df, id_col = "catalogNumber", drop_na = TRUE)

# Filter occurrence data to a geographic bounding box
japan_data <- latlong_range(df, latitude = "Latitude", longitude = "Longitude",
                            lat_min = 25, lat_max = 50,
                            lon_min = 125, lon_max = 150)

# Clean taxonomic names
df <- taxon_cleaner(df, columns = "Genus", drop_na = TRUE)

# Validate against GBIF
df <- taxon_validate(df, column = "Genus", source = "gbif")

# Append higher taxonomic ranks
df <- taxon_add(df, column = "Genus", ranks = c("order", "phylum"))

# Append authorship strings
df <- taxon_cite(df, columns = c("Family", "Genus", "Genus"))

```

## Getting help

- Full documentation and vignettes: <https://btorgovitsky00.github.io/datamuseum>
- Report bugs: <https://github.com/btorgovitsky00/datamuseum/issues>

## Citation
```r
citation("datamuseum")
```

## License

MIT © [Bryson Y. Torgovitsky](https://www.linkedin.com/in/bryson-torgovitsky/), [Cheryl L. Ames](https://https://cherylames.com/meet-the-lab/)

The `datamuseum` hex logo was designed by [Sophie Collier](https://www.linkedin.com/in/sophie-collier-2160532a9/).
