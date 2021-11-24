## new functions

expect_equal(get_dots(harmonize_options), formals("harmonize_options"))

a <- function(data, col = 1234, ...) {
    get_dots(harmonize_options)
}

expect_equal(a()$col, 1234)
