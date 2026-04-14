# Get Started

`datamuseum` is an R package designed to improve specimen management and
improve access to legacy databases. This extends from first steps, such
as removing samples with unclear or missing labels, to aesthetic
improvements intended for publishable tables and figures.

`datamuseum` is categorized into four main parts, and each will be
described briefly here. Please refer to our
[Articles](https://btorgovitsky00.github.io/datamuseum/articles/) for
more in-depth workflows and breakdowns.

## Geographic Data

`datamuseum` includes a host of functions designed for manipulating and
refining geographic data. Although the package as a whole is intended
for biological samples, functions in the `latlong_*` group are
universally applicable.

Management with `datamuseum` is done in part with
[`rnaturalearth`](https://CRAN.R-project.org/package=rnaturalearth),
which provides a standard reference for geography and works alongside
other functions of the package to ensure mappable data is consistent and
ready for display with other packages like
[`ggplot2`](https://CRAN.R-project.org/package=ggplot2).

## Taxonomic Data

At its core, `datamuseum` is intended for use with biological specimen
data sets, with a focus on taxonomy. `datamuseum` accomplishes the task
of robust taxonomic review in its taxon function group through a
dual-reference system which checks against the Global Biodiversity
Information Facility’s rGBIF package, and the Integrated Taxonomic
Information System via taxize. Users have the option to use GBIF, ITIS,
or both for their taxonomic inquiries.

`datamuseum` is only as good as its sources, and user input is
occasionally essential. Although its ability to double-check provides
safety against misspellings or inconsistent updates, some cases may
still arise where manual changes are still necessary.

## Example Data

In lieu of its limitations, `datamuseum` includes practice data in the
form of accessioned octopus specimen data sets refined to Japan.
Superfamily Octopodoidea was selected and refined to Japan due to the
long history of octopus fisheries and cuisine in the region, as well as
recent regional taxonomic updates.

More specifically, *Octopus vulgaris* (Cuvier, 1797) in East Asia was
recently re-described as the also valid *Octopus sinensis* (d’Orbigny,
1834) by [Gleadall et
al. (2016)](https://www.jstage.jst.go.jp/article/specdiv/21/1/21_31/_article).
`datamuseum` would struggle to reflect a regional change like this since
both species are still valid and accepted by GBIF and ITIS. As a result,
we recommend adding a simple command like the one below to your
`datamuseum` workflow for case-specific changes.

This code, and its broader workflow with associated `taxon_*` and
`latlong_*` functions, can also be found at [Octopodoidea in
Japan](https://btorgovitsky00.github.io/datamuseum/articles/octopodoidea_japan.html).

``` r
museum_clean <- museum_clean %>% 
  mutate(SciName = case_when(
    SciName == "Octopus vulgaris"        ~ "Octopus sinensis",
    TRUE                                 ~ SciName
  ))
```

## Utilities

Going beyond manipulating just geographic and taxonomic data,
`datamuseum` also provides management options for accessioned data sets.
This includes options for removing repeat data (deduplicating) when
multiple sources are accessioned, expanding your data set when one
specimen lot contains multiple individuals, and preparing your taxonomic
data for presentation on a ggplot2 graph!
