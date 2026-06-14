# Assert that spatial objects share the same bounding box

Checks whether all objects passed via \`...\` share an identical
bounding box. All objects are compared against the first one. Throws an
error at the first mismatch found.

## Usage

``` r
sdqa_assert_bbox(...)
```

## Arguments

- ...:

  Two or more spatial objects. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

## Value

Invisibly returns TRUE. Throws an error if any object has a different
bounding box from the first.

## Examples

``` r
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_sub <- nc[1:50, ]

sdqa_assert_bbox(nc, nc)

if (FALSE) { # \dontrun{
sdqa_assert_bbox(nc, nc_sub)
} # }
```
