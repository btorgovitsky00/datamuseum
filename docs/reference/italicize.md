# Format taxonomic names for italic display in ggplot2

Converts taxonomic names in one or more columns to plotmath italic
expressions suitable for use in ggplot2 axis labels or legends via
[`ggplot2::label_parsed`](https://ggplot2.tidyverse.org/reference/labellers.html).
A new column named `<column>_italic` is appended to the data frame for
each input column.

## Usage

``` r
italicize(data, columns, drop_na = FALSE)
```

## Arguments

- data:

  A data frame.

- columns:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to italicize, supplied either unquoted (`SciName`) or quoted
  (`"SciName"`). Each named column must contain character strings (e.g.
  `"Homo sapiens"`).

- drop_na:

  Logical. If `TRUE`, rows with `NA` in any of the specified columns are
  dropped before conversion. Default is `FALSE`.

## Value

The input data frame with one additional character column appended per
entry in `columns`, named `<column>_italic`. Each new column contains a
plotmath expression of the form `"italic(Genus~species)"`, where spaces
are replaced with `~` to preserve word spacing when rendered. `NA`
values in the source column remain `NA` in the output column when
`drop_na = FALSE`.

## Details

The `_italic` columns are intended to be mapped to a ggplot2 aesthetic
(e.g. `aes(x = Species_italic)`) and rendered as parsed expressions by
passing
[`label_parsed`](https://ggplot2.tidyverse.org/reference/labellers.html)
to the `labels` argument of the corresponding scale. This keeps names as
plain character data until the plot is rendered, avoiding manual
[`expression()`](https://rdrr.io/r/base/expression.html) calls.

Authorship strings appended by
[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
in the format `"Genus species (Author, Year)"` are automatically
detected and rendered in roman type alongside the italic canonical name,
producing expressions of the form
`italic("Genus species")~"(Author, Year)"`.

Spaces in names are replaced with `~` prior to wrapping in `italic()`,
which is required for plotmath to render multi-word names (e.g. genus +
species) correctly.

## See also

[`taxon_cleaner`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cleaner.md)
for standardising taxonomic name formatting before italicising,

[`taxon_combine`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_combine.md)
for merging genus and epithet into a binomial name before italicising,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating taxonomic names before italicising,

[`taxon_spellcheck`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_spellcheck.md)
for correcting misspellings before italicising,

[`taxon_cite`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_cite.md)
for appending authorship in the format detected and rendered by this
function,

[`label_parsed`](https://ggplot2.tidyverse.org/reference/labellers.html)
for rendering plotmath expressions in ggplot2 scales.

## Examples

``` r
df <- data.frame(
  SciName = c("Homo sapiens", "Panthera leo", "Canis lupus"),
  count   = c(120, 45, 78)
)

# Italicize a single column
df <- italicize(df, SciName)
df$SciName_italic
#> [1] "italic(\"Homo sapiens\")" "italic(\"Panthera leo\")"
#> [3] "italic(\"Canis lupus\")" 

# Use in a ggplot2 axis with parsed labels
if (FALSE) { # \dontrun{
ggplot(df, aes(x = SciName_italic, y = count)) +
  geom_col() +
  scale_x_discrete(labels = ggplot2::label_parsed)
} # }

# Italicize multiple columns at once
df2 <- data.frame(
  genus   = c("Homo", "Panthera"),
  species = c("sapiens", "leo")
)
italicize(df2, c(genus, species))
#>      genus species       genus_italic    species_italic
#> 1     Homo sapiens     italic("Homo") italic("sapiens")
#> 2 Panthera     leo italic("Panthera")     italic("leo")

# Drop rows where the name column is NA
df_na <- data.frame(
  SciName = c("Homo sapiens", NA, "Canis lupus"),
  count   = c(10, 5, 8)
)
italicize(df_na, SciName, drop_na = TRUE)
#>        SciName count         SciName_italic
#> 1 Homo sapiens    10 italic("Homo sapiens")
#> 3  Canis lupus     8  italic("Canis lupus")
```
