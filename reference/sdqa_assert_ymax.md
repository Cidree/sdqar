# Assert that spatial objects share the same ymax

Checks whether the northern edge (ymax) of the objects passed via
\`...\` satisfies the comparison defined by \`op\` relative to the first
object. With \`op = "=="\` (default), all objects are compared against
the first and must share the same value. For any other operator, exactly
two objects must be provided.

## Usage

``` r
sdqa_assert_ymax(..., op = c("==", "<=", "<", ">=", ">"))
```

## Arguments

- ...:

  Two or more spatial objects (\`op = "=="\`), or exactly two objects
  (any other \`op\`). Supported classes: \[\`sf\`\]\[sf::sf\],
  \[\`SpatRaster\`\]\[terra::SpatRaster\],
  \[\`SpatVector\`\]\[terra::SpatVector\], or \`duckspatial_df\`.

- op:

  character(1); comparison operator applied to the second object's
  coordinate value relative to the first's. One of \`"=="\` (default),
  \`"\<="\`, \`"\<"\`, \`"\>="\`, or \`"\>"\`.

## Value

Invisibly returns TRUE. Throws an error if the comparison fails.

## Examples

``` r
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

sdqa_assert_ymax(nc, nc)

if (FALSE) { # \dontrun{
nc_sub <- nc[nc$NAME == "Ashe", ]
sdqa_assert_ymax(nc, nc_sub)
sdqa_assert_ymax(nc, nc_sub, op = ">=")
} # }
```
