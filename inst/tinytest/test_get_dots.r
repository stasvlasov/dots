util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots()
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}


## check basics
expect_equal(get_dots(expect_equal)
           , formals("expect_equal"))

expect_equal(get_dots(util)
           , formals("util"))

expect_equal(get_dots(util, select_args = "foo")
           , formals("util")["foo"])

expect_equal(get_dots(util, select_args = c("bar" ,"foo"))
           , formals("util")[c("bar" ,"foo")])




main <- function (...) {
    util(bar = 1) 
}

expect_equal(main(foo = 1, bar = 0), list(1, 1))


main <- function (...) {
    util(foo = 0) 
}

expect_equal(main(foo = 1, bar = 0), list(0, 0))


util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_nframes = 2L)
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}

main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (...) {
    util()
}

expect_equal(main(foo = 3, bar = 3), list(1, 2))

## shallow search
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_nframes = 1L)
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}

main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (...) {
    util()
}


expect_equal(main(foo = 3, bar = 3), list(0, 2))


## function func call limit
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_to_call = "sub_sub_main"
                   , search_up_nframes = 3L)
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}

main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (...) {
    util()
}


expect_equal(main(foo = 3, bar = 3), list(0, 2))


## test fun arg test (signature based on arguments)
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_nframes = 3L
                     , search_while_calls_have_args = "arg_shold_be_present")
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}

main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (..., arg_shold_be_present = NULL) {
    util()
}


expect_equal(main(foo = 3, bar = 3), list(0, 2))








## test fun call belongs to env (package)
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_nframes = 3L
                   , search_while_calls_belong_to_env = "testing_environment_for_det_dots_function")
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}

env <- new.env()
attr(env, "name") <- "testing_environment_for_det_dots_function"
environmentName(env)

main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (..., arg_shold_be_present = NULL) {
    util()
}

environment(sub_sub_main) <- env

environmentName(environment(sub_sub_main))
environmentName(environment(sub_main))

expect_equal(main(foo = 3, bar = 3), list(0, 2))





## test fun call belongs to env (package)
util <- function(foo = 0, bar = 0) {
    # binds updated arguments into environment
    dots <- get_dots(search_up_nframes = 3L
                   , search_while_calls_regexp = "^sub_sub_.*")
    for (v in names(dots)) {
        assign(v, dots[[v]])
    }
    rm(dots, v)
    # report argumetns
    list(foo, bar)
}


main <- function (...) {
    sub_main(foo = 1)
}

sub_main <- function (...) {
    sub_sub_main(bar = 2)
}

sub_sub_main <- function (...) {
    util()
}

expect_equal(main(foo = 3, bar = 3), list(0, 2))
