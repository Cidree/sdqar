# Assert that spatial objects share the same CRS

Checks whether all objects passed via \`...\` share an identical
Coordinate Reference System (CRS). All objects are compared against the
first one. Throws an error at the first mismatch found.

## Usage

``` r
sdqa_assert_crs(...)
```

## Arguments

- ...:

  Two or more spatial objects. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

## Value

Invisibly returns TRUE. Throws an error if any object has a different
CRS from the first.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_utm <- st_transform(nc, 32617)

sdqa_assert_crs(nc, nc)

if (FALSE) { # \dontrun{
sdqa_assert_crs(nc, nc_utm)
sdqa_assert_crs(nc, nc, nc_utm)
} # }
```
