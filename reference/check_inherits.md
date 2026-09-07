# Class Inheritance Checks

These functions perform checks that assert the underlying class of
objects passed to them.

- `check_inherits()`: checks that object `x` is of class `class` using
  [`base::inherits()`](https://rdrr.io/r/base/class.html)

- `check_inherits2()`: checks that object `x` is of class `class` using
  [`base::.class2()`](https://rdrr.io/r/base/class.html)

- `check_inherits_any()`: checks that object `x` is at least one of the
  provided `classes` via
  [`rlang::inherits_any()`](https://rlang.r-lib.org/reference/inherits_any.html)

- `check_inherits_all()`: checks that object `x` is all of the provided
  `classes` via
  [`rlang::inherits_all()`](https://rlang.r-lib.org/reference/inherits_any.html)

If validation fails for any of these functions, an error is thrown via
`check_abort()` displaying a friendly error message.

## Usage

``` r
check_inherits(
  x,
  class,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
)

check_inherits2(
  x,
  class,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
)

check_inherits_any(
  x,
  classes,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
)

check_inherits_all(
  x,
  classes,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
)
```

## Arguments

- x:

  The object to check.

- class, classes:

  The name of the class or classes to use during checking.

- arg:

  An argument name as a string. This argument will be mentioned in error
  messages as the input that is at the origin of a problem.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

If checks pass, invisibly returns the provided `x` object. If checks
fail, a condition error is thrown.
