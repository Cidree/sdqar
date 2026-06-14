# Check if a spatial object has a geographic CRS

Returns \`TRUE\` if \`x\` has a geographic (lon/lat) CRS, \`FALSE\`
otherwise. Returns \`FALSE\` when the CRS is projected or undefined.

## Usage

``` r
sdqa_is_geographic(x)
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

sdqa_is_geographic(nc)
#> [1] TRUE
sdqa_is_geographic(nc_utm)
#> [1] FALSE
```
