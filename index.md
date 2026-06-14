# sdqar [![sdqar website](reference/figures/logo.png)](https://cidree.github.io/sdqar/)

**{sdqar}** provides data quality assessment functions for spatial
objects in R. It covers the three most common spatial backends —
**{sf}**, **{terra}**, and **{duckspatial}** — so you can run the same
QA checks regardless of how your spatial data is represented.

### How it works

All public functions follow the `sdqa_*()` prefix (*Spatial Data Quality
Assessment*). Functions are designed to work uniformly across the three
supported backends:

| Backend | Classes | Use case |
|----|----|----|
| **{sf}** | `sf`, `sfc` | Vector data (the standard R spatial format) |
| **{terra}** | `SpatRaster`, `SpatVector` | Raster and vector data |
| **{duckspatial}** | `duckspatial_df` | Large vector datasets backed by DuckDB |

QA functions are grouped by type:

- `sdqa_assert_*()` — throw an informative error when a condition is not
  met, designed to be used in data pipelines

### Naming conventions

All public functions use the `sdqa_*()` prefix. Assert-type functions
additionally follow the `sdqa_assert_*()` pattern, mirroring the style
of packages like **{assertr}** and **{checkmate}**.

## Installation

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("Cidree/sdqar")
```

## Usage

``` r

library(sdqar)
library(sf)
#> Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
nc_utm <- st_transform(nc, 32617)
```

### Assert functions

Assert functions throw an informative error when a condition is not met
and return `invisible(TRUE)` otherwise, making them safe to use inside
pipelines or at the top of scripts.

**Check that objects share the same CRS:**

``` r

# Passes silently when CRS match
sdqa_assert_crs(nc, nc)

# Errors with a clear message when they differ
sdqa_assert_crs(nc, nc_utm)
#> Error in `sdqa_assert_crs()`:
#> ! Not all objects share the same CRS as `nc` (NAD27).
#> ✖ `nc_utm`: WGS 84 / UTM zone 17N

# Checks any number of objects at once and reports all mismatches
nc_3857 <- st_transform(nc, 3857)
sdqa_assert_crs(nc, nc_utm, nc_3857)
#> Error in `sdqa_assert_crs()`:
#> ! Not all objects share the same CRS as `nc` (NAD27).
#> ✖ `nc_utm`: WGS 84 / UTM zone 17N
#> ✖ `nc_3857`: WGS 84 / Pseudo-Mercator
```

The same function works with **{terra}** and **{duckspatial}** objects,
and across backends:

``` r

library(terra)

r <- rast(system.file("ex/elev.tif", package = "terra"))
sdqa_assert_crs(nc, r)
```

## Contributing

Bug reports, feature requests, and pull requests are very welcome!

- [Raise an issue](https://github.com/Cidree/sdqar/issues)
- [Open a pull request](https://github.com/Cidree/sdqar/pulls)
