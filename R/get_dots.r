#' @details
#' An alternative way to access dots arguments without explicitly passing it through calling stack that allows updating default dots arguments that are explicitly set throughout calling stack.
#' @keywords internal
"_PACKAGE"

##' An alternative way to access dots arguments without explicitly passing it through calling stack that allows updating default dots arguments that are explicitly set throughout calling stack.
##'
##' @param function_or_arg_list The end function that meant to accept dots arguments (default arguments accessed with `formals(function_or_arg_list)`) or just explicit list of default dots arguments that will be searched up in calling stack and updated if set explicitly in higher calls. 
##' @param select_args Which arguments to select from `function_or_arg_list`. Ether character or numeric vector.
##' @param search_while_calls_have_args Arguments that should be present in each upper call to continue looking up the call stack for updates in dots arguments.
##' @param search_while_calls_belong_to_env Environment/package name (character string) to which each function in upper calls to should belong to continue looking up the call stack for updates in dots arguments.
##' @param search_while_calls_regexp Regular expression that each function name in upper calls to should matched to continue looking up the call stack for updates in dots arguments.
##' @param search_up_nframes Number of frames (aka environments) in calling stack to look up for updates in dots arguments.
##' @param search_up_to_call The name of the call before which to continue looking up the call stack for updates in dots arguments.
##' @return List of updated dots arguments
##' 
##' @md 
##' @export 
get_dots <- function(function_or_arg_list = NULL
                   , select_args = NULL
                   , search_while_calls_have_args = "..."
                   , search_while_calls_belong_to_env = NULL
                   , search_while_calls_regexp = NULL
                   , search_up_nframes = 1L
                   , search_up_to_call = NULL) {

    ## check arguments with checkmate (optionally)
    if (requireNamespace("checkmate", quietly = TRUE)) {
        checkmate::assert(checkmate::check_function(function_or_arg_list, null.ok = TRUE)
                        , checkmate::check_list(function_or_arg_list))
        checkmate::assert_character(select_args, null.ok = TRUE)
        checkmate::assert_character(search_while_calls_have_args, null.ok = TRUE)
        checkmate::assert_character(search_while_calls_belong_to_env, null.ok = TRUE)
        checkmate::assert_character(search_while_calls_regexp, null.ok = TRUE)
        checkmate::assert_integer(search_up_nframes)
        checkmate::assert_character(search_up_to_call, null.ok = TRUE)
    }
    ## set default_args
    if (is.null(function_or_arg_list)) function_or_arg_list <- sys.function(-1L)
    if (is.null(function_or_arg_list)) stop("get_dots -- supposed to be called inside function (nframe >= 1)")
    if (is.function(function_or_arg_list)) {
        default_args <- formals(function_or_arg_list)
    } else if(is.list(function_or_arg_list)) {
        default_args <- function_or_arg_list
    }
    if (length(select_args) > 0) {
        default_args <- default_args[select_args]
        if (length(default_args) == 0) stop("get_dots -- 'select_args' are not in 'formals(function_or_arg_list)'")
    }
    ## collect explicit args in parents
    explicit_args <- list()
    sp <- sys.parent()
    for (fr in sp:1) {
        ## stop searching frames stack deaper than search_up_nframes
        if (fr < 1 || (sp - fr) > search_up_nframes) break()
        ## check if we are searching only in 'friendly' functions:
        ## meaning that at least search_while_calls_have_args should exist in calls
        parent_fun <- sys.function(fr)
        parent_default_args <- formals(parent_fun)
        if (fr != sp && !all(search_while_calls_have_args %in% names(parent_default_args))) break()
        ## check if call belongs to an env (package) or has a regex name
        if (fr != sp &&
            !is.null(search_while_calls_belong_to_env) &&
            !(environmentName(environment(parent_fun)) %in% search_while_calls_belong_to_env)) break()
        ## check if call matches regexp
        parent_call <- as.list(sys.call(fr))        
        if (fr != sp &&
            !is.null(search_while_calls_regexp) &&
            !grepl(search_while_calls_regexp, as.character(parent_call[[1]]), perl = TRUE)) break()
        ## update defautls if called explicitly
        default_args <- 
            c(default_args[!(names(default_args) %in% names(parent_default_args))]
            , parent_default_args[(names(parent_default_args) %in% names(default_args))])
        ## if explicit arg is in args list and not already added add it
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
        ## stop searching frames stack at search_up_to_call call
        if (parent_call[1] %in% search_up_to_call) break()
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


dummy_function <- function() {

     return()
 }
