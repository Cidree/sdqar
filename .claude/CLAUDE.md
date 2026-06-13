# sdqar — Spatial Data Quality Assessment for R

## Package overview

`sdqar` provides data quality assessment functions for spatial data in R. All public functions use the `sdqa_*()` prefix.

The package targets three spatial backends:

| Backend | Class | Package |
|---|---|---|
| Vector (sf) | `sf` | `sf` |
| Raster/vector | `SpatRaster`, `SpatVector` | `terra` |
| DuckDB-backed vector | `duckspatial_df` | `duckspatial` |

`duckspatial` is a lazy-evaluation DuckDB spatial backend — data stays in DuckDB until explicitly materialized. Avoid pulling data into R unnecessarily when a `duckspatial_df` is the input.

## Development workflow

```r
devtools::load_all()    # load package
devtools::document()    # rebuild docs from roxygen2
devtools::check()       # R CMD check
devtools::test()        # run testthat suite
devtools::install()     # install locally
```

## Code style

Follow the [tidyverse style guide](https://style.tidyverse.org/) strictly:

- Snake case for all names
- Spaces around operators and after commas
- Maximum line length: 80 characters
- Prefer `|>` (base pipe) over `%>%`
- No `library()` or `require()` calls inside package code — use `::` or `@importFrom`

### Internal comment style

Function bodies use numbered sections and sub-sections to separate logical steps:

```r
my_function <- function(x) {

  # 0. Validate inputs
  assert_something(x)

  # 1. Prepare inputs

  ## 1.1. Brief description of sub-step
  result <- do_something(x)

  ## 1.2. Another sub-step
  result <- transform(result)

  # 2. Core logic
  ...
}
```

Only comment the **why** when it is non-obvious. Use section headers to explain **what** each block does at a high level.

## Documentation

All exported functions must have full `roxygen2` documentation:

- `@param` for every argument — use `@template` for params shared across multiple functions
- `@return` describing the output
- `@examples` with at least one runnable example
- `@export` on every public function
- Group related functions with `@family`

Run `devtools::document()` after any doc change.

## File organisation

Source files in `R/` are grouped by function type, not one file per function:

| File | Contents |
|---|---|
| `utils_not_exported.R` | Internal helpers (`.`-prefixed, not exported). Wrap with `# nocov start` / `# nocov end`. |
| `sdqa_assert.R` | All `sdqa_assert_*()` functions |

Add new files as new function families are introduced (e.g. `sdqa_check.R`, `sdqa_repair.R`).

## Function conventions

- All public functions: `sdqa_*()`
- Internal helpers: `.`-prefixed, not exported, live in `utils_not_exported.R`
- Each function should accept at least `sf` input; add `terra` and `duckspatial_df` support where applicable
- When a backend is not supported, throw an informative error with `cli::cli_abort()`

### Assert functions (`sdqa_assert_*`)

- Return `invisible(TRUE)` on success
- Throw a `cli::cli_abort()` error on failure with a message that names every offending argument
- Use `rlang::ensyms(...)` to capture argument labels for error messages

**Important:** `rlang::ensyms(...)` only accepts symbols (variable names). Passing an inline call like `data.frame(x = 1)` directly will error with "Can't convert a call to a symbol." Always assign objects to a named variable before passing them to any function that uses `ensyms()` internally.

## Testing

Framework: `testthat` (3rd edition). Tests live in `tests/testthat/`.

### File naming

Test files mirror the source file they cover: `R/sdqa_assert.R` → `tests/testthat/test-sdqa_assert_crs.R`. One test file per exported function within a group.

### Writing tests

- Build small, self-contained spatial objects at the top of the test file (assign to named variables — never pass inline expressions to `sdqa_*()` functions that use `ensyms()`)
- Test all three backends when the function supports them
- Guard duckspatial tests with `skip_if_not_installed("duckspatial")`
- For assert functions: use `expect_true()` for the happy path (they return `invisible(TRUE)`)
- Use `expect_invisible()` to verify the return is invisible
- Organise with comment section headers: `# Validation`, `# sf`, `# terra`, `# Cross-backend`, `# duckspatial`

## CI/CD

GitHub Actions runs `R CMD check` on push/PR. Workflow files live in `.github/workflows/`. Use the standard `r-lib/actions` setup.

## Dependencies

| Package | Role | DESCRIPTION field |
|---|---|---|
| `sf` | CRS extraction and comparison | `Imports` |
| `terra` | terra backend support | `Imports` |
| `cli` | All user-facing messages and errors | `Imports` |
| `rlang` | `ensyms()` for argument label capture | `Imports` |
| `duckspatial` | DuckDB spatial backend | `Suggests` + `Remotes: Cidree/duckspatial` |
| `testthat (>= 3.0.0)` | Testing | `Suggests` |

`duckspatial` is in `Suggests` (not `Imports`) because it is GitHub-only and not on CRAN. A package in `Imports` must be available on CRAN for the package to be submitted there.
