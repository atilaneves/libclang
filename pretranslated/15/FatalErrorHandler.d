extern (C):

/**
 * Installs error handler that prints error message to stderr and calls abort().
 * Replaces currently installed error handler (if any).
 */
void clang_install_aborting_llvm_fatal_error_handler ();

/**
 * Removes currently installed error handler (if any).
 * If no error handler is intalled, the default strategy is to print error
 * message to stderr and call exit(1).
 */
void clang_uninstall_llvm_fatal_error_handler ();
