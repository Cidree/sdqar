# Assert that spatial objects share the same ymin

Checks whether the southern edge (ymin) of all objects passed via
\`...\` is identical. All objects are compared against the first one.
Throws an error at the first mismatch found.

## Usage

``` r
sdqa_assert_ymin(...)
```

## Arguments

- ...:

  Two or more spatial objects. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

## Value

Invisibly returns TRUE. Throws an error if any object has a different
ymin from the first.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_ymin(nc, nc)

if (FALSE) { # \dontrun{
nc_sub <- nc[nc$NAME == "Ashe", ]
sdqa_assert_ymin(nc, nc_sub)
} # }
```
