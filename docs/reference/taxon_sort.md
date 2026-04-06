# Sort columns into standard taxonomic rank order

Reorders data frame columns so that detected taxonomic rank columns
appear in standard hierarchical order, with non-taxonomic columns
preserved in their original relative positions. Taxonomic columns are
detected automatically via
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md),
or a custom column order can be specified manually via `manual`.

## Usage

``` r
taxon_sort(data, manual = FALSE)
```

## Arguments

- data:

  A data frame.

- manual:

  Optional. A numeric vector of at least two column indices specifying a
  custom sort order for those columns. The selected columns are moved to
  the position of the lowest index in `manual`, in the order supplied.
  If `FALSE` (default), standard taxonomic rank order is used via
  automatic detection.

## Value

The input data frame with taxonomic columns reordered, all other columns
retained in their original relative positions. A console message reports
the number of columns sorted, the insertion position, and the resulting
column order. If duplicate rank assignments are detected, a warning is
issued and the data frame is returned unchanged.

## Details

The standard rank hierarchy used for automatic sorting is, from broadest
to most specific: `kingdom`, `subkingdom`, `infrakingdom`,
`superphylum`, `phylum`, `subphylum`, `infraphylum`, `superclass`,
`class`, `subclass`, `infraclass`, `superorder`, `order`, `suborder`,
`infraorder`, `superfamily`, `family`, `subfamily`, `tribe`, `subtribe`,
`genus`, `subgenus`, `species`, `subspecies`, `variety`.

Taxonomic columns not matching a rank in the hierarchy are appended
after the sorted known-rank columns. If multiple columns are detected
for the same rank, a warning is issued and the data frame is returned
unsorted – use
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
with `output = "list"` to inspect assignments and either rename columns
or use `manual` to specify the desired order explicitly.

If no taxonomic columns are detected, a message is printed and the
original data frame is returned unchanged.

## See also

[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
for detecting taxonomic columns and inspecting rank assignments before
sorting,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns before sorting,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validating taxonomic names before sorting.

## Examples

``` r
df <- data.frame(
  id      = 1:3,
  species = c("Homo sapiens", "Panthera leo", "Canis lupus"),
  kingdom = c("Animalia", "Animalia", "Animalia"),
  family  = c("Hominidae", "Felidae", "Canidae"),
  order   = c("Primates", "Carnivora", "Carnivora")
)

# Automatic sort into standard rank order
taxon_sort(df)
#> [taxon_sort] 4 taxonomic column(s) sorted from position 2: kingdom -> order -> family -> species
#>   id  kingdom     order    family      species
#> 1  1 Animalia  Primates Hominidae Homo sapiens
#> 2  2 Animalia Carnivora   Felidae Panthera leo
#> 3  3 Animalia Carnivora   Canidae  Canis lupus

# Manual sort by column index
taxon_sort(df, manual = c(3, 5, 4, 2))
#> [taxon_sort] 4 column(s) manually sorted from position 2: kingdom -> order -> family -> species
#>   id  kingdom     order    family      species
#> 1  1 Animalia  Primates Hominidae Homo sapiens
#> 2  2 Animalia Carnivora   Felidae Panthera leo
#> 3  3 Animalia Carnivora   Canidae  Canis lupus

# Inspect rank assignments first if sort returns a warning
taxon_column(df, output = "list")
#> $family
#> $family$family
#> [1] 4
#> 
#> 
#> $kingdom
#> $kingdom$kingdom
#> [1] 3
#> 
#> 
#> $order
#> $order$order
#> [1] 5
#> 
#> 
#> $species
#> $species$species
#> [1] 2
#> 
#> 
```
