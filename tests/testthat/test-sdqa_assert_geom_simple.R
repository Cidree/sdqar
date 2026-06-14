library(sf)

# Simple linestring
sf_simple <- st_sf(
  geometry = st_sfc(
    st_linestring(matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE)),
    crs = 4326
  )
)

# Figure-8 linestring: (0,0)→(1,1) crosses (0,1)→(1,0) at (0.5, 0.5)
sf_non_simple <- st_sf(
  geometry = st_sfc(
    st_linestring(matrix(
      c(0, 0, 1, 1, 0, 1, 1, 0), ncol = 2, byrow = TRUE
    )),
    crs = 4326
  )
)

# Two rows: one simple, one not
sf_mixed <- st_sf(
  geometry = st_sfc(
    st_linestring(matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE)),
    st_linestring(matrix(
      c(0, 0, 1, 1, 0, 1, 1, 0), ncol = 2, byrow = TRUE
    )),
    crs = 4326
  )
)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_geom_simple(df), "unsupported class")
})

test_that("error for SpatRaster mentions unsupported class", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_geom_simple(r), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for simple geometries", {
  expect_invisible(sdqa_assert_geom_simple(sf_simple))
  expect_true(sdqa_assert_geom_simple(sf_simple))
})

test_that("errors for non-simple geometry", {
  expect_error(sdqa_assert_geom_simple(sf_non_simple), "non-simple geometr")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_geom_simple(sf_non_simple), "sf_non_simple")
})

test_that("error includes row index", {
  expect_error(sdqa_assert_geom_simple(sf_non_simple), "row")
})

test_that("error reports all non-simple rows for mixed object", {
  expect_error(sdqa_assert_geom_simple(sf_mixed), "2")
})

# terra -----------------------------------------------------------------------

test_that("passes for SpatVector with all simple geometries", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_simple)
  expect_no_error(sdqa_assert_geom_simple(sv))
})

test_that("errors for SpatVector with non-simple geometry", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_non_simple)
  expect_error(sdqa_assert_geom_simple(sv), "non-simple geometr")
})

# duckspatial -----------------------------------------------------------------

test_that("passes for duckspatial_df with all simple geometries", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_simple, con)
  expect_no_error(sdqa_assert_geom_simple(ddf))
})

test_that("errors for duckspatial_df with non-simple geometry", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_non_simple, con)
  expect_error(sdqa_assert_geom_simple(ddf), "non-simple geometr")
})
