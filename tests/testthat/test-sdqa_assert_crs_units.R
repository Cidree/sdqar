library(sf)

pt_geo <- st_sf(geometry = st_sfc(st_point(c(0, 0)), crs = 4326))
pt_prj <- st_transform(pt_geo, 32632)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_crs_units(df), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for matching units", {
  expect_invisible(sdqa_assert_crs_units(pt_geo))
  expect_true(sdqa_assert_crs_units(pt_geo))
})

test_that("passes with default expected for a geographic object", {
  expect_no_error(sdqa_assert_crs_units(pt_geo))
})

test_that("passes for a projected object with metre units", {
  expect_no_error(sdqa_assert_crs_units(pt_prj, "metre"))
})

test_that("errors when units do not match expected", {
  expect_error(sdqa_assert_crs_units(pt_prj), "units")
})

test_that("error names the detected units", {
  expect_error(sdqa_assert_crs_units(pt_prj), "metre")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_crs_units(pt_prj), "pt_prj")
})

test_that("comparison is case-insensitive", {
  expect_no_error(sdqa_assert_crs_units(pt_geo, "DEGREE"))
  expect_no_error(sdqa_assert_crs_units(pt_prj, "Metre"))
})

test_that("passes when units are in a vector of allowed values", {
  expect_no_error(sdqa_assert_crs_units(pt_geo, c("degree", "metre")))
  expect_no_error(sdqa_assert_crs_units(pt_prj, c("degree", "metre")))
})

# terra -----------------------------------------------------------------------

test_that("passes for a geographic SpatRaster with degree units", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_crs_units(r))
})

test_that("errors for a projected SpatRaster when degree is expected", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:32632")
  expect_error(sdqa_assert_crs_units(r), "units")
})

test_that("passes for a projected SpatVector with metre units", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_prj)
  expect_no_error(sdqa_assert_crs_units(v, "metre"))
})

# duckspatial -----------------------------------------------------------------

test_that("passes when duckspatial_df has the expected units", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_geo, con)
  expect_no_error(sdqa_assert_crs_units(ddf))
})

test_that("errors when duckspatial_df has unexpected units", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_prj, con)
  expect_error(sdqa_assert_crs_units(ddf), "units")
})
