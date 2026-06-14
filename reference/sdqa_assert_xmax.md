# Assert that spatial objects share the same xmax

Checks whether the eastern edge (xmax) of all objects passed via \`...\`
is identical. All objects are compared against the first one. Throws an
error at the first mismatch found.

## Usage

``` r
sdqa_assert_xmax(...)
```

## Arguments

- ...:

  Two or more spatial objects. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

## Value

Invisibly returns TRUE. Throws an error if any object has a different
xmax from the first.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_xmax(nc, nc)

if (FALSE) { # \dontrun{
nc_sub <- nc[nc$NAME == "Currituck", ]
sdqa_assert_xmax(nc, nc_sub)
} # }
```
