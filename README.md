[![R-CMD-check](https://github.com/stasvlasov/get_dots/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/get_dots/actions)
[![codecov](https://codecov.io/gh/stasvlasov/dots/branch/master/graph/badge.svg?token=ACDBEL2JY5)](https://codecov.io/gh/stasvlasov/dots)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/dots)

An alternative way to interact with `...` dots arguments (aka ellipses).

Provides access to `...` dots arguments without explicitly passing it through calling stack and allows updating default values that are explicitly set throughout calling stack (lower calls take prevalence).

# The \'problem\' this package solves

Suppose you wrote a nice utility funciton (`util`) for your package:

``` {.r org-language="R"}
util <- function(foo = 0, bar = 0) {
    message("foo: ", foo, ", bar: ", bar)
}

util()
#> foo: 0, bar: 0
```

You are going to use this `util` function a lot internaly and you want
to pass some optional arguments passed from the upper function calls.
Usually you will use special `...` argument to do that:

``` {.r org-language="R"}
main <- function (...) {
    util(...)
}

main(foo = 0, bar = 1)
#> foo: 0, bar: 1
```

But, here is the problem if at some point you need to set one of the
arguments in your `util` function directlly this can introduce errors
(known as \"matched by multiple actual arguments\"):

``` {.r org-language="R"}
main <- function (...) {
    util(foo = 1, ...)
}

main()
#> foo: 1, bar: 0

main(bar = 2)
#> foo: 1, bar: 2

main(foo = 2)
#> Error in util(foo = 0, ...) :
#  formal argument "foo" matched by multiple actual arguments
```

The `dots` package provides a function `get_dots` that allows you to
access dots arguments without conflicts and update arguments that are
set explicitly in the function calls. You can simply put `get_dots`
inside your `util` function, bind it\'s results into local environment
and proceed with out explicitly passing dots parameter:

``` {#example-basic .r org-language="R"}
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- dots:::get_dots()
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    message("foo: ", foo, ", bar: ", bar)
}

util()
#> foo: 0, bar: 0

main <- function (...) {
    util()
    util(foo = 1) 
    util(bar = 1)
}

main(foo = 2, bar = 2)
#> foo: 2, bar: 2
#> foo: 1, bar: 2  # THIS WORKS NOW!
#> foo: 2, bar: 1  # THIS WORKS NOW!
```

# Features of `get_dots` function

-   `get_dots` can also collect and update `...` arguments up through
    stack of nested of calls:

``` {#example-nesting .r org-language="R"}
util <- function(foo = 0, bar = 0) {
    dots <- dots::get_dots(search_up_nframes = 3L)
    # bind updated arguments to local environment
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report arguments
    message("foo: ", foo, ", bar: ", bar)
}

main <- function (...) {
    util()
    sub_main(foo = 1)
}

sub_main <- function (...) {
    util()
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (...) {
    util()
}

main()
#> foo: 0, bar: 0
#> foo: 1, bar: 0
#> foo: 0, bar: 2
```

-   Limit looking up for dots arguments updates by specifying (see
    `get_dot` parameters documentation):
    -   number of frames (see last example)
    -   function name up to which to look up in calling stack
    -   look up calling stack while calls belong to specific
        environment/package
    -   look up calling stack while calls name matches specific regular
        expression
-   More to come...

# Installation

You can get it from github with:

``` {.r org-language="R"}
devtools::install_github("stasvlasov/dots")
```

The `dots` package is pretty small and has no dependencies. However, if
you have wonderful `checkmate` package installed (you can get it with
`install.packages("checkmate")`) it will be used for checking `get_dots`
arguments.

# What next?

It is work in progress/prove of concept. Please, submit issues,
questions:)
