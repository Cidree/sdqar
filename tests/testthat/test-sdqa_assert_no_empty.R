library(sf)

# Non-empty polygon
sf_valid <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)

# Empty polygon
sf_empty <- st_sf(geometry = st_sfc(st_polygon(), crs = 4326))

# Two rows: one valid, one empty
sf_mixed <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    st_polygon(),
    crs = 4326
  )
)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_no_empty(df), "unsupported class")
})

test_that("error for SpatRaster mentions unsupported class", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_no_empty(r), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for non-empty geometries", {
  expect_invisible(sdqa_assert_no_empty(sf_valid))
  expect_true(sdqa_assert_no_empty(sf_valid))
})

test_that("errors for empty geometry", {
  expect_error(sdqa_assert_no_empty(sf_empty), "empty geometr")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_no_empty(sf_empty), "sf_empty")
})

test_that("error includes row index", {
  expect_error(sdqa_assert_no_empty(sf_empty), "row")
})

test_that("error reports all empty rows for mixed object", {
  expect_error(sdqa_assert_no_empty(sf_mixed), "2")
})

# terra -----------------------------------------------------------------------
# Note: terra::vect() silently drops empty geometries during sf conversion, so
# only the happy-path case is testable here.

test_that("passes for SpatVector with all non-empty geometries", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_valid)
  expect_no_error(sdqa_assert_no_empty(sv))
})

# duckspatial -----------------------------------------------------------------

test_that("passes for duckspatial_df with all non-empty geometries", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_valid, con)
  expect_no_error(sdqa_assert_no_empty(ddf))
})

test_that("errors for duckspatial_df with empty geometry", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_mixed, con)
  expect_error(sdqa_assert_no_empty(ddf), "empty geometr")
})
