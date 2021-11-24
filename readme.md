---
author: stas
title: Lala
---

Suppose you wrote a nice utility funciton (`util`) for your package that
you are going to use internaly a lot and relies on optional arguments
passed from the main function:

``` {.r org-language="R"}
util <- function(foo = 0, bar = 0) {
    # prints list of argumetns
    environment() |> as.list() |> print() 
}

util()
# $foo
# [1] 0
# $bar
# [1] 0
```

The obvious approach is to use special `...` argument to pass optional
arguments to internal function calls:

``` {.r org-language="R"}
main <- function (...) {
util(...)
}

main(foo = 0, bar = 1)
# $foo
# [1] 0
# $bar
# [1] 0
```

It is wonderful but troubles come if you need to set/fix one of the
arguments in your `util` function directlly because it can introduce
multiple arguments with the same name:

``` {.r org-language="R"}
main <- function (...) {
util(foo = 0, ...)
}

main()
# $foo
# [1] 0
# $bar
# [1] 0

main(bar = 1)
# $foo
# [1] 0
# $bar
# [1] 1

main(foo = 1)
# Error in util(foo = 0, ...)
# formal argument "foo" matched by multiple actual arguments
```

The `get_dots` function provided by `get_dots` allows you access dots
arguments without conficts and updates arguments that are set explicitly
in the function calls. You can simply put `get_dots` inside your `util`
function and bind it results into environment:

``` {.r org-language="R"}
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots()
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # prints list of argumetns
    environment() |> as.list() |> print() 
}
```

And then you can work without explicitly passing `...` argument.

``` {.r org-language="R"}
main <- function (...) {
    util(foo = 0) 
    util()        
    util(bar = 1) 
}

main(foo = 1, bar = 0)
# $foo
# [1] 0
# 
# $bar
# [1] 0
# 
# $foo
# [1] 1
# 
# $bar
# [1] 0
# 
# $foo
# [1] 1
# 
# $bar
# [1] 1
```

`get_dots` can also collect and update `...` arguments in case of more
nesting:

``` {.r org-language="R"}
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
# $foo
# [1] 0
# 
# $bar
# [1] 0
# 
# $foo
# [1] 1
# 
# $bar
# [1] 0
# 
# $foo
# [1] 1
# 
# $bar
# [1] 2
```

More features will come...
