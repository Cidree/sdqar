library(sf)

# sf_a and sf_b share xmin=0 but differ in xmax/ymax — pass case for xmin
# sf_c has xmin=5                                      — fail case for xmin
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
    c(5, 0, 15, 0, 15, 10, 5, 10, 5, 0), ncol = 2, byrow = TRUE
  ))),
  crs = 4326
))

# Validation ------------------------------------------------------------------

test_that("errors when fewer than two objects are provided", {
  expect_error(sdqa_assert_xmin(sf_a), "two objects")
})

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_xmin(df, sf_a), "unsupported class")
})

test_that("errors when op != '==' and more than two objects are provided", {
  expect_error(sdqa_assert_xmin(sf_a, sf_b, sf_c, op = "<="), "requires exactly two")
})

# op argument -----------------------------------------------------------------
# sf_a: xmin=0, sf_b: xmin=0, sf_c: xmin=5

test_that("op = '<=' passes when second xmin <= first xmin", {
  expect_no_error(sdqa_assert_xmin(sf_c, sf_a, op = "<="))  # 0 <= 5
})

test_that("op = '<=' errors when second xmin > first xmin", {
  expect_error(sdqa_assert_xmin(sf_a, sf_c, op = "<="), "not less than or equal to")
})

test_that("op = '>=' passes when second xmin >= first xmin", {
  expect_no_error(sdqa_assert_xmin(sf_a, sf_c, op = ">="))  # 5 >= 0
})

test_that("op = '>=' errors when second xmin < first xmin", {
  expect_error(sdqa_assert_xmin(sf_c, sf_a, op = ">="), "not greater than or equal to")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly when xmin values match", {
  expect_invisible(sdqa_assert_xmin(sf_a, sf_b))
  expect_true(sdqa_assert_xmin(sf_a, sf_b))
})

test_that("errors when two sf objects have different xmin", {
  expect_error(sdqa_assert_xmin(sf_a, sf_c), "Not all objects")
})

test_that("error names the offending argument", {
  expect_error(sdqa_assert_xmin(sf_a, sf_c), "sf_c")
})

test_that("reports all mismatches when multiple sf objects differ", {
  sf_d <- sf_c
  err <- tryCatch(
    sdqa_assert_xmin(sf_a, sf_c, sf_d),
    error = function(e) e
  )
  expect_match(conditionMessage(err), "sf_c")
  expect_match(conditionMessage(err), "sf_d")
})

test_that("passes with more than two sf objects sharing the same xmin", {
  expect_no_error(sdqa_assert_xmin(sf_a, sf_b, sf_a))
})

# terra -----------------------------------------------------------------------

test_that("passes when SpatRaster objects share the same xmin", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 20,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_xmin(r1, r2))
})

test_that("errors when SpatRaster objects have different xmin", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(xmin = 5, xmax = 15, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_xmin(r1, r2), "Not all objects")
})

# Cross-backend ---------------------------------------------------------------

test_that("passes when sf and SpatRaster share the same xmin", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 20,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_xmin(sf_a, r))
})

test_that("errors when sf and SpatRaster have different xmin", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 5, xmax = 15, ymin = 0, ymax = 10,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_xmin(sf_a, r), "Not all objects")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when sf and duckspatial_df share the same xmin", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_b, con)
  expect_no_error(sdqa_assert_xmin(sf_a, ddf))
})

test_that("errors when sf and duckspatial_df have different xmin", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_c, con)
  expect_error(sdqa_assert_xmin(sf_a, ddf), "Not all objects")
})
