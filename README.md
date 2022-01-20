[![R-CMD-check](https://github.com/stasvlasov/get_dots/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/get_dots/actions)
[![codecov](https://codecov.io/gh/stasvlasov/dots/branch/master/graph/badge.svg?token=ACDBEL2JY5)](https://codecov.io/gh/stasvlasov/dots)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/dots)

Provides access to arguments of nested functions. Sort of an alterative mechanism to passing `...` arguments but with more features.

Provides access to higher level call's arguments (including `...` dots arguments) without explicitly passing it through calling stack and allows updating default values that are explicitly set throughout calling stack (i.e., lower calls take prevalence).


# The 'problem' this package solves

Suppose you wrote a nice utility funciton (`util`) for your package:

    util <- function(foo = 0, bar = 0) {
        message("foo: ", foo, ", bar: ", bar)
    }
    
    util()
    #> foo: 0, bar: 0

You are going to use this `util` function a lot internaly and you want to pass some optional arguments passed from the upper function calls. Usually you will use special `...` argument to do that:

    main <- function (...) {
        util(...)
    }
    
    main(foo = 0, bar = 1)
    #> foo: 0, bar: 1

But, here is the problem if at some point you need to set one of the arguments in your `util` function directlly this can introduce errors (known as "matched by multiple actual arguments"):

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

The `dots` package provides a function `get_dots` that allows you to access dots arguments without conflicts and update arguments that are set explicitly in the function calls. You can simply put `get_dots` inside your `util` function, bind it's results into local environment and proceed with out explicitly passing dots parameter.

Note that the `get_dots` function should be called with `:::` as `dots:::get_dots` because is not added to `NAMESPACE` since the intended use is internal only. For the following examples we assume that `get_dots` is available (i.e., run `get_dots <- dots:::get_dots` before running examples).

    util <- function(foo = 0, bar = 0) {
        # get dots and bind updated arguments into environment
        dots <- get_dots()
        for (v in names(dots)) assign(v, dots[[v]])
        # util just reports it arguments
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


# Features of `get_dots` function

`get_dots` can collect and update `...` arguments up through stack of nested of calls. This is controlled with `search_depth` parameter

    util <- function(foo = 0, bar = 0) {
        # get dots and bind updated arguments into environment
        dots <- get_dots(search_depth = 3L)
        for (v in names(dots)) assign(v, dots[[v]])
        # util just reports it arguments
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

Limit looking up for dots arguments updates by specifying (see `get_dot` parameters documentation):

-   number of frames (see last example)
-   function name up to which to look up in calling stack
-   look up calling stack while calls belong to specific environment/package
-   look up calling stack while calls name matches specific regular expression


# Installation

You can get it from github with:

    devtools::install_github("stasvlasov/dots")

The `dots` package is pretty small and has no dependencies. However, if you have wonderful `checkmate` package  installed (you can get it with `install.packages("checkmate")`) it will be used for checking `get_dots` arguments.


# What next?

It is work in progress/prove of concept. Please, submit issues, questions:)

