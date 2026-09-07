# Check Returns

Returns for the `check_*()` functions. Use
`@inherit .shared_returns_check returns` in a function's roxygen2 block
to apply this return description.

## Value

If the checks pass, invisibly returns the provided object, `x`. If
checks fail, a condition error of class `check_error` is thrown.
