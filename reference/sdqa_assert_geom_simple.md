# Assert that all geometries in a spatial object are simple

Checks whether every geometry in \`x\` is simple (i.e. does not
self-intersect). Throws an error listing the row indices of any
non-simple geometries.

## Usage

``` r
sdqa_assert_geom_simple(x)
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.
  \[\`SpatRaster\`\]\[terra::SpatRaster\] is not supported.

## Value

Invisibly returns \`TRUE\`. Throws an error if any geometry is
non-simple.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_geom_simple(nc)

if (FALSE) { # \dontrun{
non_simple <- st_sf(
  geometry = st_sfc(
    st_linestring(matrix(
      c(0, 0, 1, 1, 0, 1, 1, 0), ncol = 2, byrow = TRUE
    )),
    crs = 4326
  )
)
sdqa_assert_geom_simple(non_simple)
} # }
```
