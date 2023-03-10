module clang.c.CXString;
extern (C) @nogc nothrow pure @trusted:

/**
 * \defgroup CINDEX_STRING String manipulation routines
 * \ingroup CINDEX
 *
 * @{
 */

/**
 * A character string.
 *
 * The \c CXString type is used to return strings from the interface when
 * the ownership of that string might differ from one call to the next.
 * Use \c clang_getCString() to retrieve the string data and, once finished
 * with the string data, call \c clang_disposeString() to free the string.
 */
struct CXString
{
    const(void)* data;
    uint private_flags;
}

struct CXStringSet
{
    CXString* Strings;
    uint Count;
}

/**
 * Retrieve the character data associated with the given string.
 */
const(char)* clang_getCString (CXString string);

/**
 * Free the given string.
 */
void clang_disposeString (CXString string);

/**
 * Free the given string set.
 */
void clang_disposeStringSet (CXStringSet* set);

/**
 * @}
 */
