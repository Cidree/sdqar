# Check if a spatial object has a projected CRS

Returns \`TRUE\` if \`x\` has a projected (Cartesian) CRS, \`FALSE\`
otherwise. Returns \`FALSE\` when the CRS is geographic or undefined.

## Usage

``` r
sdqa_is_projected(x)
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

## Value

A single logical value.

## Examples

``` r
library(sf)
nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_utm <- st_transform(nc, 32617)

sdqa_is_projected(nc)
#> [1] FALSE
sdqa_is_projected(nc_utm)
#> [1] TRUE
```
