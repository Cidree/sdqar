library(sf)

# sf_a and sf_c share xmax=10 but differ in xmin/ymax — pass case for xmax
# sf_b has xmax=20                                     — fail case for xmax
sf_a <- st_sf(geometry = st_sfc(
  st_polygon(list(matrix(
    c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2, byrow = TRUE
  ))),
  crs = 4326
))
sf_b <- st_sf(geometry = st_sfc(
  st_polygon(list(matrix(
    c(0, 0, 20, 0, 20, 20, 0, 20, 0, 0), ncol = 2, byrow = TRUE
  ))),
  crs = 4326
))
sf_c <- st_sf(geometry = st_sfc(
  st_polygon(list(matrix(
    c(5, 0, 10, 0, 10, 20, 5, 20, 5, 0), ncol = 2, byrow = TRUE
  ))),
  crs = 4326
))

# Validation ------------------------------------------------------------------

test_that("errors when fewer than two objects are provided", {
  expect_error(sdqa_assert_xmax(sf_a), "two objects")
})

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_xmax(df, sf_a), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly when xmax values match", {
  expect_invisible(sdqa_assert_xmax(sf_a, sf_c))
  expect_true(sdqa_assert_xmax(sf_a, sf_c))
})

test_that("errors when two sf objects have different xmax", {
  expect_error(sdqa_assert_xmax(sf_a, sf_b), "Not all objects")
})

test_that("error names the offending argument", {
  expect_error(sdqa_assert_xmax(sf_a, sf_b), "sf_b")
})

test_that("reports all mismatches when multiple sf objects differ", {
  sf_d <- sf_b
  err <- tryCatch(
    sdqa_assert_xmax(sf_a, sf_b, sf_d),
    error = function(e) e
  )
  expect_match(conditionMessage(err), "sf_b")
  expect_match(conditionMessage(err), "sf_d")
})

test_that("passes with more than two sf objects sharing the same xmax", {
  expect_no_error(sdqa_assert_xmax(sf_a, sf_c, sf_a))
})

# terra -----------------------------------------------------------------------

test_that("passes when SpatRaster objects share the same xmax", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(xmin = 5, xmax = 10, ymin = 0, ymax = 20,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_xmax(r1, r2))
})

test_that("errors when SpatRaster objects have different xmax", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_xmax(r1, r2), "Not all objects")
})

# Cross-backend ---------------------------------------------------------------

test_that("passes when sf and SpatRaster share the same xmax", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 5, xmax = 10, ymin = 0, ymax = 20,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_xmax(sf_a, r))
})

test_that("errors when sf and SpatRaster have different xmax", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 10,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_xmax(sf_a, r), "Not all objects")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when sf and duckspatial_df share the same xmax", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_c, con)
  expect_no_error(sdqa_assert_xmax(sf_a, ddf))
})

test_that("errors when sf and duckspatial_df have different xmax", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_b, con)
  expect_error(sdqa_assert_xmax(sf_a, ddf), "Not all objects")
})
