# Assert that a spatial object contains no empty geometries

Checks whether every geometry in \`x\` is non-empty. Throws an error
listing the row indices of any empty geometries.

## Usage

``` r
sdqa_assert_no_empty(x)
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.
  \[\`SpatRaster\`\]\[terra::SpatRaster\] is not supported.

## Value

Invisibly returns \`TRUE\`. Throws an error if any geometry is empty.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_no_empty(nc)

if (FALSE) { # \dontrun{
empty <- st_sf(geometry = st_sfc(st_polygon(), crs = 4326))
sdqa_assert_no_empty(empty)
} # }
```
