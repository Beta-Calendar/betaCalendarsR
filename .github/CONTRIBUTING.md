# Contributing

Please open an issue before changing a calendar convention or recurrence rule.
Changes should keep date behavior explicit, preserve base R runtime
compatibility, and include a test for boundary conditions.

Run the package test suite with `devtools::test()` and run
`R CMD check --as-cran` on a built source archive before submitting a pull
request. Vignette examples should remain executable.
