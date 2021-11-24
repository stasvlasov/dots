##' This function provides options for `harmonizer` functions that controls how the input `data` object, intermediate and end results  are handled.
##'
##' It solves problem of passing options parameters to some arbitrary harmonizing function that are also passed with `...` (in which case there will be an error that parameters have duplicated names). Using this function allows not to pass `...` explicitly down to calling g stack and get the options values updated by explicit parameters at any location in the stack.
##' @param function_with_formals 
##' @param select_args 
##' @param search_while_calls_have_args 
##' @param search_up_to_nframes 
##' @param search_up_to_funcall 
##' @return 
##' 
##' @md 
##' @import checkmate
##' @export 
get_dots <- function(function_with_formals = NULL
                   , select_args = NULL
                   , search_while_calls_have_args = NULL
                   , search_up_nframes = 1L
                   , search_up_to_funcall = NULL) {
    ## check arguments
    checkmate::assert_function(function_with_formals, null.ok = TRUE)
    if (is.null(function_with_formals)) function_with_formals <- sys.function(-1L)
    checkmate::assert_character(select_args, null.ok = TRUE)
    checkmate::assert_character(search_while_calls_have_args, null.ok = TRUE)
    checkmate::assert_integer(search_up_to_nframes)
    checkmate::assert_character(search_up_to_funcall, null.ok = TRUE)
    ## get default arguments 
    default_args <- formals(function_with_formals)
    if (length(select_args) > 0) {
        default_args <- default_args[select_args]
        if (length(default_args) == 0) stop("get_dots -- 'select_args' are not in 'formals(function_with_formals)'")
    }
    ## collect explicit args in parents
    explicit_args <- list()
    sp <- sys.parent()
    for (fr in sp:1) {
        ## stop searching frames stack deaper than search_up_to_nframes
        if (fr < 1 || (sp - fr) > search_up_to_nframes) break()
        ## check if we are searching only in 'friendly' functions:
        ## meaning that at least search_while_calls_have_args should exist in calls
        parent_default_args <- formals(sys.function(fr))
        if (all(search_while_calls_have_args %in% names(parent_default_args))) {
            ## update defautls if called explicitly
            default_args <- 
                c(default_args[!(names(default_args) %in% names(parent_default_args))]
                , parent_default_args[(names(parent_default_args) %in% names(default_args))])
            ## if explicit arg is in args list and not already added add it
            parent_call <- as.list(sys.call(fr))
            ## parent_call <- evalq(
                ## as.list(match.call(expand.dots = FALSE))
              ## , envir = sys.frame(fr))
            parent_args <- parent_call[-1]
            if (length(parent_args) > 0) {
                args_to_add <-
                    (names(parent_args) %in% names(default_args)) &
                    !(names(parent_args) %in% names(explicit_args))
                if (any(args_to_add)) {
                    explicit_args <-
                        c(explicit_args
                        , parent_args[args_to_add] |>
                          lapply(eval, envir = sys.frame(fr)))
                }
            }
            ## stop searching frames stack at search_up_to_funcall call
            if (parent_call[1] %in% search_up_to_funcall) break()
        }
    }
    ## merge default and explicit args
    arg_update <- default_args
    if (length(explicit_args) != 0) {
        arg_update <- 
            c(explicit_args
            , default_args[!(names(default_args) %in% names(explicit_args))])
    }
    return (arg_update)
}
