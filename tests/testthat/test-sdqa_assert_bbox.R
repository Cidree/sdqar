library(sf)

# sf objects with distinct bounding boxes
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
    c(0, 0, 30, 0, 30, 30, 0, 30, 0, 0), ncol = 2, byrow = TRUE
  ))),
  crs = 4326
))

# Validation ------------------------------------------------------------------

test_that("errors when fewer than two objects are provided", {
  expect_error(sdqa_assert_bbox(sf_a), "two objects")
})

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_bbox(df, sf_a), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly when sf bboxes match", {
  expect_invisible(sdqa_assert_bbox(sf_a, sf_a))
  expect_true(sdqa_assert_bbox(sf_a, sf_a))
})

test_that("errors when two sf objects have different bounding boxes", {
  expect_error(sdqa_assert_bbox(sf_a, sf_b), "Not all objects")
})

test_that("error names the offending argument", {
  expect_error(sdqa_assert_bbox(sf_a, sf_b), "sf_b")
})

test_that("reports all mismatches when multiple sf objects differ", {
  err <- tryCatch(
    sdqa_assert_bbox(sf_a, sf_b, sf_c),
    error = function(e) e
  )
  expect_match(conditionMessage(err), "sf_b")
  expect_match(conditionMessage(err), "sf_c")
})

test_that("passes with more than two sf objects sharing the same bbox", {
  expect_no_error(sdqa_assert_bbox(sf_a, sf_a, sf_a))
})

# terra -----------------------------------------------------------------------

test_that("passes when SpatRaster objects share the same bbox", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_bbox(r, r))
})

test_that("errors when SpatRaster objects have different bounding boxes", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 20,
                    nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_bbox(r1, r2), "Not all objects")
})

test_that("passes when SpatVector objects share the same bbox", {
  skip_if_not_installed("terra")
  v <- terra::vect(sf_a)
  expect_no_error(sdqa_assert_bbox(v, v))
})

# Cross-backend ---------------------------------------------------------------

test_that("passes when sf and SpatRaster share the same bbox", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 0, xmax = 10, ymin = 0, ymax = 10,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_bbox(sf_a, r))
})

test_that("errors when sf and SpatRaster have different bounding boxes", {
  skip_if_not_installed("terra")
  r <- terra::rast(xmin = 0, xmax = 20, ymin = 0, ymax = 20,
                   nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_bbox(sf_a, r), "Not all objects")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when sf and duckspatial_df share the same bbox", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_a, con)
  expect_no_error(sdqa_assert_bbox(sf_a, ddf))
})

test_that("errors when sf and duckspatial_df have different bounding boxes", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_b, con)
  expect_error(sdqa_assert_bbox(sf_a, ddf), "Not all objects")
})
