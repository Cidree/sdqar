# Assert that a spatial object contains only the expected geometry type(s)

Checks whether every geometry type found in \`x\` is within
\`expected\`. The comparison is case-insensitive. Throws an error
listing all unexpected types found.

## Usage

``` r
sdqa_assert_geom_type(x, expected)
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.
  \[\`SpatRaster\`\]\[terra::SpatRaster\] is not supported.

- expected:

  A character vector of allowed geometry type names (e.g. \`"POLYGON"\`,
  \`c("POLYGON", "MULTIPOLYGON")\`). Case-insensitive.

## Value

Invisibly returns TRUE. Throws an error if any geometry type found in
\`x\` is not in \`expected\`.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_geom_type(nc, "MULTIPOLYGON")
sdqa_assert_geom_type(nc, c("polygon", "multipolygon"))

if (FALSE) { # \dontrun{
sdqa_assert_geom_type(nc, "POLYGON")
} # }
```
