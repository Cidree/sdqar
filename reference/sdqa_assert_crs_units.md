# Assert that a spatial object uses the expected CRS units

Checks whether the coordinate units of \`x\` match \`expected\`. The
comparison is case-insensitive. Use \`sf::st_crs(x)\$units_gdal\` to
discover the unit string for a given object (e.g. \`"degree"\`,
\`"metre"\`, \`"foot"\`).

## Usage

``` r
sdqa_assert_crs_units(x, expected = "degree")
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

- expected:

  A character vector of allowed unit names. Case-insensitive.

## Value

Invisibly returns TRUE. Throws an error if the CRS units of \`x\` are
not in \`expected\`.

## Examples

``` r
library(sf)
nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_utm <- st_transform(nc, 32617)

sdqa_assert_crs_units(nc)
sdqa_assert_crs_units(nc_utm, "metre")

if (FALSE) { # \dontrun{
sdqa_assert_crs_units(nc_utm)
} # }
```
