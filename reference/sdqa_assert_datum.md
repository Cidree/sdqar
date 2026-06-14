# Assert that a spatial object uses the expected datum

Checks whether the datum of \`x\` matches \`expected\`. The comparison
is case-insensitive. Datum names are extracted from the CRS WKT, so they
match the base geographic CRS name (e.g. \`"WGS 84"\`, \`"ETRS89"\`,
\`"NAD83"\`). To discover the datum name for a given object, run
\`sdqa_assert_datum(x, "")\` and read the detected name from the error,
or inspect \`sf::st_crs(x)\$Name\` directly.

## Usage

``` r
sdqa_assert_datum(x, expected = "WGS 84")
```

## Arguments

- x:

  A spatial object. Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

- expected:

  A character vector of allowed datum names. Case-insensitive.

## Value

Invisibly returns TRUE. Throws an error if the datum of \`x\` is not in
\`expected\`.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_datum(nc)
#> Error in sdqa_assert_datum(nc): `nc` has datum "NAD27".
#> ℹ Allowed datum: "WGS 84".
sdqa_assert_datum(nc, "wgs 84")
#> Error in sdqa_assert_datum(nc, "wgs 84"): `nc` has datum "NAD27".
#> ℹ Allowed datum: "WGS 84".

if (FALSE) { # \dontrun{
nc_etrs89 <- st_transform(nc, 25830)
sdqa_assert_datum(nc_etrs89)
} # }
```
