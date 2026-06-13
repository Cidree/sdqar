library(sf)

pt_4326  <- st_sf(geometry = st_sfc(st_point(c(0, 0)), crs = 4326))
pt_32632 <- st_transform(pt_4326, 32632)
pt_3857  <- st_transform(pt_4326, 3857)

# Validation ------------------------------------------------------------------

test_that("errors when fewer than two objects are provided", {
  expect_error(sdqa_assert_crs(pt_4326), "two objects")
})

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_crs(df, pt_4326), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns first object invisibly when sf CRS match", {
  expect_invisible(sdqa_assert_crs(pt_4326, pt_4326))
  expect_true(sdqa_assert_crs(pt_4326, pt_4326))
})

test_that("errors when two sf objects have different CRS", {
  expect_error(sdqa_assert_crs(pt_4326, pt_32632), "Not all objects")
})

test_that("error names the offending argument", {
  expect_error(sdqa_assert_crs(pt_4326, pt_32632), "pt_32632")
})

test_that("reports all mismatches when multiple sf objects differ", {
  err <- tryCatch(
    sdqa_assert_crs(pt_4326, pt_32632, pt_3857),
    error = function(e) e
  )
  expect_match(conditionMessage(err), "pt_32632")
  expect_match(conditionMessage(err), "pt_3857")
})

test_that("passes with more than two sf objects sharing the same CRS", {
  expect_no_error(sdqa_assert_crs(pt_4326, pt_4326, pt_4326))
})

# terra -----------------------------------------------------------------------

test_that("passes when SpatRaster objects share the same CRS", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_crs(r, r))
})

test_that("errors when SpatRaster objects have different CRS", {
  skip_if_not_installed("terra")
  r1 <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  r2 <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:32632")
  expect_error(sdqa_assert_crs(r1, r2), "Not all objects")
})

test_that("passes when SpatVector objects share the same CRS", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_4326)
  expect_no_error(sdqa_assert_crs(v, v))
})

# Cross-backend ---------------------------------------------------------------

test_that("passes when sf and SpatRaster share the same CRS", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_crs(pt_4326, r))
})

test_that("errors when sf and SpatRaster have different CRS", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:32632")
  expect_error(sdqa_assert_crs(pt_4326, r), "Not all objects")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when sf and duckspatial_df share the same CRS", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_4326, con)
  expect_no_error(sdqa_assert_crs(pt_4326, ddf))
})

test_that("errors when sf and duckspatial_df have different CRS", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_32632, con)
  expect_error(sdqa_assert_crs(pt_4326, ddf), "Not all objects")
})
