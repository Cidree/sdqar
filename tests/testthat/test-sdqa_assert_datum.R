library(sf)

pt_wgs84  <- st_sf(geometry = st_sfc(st_point(c(0, 0)),     crs = 4326))
pt_nad83   <- st_sf(geometry = st_sfc(st_point(c(-100, 40)), crs = 4269))
pt_utm_wgs <- st_transform(pt_wgs84, 32632)   # projected, still WGS 84 datum
pt_etrs89  <- st_transform(pt_wgs84, 25830)   # projected, ETRS89 datum

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_datum(df), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for matching datum", {
  expect_invisible(sdqa_assert_datum(pt_wgs84))
  expect_true(sdqa_assert_datum(pt_wgs84))
})

test_that("passes with default expected for a WGS 84 geographic object", {
  expect_no_error(sdqa_assert_datum(pt_wgs84))
})

test_that("passes for a projected object that still uses the WGS 84 datum", {
  expect_no_error(sdqa_assert_datum(pt_utm_wgs))
})

test_that("errors when datum does not match", {
  expect_error(sdqa_assert_datum(pt_nad83), "datum")
})

test_that("error names the detected datum", {
  expect_error(sdqa_assert_datum(pt_nad83), "NAD83")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_datum(pt_nad83), "pt_nad83")
})

test_that("passes for ETRS89 when expected is ETRS89", {
  expect_no_error(sdqa_assert_datum(pt_etrs89, "ETRS89"))
})

test_that("errors for ETRS89 when WGS 84 is expected", {
  expect_error(sdqa_assert_datum(pt_etrs89), "datum")
})

test_that("comparison is case-insensitive", {
  expect_no_error(sdqa_assert_datum(pt_wgs84, "wgs 84"))
  expect_no_error(sdqa_assert_datum(pt_wgs84, "Wgs 84"))
})

test_that("passes when datum is in a vector of allowed datums", {
  expect_no_error(sdqa_assert_datum(pt_wgs84,  c("WGS 84", "ETRS89")))
  expect_no_error(sdqa_assert_datum(pt_etrs89, c("WGS 84", "ETRS89")))
})

# terra -----------------------------------------------------------------------

test_that("passes for a geographic SpatRaster with WGS 84 datum", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_no_error(sdqa_assert_datum(r))
})

test_that("passes for a projected SpatRaster with WGS 84 datum", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:32632")
  expect_no_error(sdqa_assert_datum(r))
})

test_that("passes for a SpatVector with WGS 84 datum", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_wgs84)
  expect_no_error(sdqa_assert_datum(v))
})

test_that("errors for a SpatVector with an unexpected datum", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_nad83)
  expect_error(sdqa_assert_datum(v), "datum")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when duckspatial_df uses the expected datum", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_wgs84, con)
  expect_no_error(sdqa_assert_datum(ddf))
})

test_that("errors when duckspatial_df uses an unexpected datum", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_nad83, con)
  expect_error(sdqa_assert_datum(ddf), "datum")
})
