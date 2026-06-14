# Package index

## Assert — Coordinate Reference System

Throw an error when CRS properties do not meet expectations

- [`sdqa_assert_crs()`](https://cidree.github.io/sdqar/reference/sdqa_assert_crs.md)
  : Assert that spatial objects share the same CRS
- [`sdqa_assert_datum()`](https://cidree.github.io/sdqar/reference/sdqa_assert_datum.md)
  : Assert that a spatial object uses the expected datum
- [`sdqa_assert_crs_units()`](https://cidree.github.io/sdqar/reference/sdqa_assert_crs_units.md)
  : Assert that a spatial object uses the expected CRS units

## Assert — Bounding Box

Throw an error when spatial extents do not match

- [`sdqa_assert_bbox()`](https://cidree.github.io/sdqar/reference/sdqa_assert_bbox.md)
  : Assert that spatial objects share the same bounding box
- [`sdqa_assert_xmin()`](https://cidree.github.io/sdqar/reference/sdqa_assert_xmin.md)
  : Assert that spatial objects share the same xmin
- [`sdqa_assert_xmax()`](https://cidree.github.io/sdqar/reference/sdqa_assert_xmax.md)
  : Assert that spatial objects share the same xmax
- [`sdqa_assert_ymin()`](https://cidree.github.io/sdqar/reference/sdqa_assert_ymin.md)
  : Assert that spatial objects share the same ymin
- [`sdqa_assert_ymax()`](https://cidree.github.io/sdqar/reference/sdqa_assert_ymax.md)
  : Assert that spatial objects share the same ymax

## Assert — Geometry

Throw an error when geometry type or validity constraints are violated

- [`sdqa_assert_geom_type()`](https://cidree.github.io/sdqar/reference/sdqa_assert_geom_type.md)
  : Assert that a spatial object contains only the expected geometry
  type(s)
- [`sdqa_assert_geom_valid()`](https://cidree.github.io/sdqar/reference/sdqa_assert_geom_valid.md)
  : Assert that all geometries in a spatial object are valid
- [`sdqa_assert_geom_simple()`](https://cidree.github.io/sdqar/reference/sdqa_assert_geom_simple.md)
  : Assert that all geometries in a spatial object are simple

## Predicates

Return TRUE/FALSE for CRS properties without throwing errors

- [`sdqa_is_geographic()`](https://cidree.github.io/sdqar/reference/sdqa_is_geographic.md)
  : Check if a spatial object has a geographic CRS
- [`sdqa_is_projected()`](https://cidree.github.io/sdqar/reference/sdqa_is_projected.md)
  : Check if a spatial object has a projected CRS
