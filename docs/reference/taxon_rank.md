# Detect the taxonomic rank of a column

Infers the taxonomic rank (e.g. `species`, `genus`, `family`) of one or
more columns based on column name pattern matching. Returns a named
character vector of detected ranks, one per input column. Useful for
verifying rank assignments before calling
[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
or
[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md).

## Usage

``` r
taxon_rank(data, columns)
```

## Arguments

- data:

  A data frame.

- columns:

  Column name or [`c()`](https://rdrr.io/r/base/c.html) of column names
  to check, supplied either unquoted (`genus`) or quoted (`"genus"`).

## Value

A named character vector the same length as `columns`, where names are
the input column names and values are the detected rank as a lowercase
string (e.g. `"family"`, `"genus"`). Returns `NA` for any column whose
name does not match a recognised taxonomic rank pattern.

## Details

Detection uses a two-tier approach applied to the lowercased column
name:

1.  **Strong match** — the column name contains a full taxonomic
    keyword: `scientificname`, `species`, `genus`, `family`, `order`,
    `class`, `phylum`, `kingdom`, or `taxon`. Strong patterns are
    checked first and take priority.

2.  **Weak match** — for columns not assigned by a strong match,
    substrings of length 3–5 derived from the strong keywords are
    checked. The first matching keyword is assigned.

Detection is based on column names only — column values are not
inspected. For content-based detection across all columns in a data
frame, use
[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
instead.

## See also

[`taxon_column`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_column.md)
for detecting taxonomic columns across an entire data frame using both
name and content patterns,

[`taxon_sort`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_sort.md)
for sorting columns into standard taxonomic rank order,

[`taxon_add`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_add.md)
for appending higher taxonomic rank columns,

[`taxon_validate`](https://btorgovitsky00.github.io/datamuseum/reference/taxon_validate.md)
for validation, which uses this function internally to detect column
rank.

## Examples

``` r
df <- data.frame(
  genus       = character(),
  family_name = character(),
  my_order    = character(),
  site        = character()
)

# Detect rank of a single column
taxon_rank(df, genus)
#>   genus 
#> "genus" 

# Detect ranks of multiple columns
taxon_rank(df, c(genus, family_name, my_order))
#>       genus family_name    my_order 
#>     "genus"    "family"     "order" 

# NA returned for columns with no recognisable rank pattern
taxon_rank(df, c(genus, site))
#>   genus    site 
#> "genus"      NA 
```
