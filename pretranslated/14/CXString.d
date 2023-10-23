module clang.c.CXString;

extern (C):

/**
 * \defgroup CINDEX_STRING String manipulation routines
 * \ingroup CINDEX
 *
 * @{
 */

/**
 * \brief A character string.
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
 * \brief Retrieve the character data associated with the given string.
 */
const(char)* clang_getCString(CXString string) @trusted @nogc pure nothrow;

/**
 * \brief Free the given string.
 */
void clang_disposeString(CXString string) @trusted @nogc pure nothrow;

/**
 * \brief Free the given string set.
 */
void clang_disposeStringSet(CXStringSet* set) @trusted @nogc pure nothrow;

/**
 * @}
 */
