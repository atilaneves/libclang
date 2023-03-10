module clang.c.index;

import clang.c.util: EnumC;

public import clang.c.CXErrorCode;
public import clang.c.CXString;
public import clang.c.documentation;

import core.stdc.config;
import core.stdc.time;

extern (D) string CINDEX_VERSION_STRINGIZE_(T0, T1)(auto ref T0 major, auto ref T1 minor)
{
    import std.conv : to;

    return to!string(major) ~ "." ~ to!string(minor);
}

alias CINDEX_VERSION_STRINGIZE = CINDEX_VERSION_STRINGIZE_;



/**
 * Visitor invoked for each cursor found by a traversal.
 *
 * This visitor function will be invoked for each cursor found by
 * clang_visitCursorChildren(). Its first argument is the cursor being
 * visited, its second argument is the parent visitor for that cursor,
 * and its third argument is the client data provided to
 * clang_visitCursorChildren().
 *
 * The visitor should return one of the \c CXChildVisitResult values
 * to direct clang_visitCursorChildren().
 */
alias CXCursorVisitor = extern(C) CXChildVisitResult function (
    CXCursor cursor,
    CXCursor parent,
    CXClientData client_data);

/**
 * Visit the children of a particular cursor.
 *
 * This function visits all the direct children of the given cursor,
 * invoking the given \p visitor function with the cursors of each
 * visited child. The traversal may be recursive, if the visitor returns
 * \c CXChildVisit_Recurse. The traversal may also be ended prematurely, if
 * the visitor returns \c CXChildVisit_Break.
 *
 * \param parent the cursor whose child may be visited. All kinds of
 * cursors can be visited, including invalid cursors (which, by
 * definition, have no children).
 *
 * \param visitor the visitor function that will be invoked for each
 * child of \p parent.
 *
 * \param client_data pointer data supplied by the client, which will
 * be passed to the visitor each time it is invoked.
 *
 * \returns a non-zero value if the traversal was terminated
 * prematurely by the visitor returning \c CXChildVisit_Break.
 */
extern(C) uint clang_visitChildren (
    in CXCursor parent,
    CXCursorVisitor visitor,
    CXClientData client_data) @trusted;

extern (C) @nogc @trusted nothrow pure:

/**
 * The version constants for the libclang API.
 * CINDEX_VERSION_MINOR should increase when there are API additions.
 * CINDEX_VERSION_MAJOR is intended for "major" source/ABI breaking changes.
 *
 * The policy about the libclang API was always to keep it source and ABI
 * compatible, thus CINDEX_VERSION_MAJOR is expected to remain stable.
 */
enum CINDEX_VERSION_MAJOR = 0;
enum CINDEX_VERSION_MINOR = 62;

extern (D) auto CINDEX_VERSION_ENCODE(T0, T1)(auto ref T0 major, auto ref T1 minor)
{
    return (major * 10000) + (minor * 1);
}

enum CINDEX_VERSION = CINDEX_VERSION_ENCODE(CINDEX_VERSION_MAJOR, CINDEX_VERSION_MINOR);


enum CINDEX_VERSION_STRING = CINDEX_VERSION_STRINGIZE(CINDEX_VERSION_MAJOR, CINDEX_VERSION_MINOR);

/** \defgroup CINDEX libclang: C Interface to Clang
 *
 * The C Interface to Clang provides a relatively small API that exposes
 * facilities for parsing source code into an abstract syntax tree (AST),
 * loading already-parsed ASTs, traversing the AST, associating
 * physical source locations with elements within the AST, and other
 * facilities that support Clang-based development tools.
 *
 * This C interface to Clang will never provide all of the information
 * representation stored in Clang's C++ AST, nor should it: the intent is to
 * maintain an API that is relatively stable from one release to the next,
 * providing only the basic functionality needed to support development tools.
 *
 * To avoid namespace pollution, data types are prefixed with "CX" and
 * functions are prefixed with "clang_".
 *
 * @{
 */

/**
 * An "index" that consists of a set of translation units that would
 * typically be linked together into an executable or library.
 */
alias CXIndex = void*;

/**
 * An opaque type representing target information for a given translation
 * unit.
 */
struct CXTargetInfoImpl;
alias CXTargetInfo = CXTargetInfoImpl*;

/**
 * A single translation unit, which resides in an index.
 */
struct CXTranslationUnitImpl;
alias CXTranslationUnit = CXTranslationUnitImpl*;

/**
 * Opaque pointer representing client data that will be passed through
 * to various callbacks and visitors.
 */
alias CXClientData = void*;

/**
 * Provides the contents of a file that has not yet been saved to disk.
 *
 * Each CXUnsavedFile instance provides the name of a file on the
 * system along with the current contents of that file that have not
 * yet been saved to disk.
 */
struct CXUnsavedFile
{
    /**
     * The file whose contents have not yet been saved.
     *
     * This file must already exist in the file system.
     */
    const(char)* Filename;

    /**
     * A buffer containing the unsaved contents of this file.
     */
    const(char)* Contents;

    /**
     * The length of the unsaved contents of this buffer.
     */
    c_ulong Length;
}

/**
 * Describes the availability of a particular entity, which indicates
 * whether the use of this entity will result in a warning or error due to
 * it being deprecated or unavailable.
 */
enum CXAvailabilityKind
{
    /**
     * The entity is available.
     */
    CXAvailability_Available = 0,
    /**
     * The entity is available, but has been deprecated (and its use is
     * not recommended).
     */
    CXAvailability_Deprecated = 1,
    /**
     * The entity is not available; any use of it will be an error.
     */
    CXAvailability_NotAvailable = 2,
    /**
     * The entity is available, but not accessible; any use of it will be
     * an error.
     */
    CXAvailability_NotAccessible = 3
}

alias CXAvailability_Available = CXAvailabilityKind.CXAvailability_Available;
alias CXAvailability_Deprecated = CXAvailabilityKind.CXAvailability_Deprecated;
alias CXAvailability_NotAvailable = CXAvailabilityKind.CXAvailability_NotAvailable;
alias CXAvailability_NotAccessible = CXAvailabilityKind.CXAvailability_NotAccessible;

/**
 * Describes a version number of the form major.minor.subminor.
 */
struct CXVersion
{
    /**
     * The major version number, e.g., the '10' in '10.7.3'. A negative
     * value indicates that there is no version number at all.
     */
    int Major;
    /**
     * The minor version number, e.g., the '7' in '10.7.3'. This value
     * will be negative if no minor version number was provided, e.g., for
     * version '10'.
     */
    int Minor;
    /**
     * The subminor version number, e.g., the '3' in '10.7.3'. This value
     * will be negative if no minor or subminor version number was provided,
     * e.g., in version '10' or '10.7'.
     */
    int Subminor;
}

/**
 * Describes the exception specification of a cursor.
 *
 * A negative value indicates that the cursor is not a function declaration.
 */
enum CXCursor_ExceptionSpecificationKind
{
    /**
     * The cursor has no exception specification.
     */
    CXCursor_ExceptionSpecificationKind_None = 0,

    /**
     * The cursor has exception specification throw()
     */
    CXCursor_ExceptionSpecificationKind_DynamicNone = 1,

    /**
     * The cursor has exception specification throw(T1, T2)
     */
    CXCursor_ExceptionSpecificationKind_Dynamic = 2,

    /**
     * The cursor has exception specification throw(...).
     */
    CXCursor_ExceptionSpecificationKind_MSAny = 3,

    /**
     * The cursor has exception specification basic noexcept.
     */
    CXCursor_ExceptionSpecificationKind_BasicNoexcept = 4,

    /**
     * The cursor has exception specification computed noexcept.
     */
    CXCursor_ExceptionSpecificationKind_ComputedNoexcept = 5,

    /**
     * The exception specification has not yet been evaluated.
     */
    CXCursor_ExceptionSpecificationKind_Unevaluated = 6,

    /**
     * The exception specification has not yet been instantiated.
     */
    CXCursor_ExceptionSpecificationKind_Uninstantiated = 7,

    /**
     * The exception specification has not been parsed yet.
     */
    CXCursor_ExceptionSpecificationKind_Unparsed = 8,

    /**
     * The cursor has a __declspec(nothrow) exception specification.
     */
    CXCursor_ExceptionSpecificationKind_NoThrow = 9
}

alias CXCursor_ExceptionSpecificationKind_None = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_None;
alias CXCursor_ExceptionSpecificationKind_DynamicNone = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_DynamicNone;
alias CXCursor_ExceptionSpecificationKind_Dynamic = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_Dynamic;
alias CXCursor_ExceptionSpecificationKind_MSAny = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_MSAny;
alias CXCursor_ExceptionSpecificationKind_BasicNoexcept = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_BasicNoexcept;
alias CXCursor_ExceptionSpecificationKind_ComputedNoexcept = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_ComputedNoexcept;
alias CXCursor_ExceptionSpecificationKind_Unevaluated = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_Unevaluated;
alias CXCursor_ExceptionSpecificationKind_Uninstantiated = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_Uninstantiated;
alias CXCursor_ExceptionSpecificationKind_Unparsed = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_Unparsed;
alias CXCursor_ExceptionSpecificationKind_NoThrow = CXCursor_ExceptionSpecificationKind.CXCursor_ExceptionSpecificationKind_NoThrow;

/**
 * Provides a shared context for creating translation units.
 *
 * It provides two options:
 *
 * - excludeDeclarationsFromPCH: When non-zero, allows enumeration of "local"
 * declarations (when loading any new translation units). A "local" declaration
 * is one that belongs in the translation unit itself and not in a precompiled
 * header that was used by the translation unit. If zero, all declarations
 * will be enumerated.
 *
 * Here is an example:
 *
 * \code
 *   // excludeDeclsFromPCH = 1, displayDiagnostics=1
 *   Idx = clang_createIndex(1, 1);
 *
 *   // IndexTest.pch was produced with the following command:
 *   // "clang -x c IndexTest.h -emit-ast -o IndexTest.pch"
 *   TU = clang_createTranslationUnit(Idx, "IndexTest.pch");
 *
 *   // This will load all the symbols from 'IndexTest.pch'
 *   clang_visitChildren(clang_getTranslationUnitCursor(TU),
 *                       TranslationUnitVisitor, 0);
 *   clang_disposeTranslationUnit(TU);
 *
 *   // This will load all the symbols from 'IndexTest.c', excluding symbols
 *   // from 'IndexTest.pch'.
 *   char *args[] = { "-Xclang", "-include-pch=IndexTest.pch" };
 *   TU = clang_createTranslationUnitFromSourceFile(Idx, "IndexTest.c", 2, args,
 *                                                  0, 0);
 *   clang_visitChildren(clang_getTranslationUnitCursor(TU),
 *                       TranslationUnitVisitor, 0);
 *   clang_disposeTranslationUnit(TU);
 * \endcode
 *
 * This process of creating the 'pch', loading it separately, and using it (via
 * -include-pch) allows 'excludeDeclsFromPCH' to remove redundant callbacks
 * (which gives the indexer the same performance benefit as the compiler).
 */
CXIndex clang_createIndex (
    int excludeDeclarationsFromPCH,
    int displayDiagnostics);

/**
 * Destroy the given index.
 *
 * The index must not be destroyed until all of the translation units created
 * within that index have been destroyed.
 */
void clang_disposeIndex (CXIndex index);

enum CXGlobalOptFlags
{
    /**
     * Used to indicate that no special CXIndex options are needed.
     */
    CXGlobalOpt_None = 0x0,

    /**
     * Used to indicate that threads that libclang creates for indexing
     * purposes should use background priority.
     *
     * Affects #clang_indexSourceFile, #clang_indexTranslationUnit,
     * #clang_parseTranslationUnit, #clang_saveTranslationUnit.
     */
    CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 0x1,

    /**
     * Used to indicate that threads that libclang creates for editing
     * purposes should use background priority.
     *
     * Affects #clang_reparseTranslationUnit, #clang_codeCompleteAt,
     * #clang_annotateTokens
     */
    CXGlobalOpt_ThreadBackgroundPriorityForEditing = 0x2,

    /**
     * Used to indicate that all threads that libclang creates should use
     * background priority.
     */
    CXGlobalOpt_ThreadBackgroundPriorityForAll = CXGlobalOpt_ThreadBackgroundPriorityForIndexing | CXGlobalOpt_ThreadBackgroundPriorityForEditing
}

alias CXGlobalOpt_None = CXGlobalOptFlags.CXGlobalOpt_None;
alias CXGlobalOpt_ThreadBackgroundPriorityForIndexing = CXGlobalOptFlags.CXGlobalOpt_ThreadBackgroundPriorityForIndexing;
alias CXGlobalOpt_ThreadBackgroundPriorityForEditing = CXGlobalOptFlags.CXGlobalOpt_ThreadBackgroundPriorityForEditing;
alias CXGlobalOpt_ThreadBackgroundPriorityForAll = CXGlobalOptFlags.CXGlobalOpt_ThreadBackgroundPriorityForAll;

/**
 * Sets general options associated with a CXIndex.
 *
 * For example:
 * \code
 * CXIndex idx = ...;
 * clang_CXIndex_setGlobalOptions(idx,
 *     clang_CXIndex_getGlobalOptions(idx) |
 *     CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
 * \endcode
 *
 * \param options A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags.
 */
void clang_CXIndex_setGlobalOptions (CXIndex, uint options);

/**
 * Gets the general options associated with a CXIndex.
 *
 * \returns A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags that
 * are associated with the given CXIndex object.
 */
uint clang_CXIndex_getGlobalOptions (CXIndex);

/**
 * Sets the invocation emission path option in a CXIndex.
 *
 * The invocation emission path specifies a path which will contain log
 * files for certain libclang invocations. A null value (default) implies that
 * libclang invocations are not logged..
 */
void clang_CXIndex_setInvocationEmissionPathOption (CXIndex, const(char)* Path);

/**
 * \defgroup CINDEX_FILES File manipulation routines
 *
 * @{
 */

/**
 * A particular source file that is part of a translation unit.
 */
alias CXFile = void*;

/**
 * Retrieve the complete file and path name of the given file.
 */
CXString clang_getFileName (CXFile SFile) pure;

/**
 * Retrieve the last modification time of the given file.
 */
time_t clang_getFileTime (CXFile SFile);

/**
 * Uniquely identifies a CXFile, that refers to the same underlying file,
 * across an indexing session.
 */
struct CXFileUniqueID
{
    ulong[3] data;
}

/**
 * Retrieve the unique ID for the given \c file.
 *
 * \param file the file to get the ID for.
 * \param outID stores the returned CXFileUniqueID.
 * \returns If there was a failure getting the unique ID, returns non-zero,
 * otherwise returns 0.
 */
int clang_getFileUniqueID (CXFile file, CXFileUniqueID* outID);

/**
 * Determine whether the given header is guarded against
 * multiple inclusions, either with the conventional
 * \#ifndef/\#define/\#endif macro guards or with \#pragma once.
 */
uint clang_isFileMultipleIncludeGuarded (CXTranslationUnit tu, CXFile file);

/**
 * Retrieve a file handle within the given translation unit.
 *
 * \param tu the translation unit
 *
 * \param file_name the name of the file.
 *
 * \returns the file handle for the named file in the translation unit \p tu,
 * or a NULL file handle if the file was not a part of this translation unit.
 */
CXFile clang_getFile (CXTranslationUnit tu, const(char)* file_name);

/**
 * Retrieve the buffer associated with the given file.
 *
 * \param tu the translation unit
 *
 * \param file the file for which to retrieve the buffer.
 *
 * \param size [out] if non-NULL, will be set to the size of the buffer.
 *
 * \returns a pointer to the buffer in memory that holds the contents of
 * \p file, or a NULL pointer when the file is not loaded.
 */
const(char)* clang_getFileContents (
    CXTranslationUnit tu,
    CXFile file,
    size_t* size);

/**
 * Returns non-zero if the \c file1 and \c file2 point to the same file,
 * or they are both NULL.
 */
int clang_File_isEqual (CXFile file1, CXFile file2);

/**
 * Returns the real path name of \c file.
 *
 * An empty string may be returned. Use \c clang_getFileName() in that case.
 */
CXString clang_File_tryGetRealPathName (CXFile file);

/**
 * @}
 */

/**
 * \defgroup CINDEX_LOCATIONS Physical source locations
 *
 * Clang represents physical source locations in its abstract syntax tree in
 * great detail, with file, line, and column information for the majority of
 * the tokens parsed in the source code. These data types and functions are
 * used to represent source location information, either for a particular
 * point in the program or for a range of points in the program, and extract
 * specific location information from those data types.
 *
 * @{
 */

/**
 * Identifies a specific source location within a translation
 * unit.
 *
 * Use clang_getExpansionLocation() or clang_getSpellingLocation()
 * to map a source location to a particular file, line, and column.
 */
struct CXSourceLocation
{
    const(void)*[2] ptr_data;
    uint int_data;
}

/**
 * Identifies a half-open character range in the source code.
 *
 * Use clang_getRangeStart() and clang_getRangeEnd() to retrieve the
 * starting and end locations from a source range, respectively.
 */
struct CXSourceRange
{
    const(void)*[2] ptr_data;
    uint begin_int_data;
    uint end_int_data;
}

/**
 * Retrieve a NULL (invalid) source location.
 */
CXSourceLocation clang_getNullLocation ();

/**
 * Determine whether two source locations, which must refer into
 * the same translation unit, refer to exactly the same point in the source
 * code.
 *
 * \returns non-zero if the source locations refer to the same location, zero
 * if they refer to different locations.
 */
uint clang_equalLocations (CXSourceLocation loc1, CXSourceLocation loc2);

/**
 * Retrieves the source location associated with a given file/line/column
 * in a particular translation unit.
 */
CXSourceLocation clang_getLocation (
    CXTranslationUnit tu,
    CXFile file,
    uint line,
    uint column);
/**
 * Retrieves the source location associated with a given character offset
 * in a particular translation unit.
 */
CXSourceLocation clang_getLocationForOffset (
    CXTranslationUnit tu,
    CXFile file,
    uint offset);

/**
 * Returns non-zero if the given source location is in a system header.
 */
int clang_Location_isInSystemHeader (CXSourceLocation location);

/**
 * Returns non-zero if the given source location is in the main file of
 * the corresponding translation unit.
 */
int clang_Location_isFromMainFile (CXSourceLocation location);

/**
 * Retrieve a NULL (invalid) source range.
 */
CXSourceRange clang_getNullRange ();

/**
 * Retrieve a source range given the beginning and ending source
 * locations.
 */
CXSourceRange clang_getRange (CXSourceLocation begin, CXSourceLocation end);

/**
 * Determine whether two ranges are equivalent.
 *
 * \returns non-zero if the ranges are the same, zero if they differ.
 */
uint clang_equalRanges (CXSourceRange range1, CXSourceRange range2);

/**
 * Returns non-zero if \p range is null.
 */
int clang_Range_isNull (CXSourceRange range) pure;

/**
 * Retrieve the file, line, column, and offset represented by
 * the given source location.
 *
 * If the location refers into a macro expansion, retrieves the
 * location of the macro expansion.
 *
 * \param location the location within a source file that will be decomposed
 * into its parts.
 *
 * \param file [out] if non-NULL, will be set to the file to which the given
 * source location points.
 *
 * \param line [out] if non-NULL, will be set to the line to which the given
 * source location points.
 *
 * \param column [out] if non-NULL, will be set to the column to which the given
 * source location points.
 *
 * \param offset [out] if non-NULL, will be set to the offset into the
 * buffer to which the given source location points.
 */
void clang_getExpansionLocation (
    CXSourceLocation location,
    CXFile* file,
    uint* line,
    uint* column,
    uint* offset) pure;

/**
 * Retrieve the file, line and column represented by the given source
 * location, as specified in a # line directive.
 *
 * Example: given the following source code in a file somefile.c
 *
 * \code
 * #123 "dummy.c" 1
 *
 * static int func(void)
 * {
 *     return 0;
 * }
 * \endcode
 *
 * the location information returned by this function would be
 *
 * File: dummy.c Line: 124 Column: 12
 *
 * whereas clang_getExpansionLocation would have returned
 *
 * File: somefile.c Line: 3 Column: 12
 *
 * \param location the location within a source file that will be decomposed
 * into its parts.
 *
 * \param filename [out] if non-NULL, will be set to the filename of the
 * source location. Note that filenames returned will be for "virtual" files,
 * which don't necessarily exist on the machine running clang - e.g. when
 * parsing preprocessed output obtained from a different environment. If
 * a non-NULL value is passed in, remember to dispose of the returned value
 * using \c clang_disposeString() once you've finished with it. For an invalid
 * source location, an empty string is returned.
 *
 * \param line [out] if non-NULL, will be set to the line number of the
 * source location. For an invalid source location, zero is returned.
 *
 * \param column [out] if non-NULL, will be set to the column number of the
 * source location. For an invalid source location, zero is returned.
 */
void clang_getPresumedLocation (
    CXSourceLocation location,
    CXString* filename,
    uint* line,
    uint* column);

/**
 * Legacy API to retrieve the file, line, column, and offset represented
 * by the given source location.
 *
 * This interface has been replaced by the newer interface
 * #clang_getExpansionLocation(). See that interface's documentation for
 * details.
 */
void clang_getInstantiationLocation (
    CXSourceLocation location,
    CXFile* file,
    uint* line,
    uint* column,
    uint* offset);

/**
 * Retrieve the file, line, column, and offset represented by
 * the given source location.
 *
 * If the location refers into a macro instantiation, return where the
 * location was originally spelled in the source file.
 *
 * \param location the location within a source file that will be decomposed
 * into its parts.
 *
 * \param file [out] if non-NULL, will be set to the file to which the given
 * source location points.
 *
 * \param line [out] if non-NULL, will be set to the line to which the given
 * source location points.
 *
 * \param column [out] if non-NULL, will be set to the column to which the given
 * source location points.
 *
 * \param offset [out] if non-NULL, will be set to the offset into the
 * buffer to which the given source location points.
 */
void clang_getSpellingLocation (
    CXSourceLocation location,
    CXFile* file,
    uint* line,
    uint* column,
    uint* offset) pure;

/**
 * Retrieve the file, line, column, and offset represented by
 * the given source location.
 *
 * If the location refers into a macro expansion, return where the macro was
 * expanded or where the macro argument was written, if the location points at
 * a macro argument.
 *
 * \param location the location within a source file that will be decomposed
 * into its parts.
 *
 * \param file [out] if non-NULL, will be set to the file to which the given
 * source location points.
 *
 * \param line [out] if non-NULL, will be set to the line to which the given
 * source location points.
 *
 * \param column [out] if non-NULL, will be set to the column to which the given
 * source location points.
 *
 * \param offset [out] if non-NULL, will be set to the offset into the
 * buffer to which the given source location points.
 */
void clang_getFileLocation (
    CXSourceLocation location,
    CXFile* file,
    uint* line,
    uint* column,
    uint* offset);

/**
 * Retrieve a source location representing the first character within a
 * source range.
 */
CXSourceLocation clang_getRangeStart (CXSourceRange range) pure;

/**
 * Retrieve a source location representing the last character within a
 * source range.
 */
CXSourceLocation clang_getRangeEnd (CXSourceRange range) pure;

/**
 * Identifies an array of ranges.
 */
struct CXSourceRangeList
{
    /** The number of ranges in the \c ranges array. */
    uint count;
    /**
     * An array of \c CXSourceRanges.
     */
    CXSourceRange* ranges;
}

/**
 * Retrieve all ranges that were skipped by the preprocessor.
 *
 * The preprocessor will skip lines when they are surrounded by an
 * if/ifdef/ifndef directive whose condition does not evaluate to true.
 */
CXSourceRangeList* clang_getSkippedRanges (CXTranslationUnit tu, CXFile file);

/**
 * Retrieve all ranges from all files that were skipped by the
 * preprocessor.
 *
 * The preprocessor will skip lines when they are surrounded by an
 * if/ifdef/ifndef directive whose condition does not evaluate to true.
 */
CXSourceRangeList* clang_getAllSkippedRanges (CXTranslationUnit tu);

/**
 * Destroy the given \c CXSourceRangeList.
 */
void clang_disposeSourceRangeList (CXSourceRangeList* ranges);

/**
 * @}
 */

/**
 * \defgroup CINDEX_DIAG Diagnostic reporting
 *
 * @{
 */

/**
 * Describes the severity of a particular diagnostic.
 */
enum CXDiagnosticSeverity
{
    /**
     * A diagnostic that has been suppressed, e.g., by a command-line
     * option.
     */
    CXDiagnostic_Ignored = 0,

    /**
     * This diagnostic is a note that should be attached to the
     * previous (non-note) diagnostic.
     */
    CXDiagnostic_Note = 1,

    /**
     * This diagnostic indicates suspicious code that may not be
     * wrong.
     */
    CXDiagnostic_Warning = 2,

    /**
     * This diagnostic indicates that the code is ill-formed.
     */
    CXDiagnostic_Error = 3,

    /**
     * This diagnostic indicates that the code is ill-formed such
     * that future parser recovery is unlikely to produce useful
     * results.
     */
    CXDiagnostic_Fatal = 4
}

alias CXDiagnostic_Ignored = CXDiagnosticSeverity.CXDiagnostic_Ignored;
alias CXDiagnostic_Note = CXDiagnosticSeverity.CXDiagnostic_Note;
alias CXDiagnostic_Warning = CXDiagnosticSeverity.CXDiagnostic_Warning;
alias CXDiagnostic_Error = CXDiagnosticSeverity.CXDiagnostic_Error;
alias CXDiagnostic_Fatal = CXDiagnosticSeverity.CXDiagnostic_Fatal;

/**
 * A single diagnostic, containing the diagnostic's severity,
 * location, text, source ranges, and fix-it hints.
 */
alias CXDiagnostic = void*;

/**
 * A group of CXDiagnostics.
 */
alias CXDiagnosticSet = void*;

/**
 * Determine the number of diagnostics in a CXDiagnosticSet.
 */
uint clang_getNumDiagnosticsInSet (CXDiagnosticSet Diags);

/**
 * Retrieve a diagnostic associated with the given CXDiagnosticSet.
 *
 * \param Diags the CXDiagnosticSet to query.
 * \param Index the zero-based diagnostic number to retrieve.
 *
 * \returns the requested diagnostic. This diagnostic must be freed
 * via a call to \c clang_disposeDiagnostic().
 */
CXDiagnostic clang_getDiagnosticInSet (CXDiagnosticSet Diags, uint Index);

/**
 * Describes the kind of error that occurred (if any) in a call to
 * \c clang_loadDiagnostics.
 */
enum CXLoadDiag_Error
{
    /**
     * Indicates that no error occurred.
     */
    CXLoadDiag_None = 0,

    /**
     * Indicates that an unknown error occurred while attempting to
     * deserialize diagnostics.
     */
    CXLoadDiag_Unknown = 1,

    /**
     * Indicates that the file containing the serialized diagnostics
     * could not be opened.
     */
    CXLoadDiag_CannotLoad = 2,

    /**
     * Indicates that the serialized diagnostics file is invalid or
     * corrupt.
     */
    CXLoadDiag_InvalidFile = 3
}

alias CXLoadDiag_None = CXLoadDiag_Error.CXLoadDiag_None;
alias CXLoadDiag_Unknown = CXLoadDiag_Error.CXLoadDiag_Unknown;
alias CXLoadDiag_CannotLoad = CXLoadDiag_Error.CXLoadDiag_CannotLoad;
alias CXLoadDiag_InvalidFile = CXLoadDiag_Error.CXLoadDiag_InvalidFile;

/**
 * Deserialize a set of diagnostics from a Clang diagnostics bitcode
 * file.
 *
 * \param file The name of the file to deserialize.
 * \param error A pointer to a enum value recording if there was a problem
 *        deserializing the diagnostics.
 * \param errorString A pointer to a CXString for recording the error string
 *        if the file was not successfully loaded.
 *
 * \returns A loaded CXDiagnosticSet if successful, and NULL otherwise.  These
 * diagnostics should be released using clang_disposeDiagnosticSet().
 */
CXDiagnosticSet clang_loadDiagnostics (
    const(char)* file,
    CXLoadDiag_Error* error,
    CXString* errorString);

/**
 * Release a CXDiagnosticSet and all of its contained diagnostics.
 */
void clang_disposeDiagnosticSet (CXDiagnosticSet Diags);

/**
 * Retrieve the child diagnostics of a CXDiagnostic.
 *
 * This CXDiagnosticSet does not need to be released by
 * clang_disposeDiagnosticSet.
 */
CXDiagnosticSet clang_getChildDiagnostics (CXDiagnostic D);

/**
 * Determine the number of diagnostics produced for the given
 * translation unit.
 */
uint clang_getNumDiagnostics (CXTranslationUnit Unit);

/**
 * Retrieve a diagnostic associated with the given translation unit.
 *
 * \param Unit the translation unit to query.
 * \param Index the zero-based diagnostic number to retrieve.
 *
 * \returns the requested diagnostic. This diagnostic must be freed
 * via a call to \c clang_disposeDiagnostic().
 */
CXDiagnostic clang_getDiagnostic (CXTranslationUnit Unit, uint Index);

/**
 * Retrieve the complete set of diagnostics associated with a
 *        translation unit.
 *
 * \param Unit the translation unit to query.
 */
CXDiagnosticSet clang_getDiagnosticSetFromTU (CXTranslationUnit Unit);

/**
 * Destroy a diagnostic.
 */
void clang_disposeDiagnostic (CXDiagnostic Diagnostic);

/**
 * Options to control the display of diagnostics.
 *
 * The values in this enum are meant to be combined to customize the
 * behavior of \c clang_formatDiagnostic().
 */
enum CXDiagnosticDisplayOptions
{
    /**
     * Display the source-location information where the
     * diagnostic was located.
     *
     * When set, diagnostics will be prefixed by the file, line, and
     * (optionally) column to which the diagnostic refers. For example,
     *
     * \code
     * test.c:28: warning: extra tokens at end of #endif directive
     * \endcode
     *
     * This option corresponds to the clang flag \c -fshow-source-location.
     */
    CXDiagnostic_DisplaySourceLocation = 0x01,

    /**
     * If displaying the source-location information of the
     * diagnostic, also include the column number.
     *
     * This option corresponds to the clang flag \c -fshow-column.
     */
    CXDiagnostic_DisplayColumn = 0x02,

    /**
     * If displaying the source-location information of the
     * diagnostic, also include information about source ranges in a
     * machine-parsable format.
     *
     * This option corresponds to the clang flag
     * \c -fdiagnostics-print-source-range-info.
     */
    CXDiagnostic_DisplaySourceRanges = 0x04,

    /**
     * Display the option name associated with this diagnostic, if any.
     *
     * The option name displayed (e.g., -Wconversion) will be placed in brackets
     * after the diagnostic text. This option corresponds to the clang flag
     * \c -fdiagnostics-show-option.
     */
    CXDiagnostic_DisplayOption = 0x08,

    /**
     * Display the category number associated with this diagnostic, if any.
     *
     * The category number is displayed within brackets after the diagnostic text.
     * This option corresponds to the clang flag
     * \c -fdiagnostics-show-category=id.
     */
    CXDiagnostic_DisplayCategoryId = 0x10,

    /**
     * Display the category name associated with this diagnostic, if any.
     *
     * The category name is displayed within brackets after the diagnostic text.
     * This option corresponds to the clang flag
     * \c -fdiagnostics-show-category=name.
     */
    CXDiagnostic_DisplayCategoryName = 0x20
}

alias CXDiagnostic_DisplaySourceLocation = CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceLocation;
alias CXDiagnostic_DisplayColumn = CXDiagnosticDisplayOptions.CXDiagnostic_DisplayColumn;
alias CXDiagnostic_DisplaySourceRanges = CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceRanges;
alias CXDiagnostic_DisplayOption = CXDiagnosticDisplayOptions.CXDiagnostic_DisplayOption;
alias CXDiagnostic_DisplayCategoryId = CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryId;
alias CXDiagnostic_DisplayCategoryName = CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryName;

/**
 * Format the given diagnostic in a manner that is suitable for display.
 *
 * This routine will format the given diagnostic to a string, rendering
 * the diagnostic according to the various options given. The
 * \c clang_defaultDiagnosticDisplayOptions() function returns the set of
 * options that most closely mimics the behavior of the clang compiler.
 *
 * \param Diagnostic The diagnostic to print.
 *
 * \param Options A set of options that control the diagnostic display,
 * created by combining \c CXDiagnosticDisplayOptions values.
 *
 * \returns A new string containing for formatted diagnostic.
 */
CXString clang_formatDiagnostic (CXDiagnostic Diagnostic, uint Options);

/**
 * Retrieve the set of display options most similar to the
 * default behavior of the clang compiler.
 *
 * \returns A set of display options suitable for use with \c
 * clang_formatDiagnostic().
 */
uint clang_defaultDiagnosticDisplayOptions ();

/**
 * Determine the severity of the given diagnostic.
 */
CXDiagnosticSeverity clang_getDiagnosticSeverity (CXDiagnostic);

/**
 * Retrieve the source location of the given diagnostic.
 *
 * This location is where Clang would print the caret ('^') when
 * displaying the diagnostic on the command line.
 */
CXSourceLocation clang_getDiagnosticLocation (CXDiagnostic);

/**
 * Retrieve the text of the given diagnostic.
 */
CXString clang_getDiagnosticSpelling (CXDiagnostic);

/**
 * Retrieve the name of the command-line option that enabled this
 * diagnostic.
 *
 * \param Diag The diagnostic to be queried.
 *
 * \param Disable If non-NULL, will be set to the option that disables this
 * diagnostic (if any).
 *
 * \returns A string that contains the command-line option used to enable this
 * warning, such as "-Wconversion" or "-pedantic".
 */
CXString clang_getDiagnosticOption (CXDiagnostic Diag, CXString* Disable);

/**
 * Retrieve the category number for this diagnostic.
 *
 * Diagnostics can be categorized into groups along with other, related
 * diagnostics (e.g., diagnostics under the same warning flag). This routine
 * retrieves the category number for the given diagnostic.
 *
 * \returns The number of the category that contains this diagnostic, or zero
 * if this diagnostic is uncategorized.
 */
uint clang_getDiagnosticCategory (CXDiagnostic);

/**
 * Retrieve the name of a particular diagnostic category.  This
 *  is now deprecated.  Use clang_getDiagnosticCategoryText()
 *  instead.
 *
 * \param Category A diagnostic category number, as returned by
 * \c clang_getDiagnosticCategory().
 *
 * \returns The name of the given diagnostic category.
 */
CXString clang_getDiagnosticCategoryName (uint Category);

/**
 * Retrieve the diagnostic category text for a given diagnostic.
 *
 * \returns The text of the given diagnostic category.
 */
CXString clang_getDiagnosticCategoryText (CXDiagnostic);

/**
 * Determine the number of source ranges associated with the given
 * diagnostic.
 */
uint clang_getDiagnosticNumRanges (CXDiagnostic);

/**
 * Retrieve a source range associated with the diagnostic.
 *
 * A diagnostic's source ranges highlight important elements in the source
 * code. On the command line, Clang displays source ranges by
 * underlining them with '~' characters.
 *
 * \param Diagnostic the diagnostic whose range is being extracted.
 *
 * \param Range the zero-based index specifying which range to
 *
 * \returns the requested source range.
 */
CXSourceRange clang_getDiagnosticRange (CXDiagnostic Diagnostic, uint Range);

/**
 * Determine the number of fix-it hints associated with the
 * given diagnostic.
 */
uint clang_getDiagnosticNumFixIts (CXDiagnostic Diagnostic);

/**
 * Retrieve the replacement information for a given fix-it.
 *
 * Fix-its are described in terms of a source range whose contents
 * should be replaced by a string. This approach generalizes over
 * three kinds of operations: removal of source code (the range covers
 * the code to be removed and the replacement string is empty),
 * replacement of source code (the range covers the code to be
 * replaced and the replacement string provides the new code), and
 * insertion (both the start and end of the range point at the
 * insertion location, and the replacement string provides the text to
 * insert).
 *
 * \param Diagnostic The diagnostic whose fix-its are being queried.
 *
 * \param FixIt The zero-based index of the fix-it.
 *
 * \param ReplacementRange The source range whose contents will be
 * replaced with the returned replacement string. Note that source
 * ranges are half-open ranges [a, b), so the source code should be
 * replaced from a and up to (but not including) b.
 *
 * \returns A string containing text that should be replace the source
 * code indicated by the \c ReplacementRange.
 */
CXString clang_getDiagnosticFixIt (
    CXDiagnostic Diagnostic,
    uint FixIt,
    CXSourceRange* ReplacementRange);

/**
 * @}
 */

/**
 * \defgroup CINDEX_TRANSLATION_UNIT Translation unit manipulation
 *
 * The routines in this group provide the ability to create and destroy
 * translation units from files, either by parsing the contents of the files or
 * by reading in a serialized representation of a translation unit.
 *
 * @{
 */

/**
 * Get the original translation unit source file name.
 */
CXString clang_getTranslationUnitSpelling (in CXTranslationUnit CTUnit) pure;

/**
 * Return the CXTranslationUnit for a given source file and the provided
 * command line arguments one would pass to the compiler.
 *
 * Note: The 'source_filename' argument is optional.  If the caller provides a
 * NULL pointer, the name of the source file is expected to reside in the
 * specified command line arguments.
 *
 * Note: When encountered in 'clang_command_line_args', the following options
 * are ignored:
 *
 *   '-c'
 *   '-emit-ast'
 *   '-fsyntax-only'
 *   '-o \<output file>'  (both '-o' and '\<output file>' are ignored)
 *
 * \param CIdx The index object with which the translation unit will be
 * associated.
 *
 * \param source_filename The name of the source file to load, or NULL if the
 * source file is included in \p clang_command_line_args.
 *
 * \param num_clang_command_line_args The number of command-line arguments in
 * \p clang_command_line_args.
 *
 * \param clang_command_line_args The command-line arguments that would be
 * passed to the \c clang executable if it were being invoked out-of-process.
 * These command-line options will be parsed and will affect how the translation
 * unit is parsed. Note that the following options are ignored: '-c',
 * '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
 *
 * \param num_unsaved_files the number of unsaved file entries in \p
 * unsaved_files.
 *
 * \param unsaved_files the files that have not yet been saved to disk
 * but may be required for code completion, including the contents of
 * those files.  The contents and name of these files (as specified by
 * CXUnsavedFile) are copied when necessary, so the client only needs to
 * guarantee their validity until the call to this function returns.
 */
CXTranslationUnit clang_createTranslationUnitFromSourceFile (
    CXIndex CIdx,
    const(char)* source_filename,
    int num_clang_command_line_args,
    const(char*)* clang_command_line_args,
    uint num_unsaved_files,
    CXUnsavedFile* unsaved_files);

/**
 * Same as \c clang_createTranslationUnit2, but returns
 * the \c CXTranslationUnit instead of an error code.  In case of an error this
 * routine returns a \c NULL \c CXTranslationUnit, without further detailed
 * error codes.
 */
CXTranslationUnit clang_createTranslationUnit (
    CXIndex CIdx,
    const(char)* ast_filename);

/**
 * Create a translation unit from an AST file (\c -emit-ast).
 *
 * \param[out] out_TU A non-NULL pointer to store the created
 * \c CXTranslationUnit.
 *
 * \returns Zero on success, otherwise returns an error code.
 */
CXErrorCode clang_createTranslationUnit2 (
    CXIndex CIdx,
    const(char)* ast_filename,
    CXTranslationUnit* out_TU);

/**
 * Flags that control the creation of translation units.
 *
 * The enumerators in this enumeration type are meant to be bitwise
 * ORed together to specify which options should be used when
 * constructing the translation unit.
 */
enum CXTranslationUnit_Flags
{
    /**
     * Used to indicate that no special translation-unit options are
     * needed.
     */
    CXTranslationUnit_None = 0x0,

    /**
     * Used to indicate that the parser should construct a "detailed"
     * preprocessing record, including all macro definitions and instantiations.
     *
     * Constructing a detailed preprocessing record requires more memory
     * and time to parse, since the information contained in the record
     * is usually not retained. However, it can be useful for
     * applications that require more detailed information about the
     * behavior of the preprocessor.
     */
    CXTranslationUnit_DetailedPreprocessingRecord = 0x01,

    /**
     * Used to indicate that the translation unit is incomplete.
     *
     * When a translation unit is considered "incomplete", semantic
     * analysis that is typically performed at the end of the
     * translation unit will be suppressed. For example, this suppresses
     * the completion of tentative declarations in C and of
     * instantiation of implicitly-instantiation function templates in
     * C++. This option is typically used when parsing a header with the
     * intent of producing a precompiled header.
     */
    CXTranslationUnit_Incomplete = 0x02,

    /**
     * Used to indicate that the translation unit should be built with an
     * implicit precompiled header for the preamble.
     *
     * An implicit precompiled header is used as an optimization when a
     * particular translation unit is likely to be reparsed many times
     * when the sources aren't changing that often. In this case, an
     * implicit precompiled header will be built containing all of the
     * initial includes at the top of the main file (what we refer to as
     * the "preamble" of the file). In subsequent parses, if the
     * preamble or the files in it have not changed, \c
     * clang_reparseTranslationUnit() will re-use the implicit
     * precompiled header to improve parsing performance.
     */
    CXTranslationUnit_PrecompiledPreamble = 0x04,

    /**
     * Used to indicate that the translation unit should cache some
     * code-completion results with each reparse of the source file.
     *
     * Caching of code-completion results is a performance optimization that
     * introduces some overhead to reparsing but improves the performance of
     * code-completion operations.
     */
    CXTranslationUnit_CacheCompletionResults = 0x08,

    /**
     * Used to indicate that the translation unit will be serialized with
     * \c clang_saveTranslationUnit.
     *
     * This option is typically used when parsing a header with the intent of
     * producing a precompiled header.
     */
    CXTranslationUnit_ForSerialization = 0x10,

    /**
     * DEPRECATED: Enabled chained precompiled preambles in C++.
     *
     * Note: this is a *temporary* option that is available only while
     * we are testing C++ precompiled preamble support. It is deprecated.
     */
    CXTranslationUnit_CXXChainedPCH = 0x20,

    /**
     * Used to indicate that function/method bodies should be skipped while
     * parsing.
     *
     * This option can be used to search for declarations/definitions while
     * ignoring the usages.
     */
    CXTranslationUnit_SkipFunctionBodies = 0x40,

    /**
     * Used to indicate that brief documentation comments should be
     * included into the set of code completions returned from this translation
     * unit.
     */
    CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 0x80,

    /**
     * Used to indicate that the precompiled preamble should be created on
     * the first parse. Otherwise it will be created on the first reparse. This
     * trades runtime on the first parse (serializing the preamble takes time) for
     * reduced runtime on the second parse (can now reuse the preamble).
     */
    CXTranslationUnit_CreatePreambleOnFirstParse = 0x100,

    /**
     * Do not stop processing when fatal errors are encountered.
     *
     * When fatal errors are encountered while parsing a translation unit,
     * semantic analysis is typically stopped early when compiling code. A common
     * source for fatal errors are unresolvable include files. For the
     * purposes of an IDE, this is undesirable behavior and as much information
     * as possible should be reported. Use this flag to enable this behavior.
     */
    CXTranslationUnit_KeepGoing = 0x200,

    /**
     * Sets the preprocessor in a mode for parsing a single file only.
     */
    CXTranslationUnit_SingleFileParse = 0x400,

    /**
     * Used in combination with CXTranslationUnit_SkipFunctionBodies to
     * constrain the skipping of function bodies to the preamble.
     *
     * The function bodies of the main file are not skipped.
     */
    CXTranslationUnit_LimitSkipFunctionBodiesToPreamble = 0x800,

    /**
     * Used to indicate that attributed types should be included in CXType.
     */
    CXTranslationUnit_IncludeAttributedTypes = 0x1000,

    /**
     * Used to indicate that implicit attributes should be visited.
     */
    CXTranslationUnit_VisitImplicitAttributes = 0x2000,

    /**
     * Used to indicate that non-errors from included files should be ignored.
     *
     * If set, clang_getDiagnosticSetFromTU() will not report e.g. warnings from
     * included files anymore. This speeds up clang_getDiagnosticSetFromTU() for
     * the case where these warnings are not of interest, as for an IDE for
     * example, which typically shows only the diagnostics in the main file.
     */
    CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles = 0x4000,

    /**
     * Tells the preprocessor not to skip excluded conditional blocks.
     */
    CXTranslationUnit_RetainExcludedConditionalBlocks = 0x8000
}

alias CXTranslationUnit_None = CXTranslationUnit_Flags.CXTranslationUnit_None;
alias CXTranslationUnit_DetailedPreprocessingRecord = CXTranslationUnit_Flags.CXTranslationUnit_DetailedPreprocessingRecord;
alias CXTranslationUnit_Incomplete = CXTranslationUnit_Flags.CXTranslationUnit_Incomplete;
alias CXTranslationUnit_PrecompiledPreamble = CXTranslationUnit_Flags.CXTranslationUnit_PrecompiledPreamble;
alias CXTranslationUnit_CacheCompletionResults = CXTranslationUnit_Flags.CXTranslationUnit_CacheCompletionResults;
alias CXTranslationUnit_ForSerialization = CXTranslationUnit_Flags.CXTranslationUnit_ForSerialization;
alias CXTranslationUnit_CXXChainedPCH = CXTranslationUnit_Flags.CXTranslationUnit_CXXChainedPCH;
alias CXTranslationUnit_SkipFunctionBodies = CXTranslationUnit_Flags.CXTranslationUnit_SkipFunctionBodies;
alias CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = CXTranslationUnit_Flags.CXTranslationUnit_IncludeBriefCommentsInCodeCompletion;
alias CXTranslationUnit_CreatePreambleOnFirstParse = CXTranslationUnit_Flags.CXTranslationUnit_CreatePreambleOnFirstParse;
alias CXTranslationUnit_KeepGoing = CXTranslationUnit_Flags.CXTranslationUnit_KeepGoing;
alias CXTranslationUnit_SingleFileParse = CXTranslationUnit_Flags.CXTranslationUnit_SingleFileParse;
alias CXTranslationUnit_LimitSkipFunctionBodiesToPreamble = CXTranslationUnit_Flags.CXTranslationUnit_LimitSkipFunctionBodiesToPreamble;
alias CXTranslationUnit_IncludeAttributedTypes = CXTranslationUnit_Flags.CXTranslationUnit_IncludeAttributedTypes;
alias CXTranslationUnit_VisitImplicitAttributes = CXTranslationUnit_Flags.CXTranslationUnit_VisitImplicitAttributes;
alias CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles = CXTranslationUnit_Flags.CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles;
alias CXTranslationUnit_RetainExcludedConditionalBlocks = CXTranslationUnit_Flags.CXTranslationUnit_RetainExcludedConditionalBlocks;

/**
 * Returns the set of flags that is suitable for parsing a translation
 * unit that is being edited.
 *
 * The set of flags returned provide options for \c clang_parseTranslationUnit()
 * to indicate that the translation unit is likely to be reparsed many times,
 * either explicitly (via \c clang_reparseTranslationUnit()) or implicitly
 * (e.g., by code completion (\c clang_codeCompletionAt())). The returned flag
 * set contains an unspecified set of optimizations (e.g., the precompiled
 * preamble) geared toward improving the performance of these routines. The
 * set of optimizations enabled may change from one version to the next.
 */
uint clang_defaultEditingTranslationUnitOptions ();

/**
 * Same as \c clang_parseTranslationUnit2, but returns
 * the \c CXTranslationUnit instead of an error code.  In case of an error this
 * routine returns a \c NULL \c CXTranslationUnit, without further detailed
 * error codes.
 */
CXTranslationUnit clang_parseTranslationUnit (
    CXIndex CIdx,
    const(char)* source_filename,
    const(char*)* command_line_args,
    int num_command_line_args,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    uint options);

/**
 * Parse the given source file and the translation unit corresponding
 * to that file.
 *
 * This routine is the main entry point for the Clang C API, providing the
 * ability to parse a source file into a translation unit that can then be
 * queried by other functions in the API. This routine accepts a set of
 * command-line arguments so that the compilation can be configured in the same
 * way that the compiler is configured on the command line.
 *
 * \param CIdx The index object with which the translation unit will be
 * associated.
 *
 * \param source_filename The name of the source file to load, or NULL if the
 * source file is included in \c command_line_args.
 *
 * \param command_line_args The command-line arguments that would be
 * passed to the \c clang executable if it were being invoked out-of-process.
 * These command-line options will be parsed and will affect how the translation
 * unit is parsed. Note that the following options are ignored: '-c',
 * '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
 *
 * \param num_command_line_args The number of command-line arguments in
 * \c command_line_args.
 *
 * \param unsaved_files the files that have not yet been saved to disk
 * but may be required for parsing, including the contents of
 * those files.  The contents and name of these files (as specified by
 * CXUnsavedFile) are copied when necessary, so the client only needs to
 * guarantee their validity until the call to this function returns.
 *
 * \param num_unsaved_files the number of unsaved file entries in \p
 * unsaved_files.
 *
 * \param options A bitmask of options that affects how the translation unit
 * is managed but not its compilation. This should be a bitwise OR of the
 * CXTranslationUnit_XXX flags.
 *
 * \param[out] out_TU A non-NULL pointer to store the created
 * \c CXTranslationUnit, describing the parsed code and containing any
 * diagnostics produced by the compiler.
 *
 * \returns Zero on success, otherwise returns an error code.
 */
CXErrorCode clang_parseTranslationUnit2 (
    CXIndex CIdx,
    const(char)* source_filename,
    const(char*)* command_line_args,
    int num_command_line_args,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    uint options,
    CXTranslationUnit* out_TU);

/**
 * Same as clang_parseTranslationUnit2 but requires a full command line
 * for \c command_line_args including argv[0]. This is useful if the standard
 * library paths are relative to the binary.
 */
CXErrorCode clang_parseTranslationUnit2FullArgv (
    CXIndex CIdx,
    const(char)* source_filename,
    const(char*)* command_line_args,
    int num_command_line_args,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    uint options,
    CXTranslationUnit* out_TU);

/**
 * Flags that control how translation units are saved.
 *
 * The enumerators in this enumeration type are meant to be bitwise
 * ORed together to specify which options should be used when
 * saving the translation unit.
 */
enum CXSaveTranslationUnit_Flags
{
    /**
     * Used to indicate that no special saving options are needed.
     */
    CXSaveTranslationUnit_None = 0x0
}

alias CXSaveTranslationUnit_None = CXSaveTranslationUnit_Flags.CXSaveTranslationUnit_None;

/**
 * Returns the set of flags that is suitable for saving a translation
 * unit.
 *
 * The set of flags returned provide options for
 * \c clang_saveTranslationUnit() by default. The returned flag
 * set contains an unspecified set of options that save translation units with
 * the most commonly-requested data.
 */
uint clang_defaultSaveOptions (in CXTranslationUnit TU);

/**
 * Describes the kind of error that occurred (if any) in a call to
 * \c clang_saveTranslationUnit().
 */
enum CXSaveError
{
    /**
     * Indicates that no error occurred while saving a translation unit.
     */
    CXSaveError_None = 0,

    /**
     * Indicates that an unknown error occurred while attempting to save
     * the file.
     *
     * This error typically indicates that file I/O failed when attempting to
     * write the file.
     */
    CXSaveError_Unknown = 1,

    /**
     * Indicates that errors during translation prevented this attempt
     * to save the translation unit.
     *
     * Errors that prevent the translation unit from being saved can be
     * extracted using \c clang_getNumDiagnostics() and \c clang_getDiagnostic().
     */
    CXSaveError_TranslationErrors = 2,

    /**
     * Indicates that the translation unit to be saved was somehow
     * invalid (e.g., NULL).
     */
    CXSaveError_InvalidTU = 3
}

alias CXSaveError_None = CXSaveError.CXSaveError_None;
alias CXSaveError_Unknown = CXSaveError.CXSaveError_Unknown;
alias CXSaveError_TranslationErrors = CXSaveError.CXSaveError_TranslationErrors;
alias CXSaveError_InvalidTU = CXSaveError.CXSaveError_InvalidTU;

/**
 * Saves a translation unit into a serialized representation of
 * that translation unit on disk.
 *
 * Any translation unit that was parsed without error can be saved
 * into a file. The translation unit can then be deserialized into a
 * new \c CXTranslationUnit with \c clang_createTranslationUnit() or,
 * if it is an incomplete translation unit that corresponds to a
 * header, used as a precompiled header when parsing other translation
 * units.
 *
 * \param TU The translation unit to save.
 *
 * \param FileName The file to which the translation unit will be saved.
 *
 * \param options A bitmask of options that affects how the translation unit
 * is saved. This should be a bitwise OR of the
 * CXSaveTranslationUnit_XXX flags.
 *
 * \returns A value that will match one of the enumerators of the CXSaveError
 * enumeration. Zero (CXSaveError_None) indicates that the translation unit was
 * saved successfully, while a non-zero value indicates that a problem occurred.
 */
int clang_saveTranslationUnit (
    CXTranslationUnit TU,
    const(char)* FileName,
    uint options);

/**
 * Suspend a translation unit in order to free memory associated with it.
 *
 * A suspended translation unit uses significantly less memory but on the other
 * side does not support any other calls than \c clang_reparseTranslationUnit
 * to resume it or \c clang_disposeTranslationUnit to dispose it completely.
 */
uint clang_suspendTranslationUnit (in CXTranslationUnit);

/**
 * Destroy the specified CXTranslationUnit object.
 */
void clang_disposeTranslationUnit (in CXTranslationUnit);

/**
 * Flags that control the reparsing of translation units.
 *
 * The enumerators in this enumeration type are meant to be bitwise
 * ORed together to specify which options should be used when
 * reparsing the translation unit.
 */
enum CXReparse_Flags
{
    /**
     * Used to indicate that no special reparsing options are needed.
     */
    CXReparse_None = 0x0
}

alias CXReparse_None = CXReparse_Flags.CXReparse_None;

/**
 * Returns the set of flags that is suitable for reparsing a translation
 * unit.
 *
 * The set of flags returned provide options for
 * \c clang_reparseTranslationUnit() by default. The returned flag
 * set contains an unspecified set of optimizations geared toward common uses
 * of reparsing. The set of optimizations enabled may change from one version
 * to the next.
 */
uint clang_defaultReparseOptions (in CXTranslationUnit TU);

/**
 * Reparse the source files that produced this translation unit.
 *
 * This routine can be used to re-parse the source files that originally
 * created the given translation unit, for example because those source files
 * have changed (either on disk or as passed via \p unsaved_files). The
 * source code will be reparsed with the same command-line options as it
 * was originally parsed.
 *
 * Reparsing a translation unit invalidates all cursors and source locations
 * that refer into that translation unit. This makes reparsing a translation
 * unit semantically equivalent to destroying the translation unit and then
 * creating a new translation unit with the same command-line arguments.
 * However, it may be more efficient to reparse a translation
 * unit using this routine.
 *
 * \param TU The translation unit whose contents will be re-parsed. The
 * translation unit must originally have been built with
 * \c clang_createTranslationUnitFromSourceFile().
 *
 * \param num_unsaved_files The number of unsaved file entries in \p
 * unsaved_files.
 *
 * \param unsaved_files The files that have not yet been saved to disk
 * but may be required for parsing, including the contents of
 * those files.  The contents and name of these files (as specified by
 * CXUnsavedFile) are copied when necessary, so the client only needs to
 * guarantee their validity until the call to this function returns.
 *
 * \param options A bitset of options composed of the flags in CXReparse_Flags.
 * The function \c clang_defaultReparseOptions() produces a default set of
 * options recommended for most uses, based on the translation unit.
 *
 * \returns 0 if the sources could be reparsed.  A non-zero error code will be
 * returned if reparsing was impossible, such that the translation unit is
 * invalid. In such cases, the only valid call for \c TU is
 * \c clang_disposeTranslationUnit(TU).  The error codes returned by this
 * routine are described by the \c CXErrorCode enum.
 */
int clang_reparseTranslationUnit (
    CXTranslationUnit TU,
    uint num_unsaved_files,
    CXUnsavedFile* unsaved_files,
    uint options);

/**
 * Categorizes how memory is being used by a translation unit.
 */
enum CXTUResourceUsageKind
{
    CXTUResourceUsage_AST = 1,
    CXTUResourceUsage_Identifiers = 2,
    CXTUResourceUsage_Selectors = 3,
    CXTUResourceUsage_GlobalCompletionResults = 4,
    CXTUResourceUsage_SourceManagerContentCache = 5,
    CXTUResourceUsage_AST_SideTables = 6,
    CXTUResourceUsage_SourceManager_Membuffer_Malloc = 7,
    CXTUResourceUsage_SourceManager_Membuffer_MMap = 8,
    CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc = 9,
    CXTUResourceUsage_ExternalASTSource_Membuffer_MMap = 10,
    CXTUResourceUsage_Preprocessor = 11,
    CXTUResourceUsage_PreprocessingRecord = 12,
    CXTUResourceUsage_SourceManager_DataStructures = 13,
    CXTUResourceUsage_Preprocessor_HeaderSearch = 14,
    CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN = CXTUResourceUsage_AST,
    CXTUResourceUsage_MEMORY_IN_BYTES_END = CXTUResourceUsage_Preprocessor_HeaderSearch,

    CXTUResourceUsage_First = CXTUResourceUsage_AST,
    CXTUResourceUsage_Last = CXTUResourceUsage_Preprocessor_HeaderSearch
}

alias CXTUResourceUsage_AST = CXTUResourceUsageKind.CXTUResourceUsage_AST;
alias CXTUResourceUsage_Identifiers = CXTUResourceUsageKind.CXTUResourceUsage_Identifiers;
alias CXTUResourceUsage_Selectors = CXTUResourceUsageKind.CXTUResourceUsage_Selectors;
alias CXTUResourceUsage_GlobalCompletionResults = CXTUResourceUsageKind.CXTUResourceUsage_GlobalCompletionResults;
alias CXTUResourceUsage_SourceManagerContentCache = CXTUResourceUsageKind.CXTUResourceUsage_SourceManagerContentCache;
alias CXTUResourceUsage_AST_SideTables = CXTUResourceUsageKind.CXTUResourceUsage_AST_SideTables;
alias CXTUResourceUsage_SourceManager_Membuffer_Malloc = CXTUResourceUsageKind.CXTUResourceUsage_SourceManager_Membuffer_Malloc;
alias CXTUResourceUsage_SourceManager_Membuffer_MMap = CXTUResourceUsageKind.CXTUResourceUsage_SourceManager_Membuffer_MMap;
alias CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc = CXTUResourceUsageKind.CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc;
alias CXTUResourceUsage_ExternalASTSource_Membuffer_MMap = CXTUResourceUsageKind.CXTUResourceUsage_ExternalASTSource_Membuffer_MMap;
alias CXTUResourceUsage_Preprocessor = CXTUResourceUsageKind.CXTUResourceUsage_Preprocessor;
alias CXTUResourceUsage_PreprocessingRecord = CXTUResourceUsageKind.CXTUResourceUsage_PreprocessingRecord;
alias CXTUResourceUsage_SourceManager_DataStructures = CXTUResourceUsageKind.CXTUResourceUsage_SourceManager_DataStructures;
alias CXTUResourceUsage_Preprocessor_HeaderSearch = CXTUResourceUsageKind.CXTUResourceUsage_Preprocessor_HeaderSearch;
alias CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN = CXTUResourceUsageKind.CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN;
alias CXTUResourceUsage_MEMORY_IN_BYTES_END = CXTUResourceUsageKind.CXTUResourceUsage_MEMORY_IN_BYTES_END;
alias CXTUResourceUsage_First = CXTUResourceUsageKind.CXTUResourceUsage_First;
alias CXTUResourceUsage_Last = CXTUResourceUsageKind.CXTUResourceUsage_Last;

/**
 * Returns the human-readable null-terminated C string that represents
 *  the name of the memory category.  This string should never be freed.
 */
const(char)* clang_getTUResourceUsageName (in CXTUResourceUsageKind kind);

struct CXTUResourceUsageEntry
{
    /* The memory usage category. */
    CXTUResourceUsageKind kind;
    /* Amount of resources used.
        The units will depend on the resource kind. */
    c_ulong amount;
}

/**
 * The memory usage of a CXTranslationUnit, broken into categories.
 */
struct CXTUResourceUsage
{
    /* Private data member, used for queries. */
    void* data;

    /* The number of entries in the 'entries' array. */
    uint numEntries;

    /* An array of key-value pairs, representing the breakdown of memory
              usage. */
    CXTUResourceUsageEntry* entries;
}

/**
 * Return the memory usage of a translation unit.  This object
 *  should be released with clang_disposeCXTUResourceUsage().
 */
CXTUResourceUsage clang_getCXTUResourceUsage (in CXTranslationUnit TU);

void clang_disposeCXTUResourceUsage (in CXTUResourceUsage usage);

/**
 * Get target information for this translation unit.
 *
 * The CXTargetInfo object cannot outlive the CXTranslationUnit object.
 */
CXTargetInfo clang_getTranslationUnitTargetInfo (in CXTranslationUnit CTUnit);

/**
 * Destroy the CXTargetInfo object.
 */
void clang_TargetInfo_dispose (in CXTargetInfo Info);

/**
 * Get the normalized target triple as a string.
 *
 * Returns the empty string in case of any error.
 */
CXString clang_TargetInfo_getTriple (in CXTargetInfo Info);

/**
 * Get the pointer width of the target in bits.
 *
 * Returns -1 in case of error.
 */
int clang_TargetInfo_getPointerWidth (in CXTargetInfo Info);

/**
 * @}
 */

/**
 * Describes the kind of entity that a cursor refers to.
 */
enum CXCursorKind
{
    /* Declarations */
    /**
     * A declaration whose specific kind is not exposed via this
     * interface.
     *
     * Unexposed declarations have the same operations as any other kind
     * of declaration; one can extract their location information,
     * spelling, find their definitions, etc. However, the specific kind
     * of the declaration is not reported.
     */
    CXCursor_UnexposedDecl = 1,
    /** A C or C++ struct. */
    CXCursor_StructDecl = 2,
    /** A C or C++ union. */
    CXCursor_UnionDecl = 3,
    /** A C++ class. */
    CXCursor_ClassDecl = 4,
    /** An enumeration. */
    CXCursor_EnumDecl = 5,
    /**
     * A field (in C) or non-static data member (in C++) in a
     * struct, union, or C++ class.
     */
    CXCursor_FieldDecl = 6,
    /** An enumerator constant. */
    CXCursor_EnumConstantDecl = 7,
    /** A function. */
    CXCursor_FunctionDecl = 8,
    /** A variable. */
    CXCursor_VarDecl = 9,
    /** A function or method parameter. */
    CXCursor_ParmDecl = 10,
    /** An Objective-C \@interface. */
    CXCursor_ObjCInterfaceDecl = 11,
    /** An Objective-C \@interface for a category. */
    CXCursor_ObjCCategoryDecl = 12,
    /** An Objective-C \@protocol declaration. */
    CXCursor_ObjCProtocolDecl = 13,
    /** An Objective-C \@property declaration. */
    CXCursor_ObjCPropertyDecl = 14,
    /** An Objective-C instance variable. */
    CXCursor_ObjCIvarDecl = 15,
    /** An Objective-C instance method. */
    CXCursor_ObjCInstanceMethodDecl = 16,
    /** An Objective-C class method. */
    CXCursor_ObjCClassMethodDecl = 17,
    /** An Objective-C \@implementation. */
    CXCursor_ObjCImplementationDecl = 18,
    /** An Objective-C \@implementation for a category. */
    CXCursor_ObjCCategoryImplDecl = 19,
    /** A typedef. */
    CXCursor_TypedefDecl = 20,
    /** A C++ class method. */
    CXCursor_CXXMethod = 21,
    /** A C++ namespace. */
    CXCursor_Namespace = 22,
    /** A linkage specification, e.g. 'extern "C"'. */
    CXCursor_LinkageSpec = 23,
    /** A C++ constructor. */
    CXCursor_Constructor = 24,
    /** A C++ destructor. */
    CXCursor_Destructor = 25,
    /** A C++ conversion function. */
    CXCursor_ConversionFunction = 26,
    /** A C++ template type parameter. */
    CXCursor_TemplateTypeParameter = 27,
    /** A C++ non-type template parameter. */
    CXCursor_NonTypeTemplateParameter = 28,
    /** A C++ template template parameter. */
    CXCursor_TemplateTemplateParameter = 29,
    /** A C++ function template. */
    CXCursor_FunctionTemplate = 30,
    /** A C++ class template. */
    CXCursor_ClassTemplate = 31,
    /** A C++ class template partial specialization. */
    CXCursor_ClassTemplatePartialSpecialization = 32,
    /** A C++ namespace alias declaration. */
    CXCursor_NamespaceAlias = 33,
    /** A C++ using directive. */
    CXCursor_UsingDirective = 34,
    /** A C++ using declaration. */
    CXCursor_UsingDeclaration = 35,
    /** A C++ alias declaration */
    CXCursor_TypeAliasDecl = 36,
    /** An Objective-C \@synthesize definition. */
    CXCursor_ObjCSynthesizeDecl = 37,
    /** An Objective-C \@dynamic definition. */
    CXCursor_ObjCDynamicDecl = 38,
    /** An access specifier. */
    CXCursor_CXXAccessSpecifier = 39,

    CXCursor_FirstDecl = CXCursor_UnexposedDecl,
    CXCursor_LastDecl = CXCursor_CXXAccessSpecifier,

    /* References */
    CXCursor_FirstRef = 40, /* Decl references */
    CXCursor_ObjCSuperClassRef = 40,
    CXCursor_ObjCProtocolRef = 41,
    CXCursor_ObjCClassRef = 42,
    /**
     * A reference to a type declaration.
     *
     * A type reference occurs anywhere where a type is named but not
     * declared. For example, given:
     *
     * \code
     * typedef unsigned size_type;
     * size_type size;
     * \endcode
     *
     * The typedef is a declaration of size_type (CXCursor_TypedefDecl),
     * while the type of the variable "size" is referenced. The cursor
     * referenced by the type of size is the typedef for size_type.
     */
    CXCursor_TypeRef = 43,
    CXCursor_CXXBaseSpecifier = 44,
    /**
     * A reference to a class template, function template, template
     * template parameter, or class template partial specialization.
     */
    CXCursor_TemplateRef = 45,
    /**
     * A reference to a namespace or namespace alias.
     */
    CXCursor_NamespaceRef = 46,
    /**
     * A reference to a member of a struct, union, or class that occurs in
     * some non-expression context, e.g., a designated initializer.
     */
    CXCursor_MemberRef = 47,
    /**
     * A reference to a labeled statement.
     *
     * This cursor kind is used to describe the jump to "start_over" in the
     * goto statement in the following example:
     *
     * \code
     *   start_over:
     *     ++counter;
     *
     *     goto start_over;
     * \endcode
     *
     * A label reference cursor refers to a label statement.
     */
    CXCursor_LabelRef = 48,

    /**
     * A reference to a set of overloaded functions or function templates
     * that has not yet been resolved to a specific function or function template.
     *
     * An overloaded declaration reference cursor occurs in C++ templates where
     * a dependent name refers to a function. For example:
     *
     * \code
     * template<typename T> void swap(T&, T&);
     *
     * struct X { ... };
     * void swap(X&, X&);
     *
     * template<typename T>
     * void reverse(T* first, T* last) {
     *   while (first < last - 1) {
     *     swap(*first, *--last);
     *     ++first;
     *   }
     * }
     *
     * struct Y { };
     * void swap(Y&, Y&);
     * \endcode
     *
     * Here, the identifier "swap" is associated with an overloaded declaration
     * reference. In the template definition, "swap" refers to either of the two
     * "swap" functions declared above, so both results will be available. At
     * instantiation time, "swap" may also refer to other functions found via
     * argument-dependent lookup (e.g., the "swap" function at the end of the
     * example).
     *
     * The functions \c clang_getNumOverloadedDecls() and
     * \c clang_getOverloadedDecl() can be used to retrieve the definitions
     * referenced by this cursor.
     */
    CXCursor_OverloadedDeclRef = 49,

    /**
     * A reference to a variable that occurs in some non-expression
     * context, e.g., a C++ lambda capture list.
     */
    CXCursor_VariableRef = 50,

    CXCursor_LastRef = CXCursor_VariableRef,

    /* Error conditions */
    CXCursor_FirstInvalid = 70,
    CXCursor_InvalidFile = 70,
    CXCursor_NoDeclFound = 71,
    CXCursor_NotImplemented = 72,
    CXCursor_InvalidCode = 73,
    CXCursor_LastInvalid = CXCursor_InvalidCode,

    /* Expressions */
    CXCursor_FirstExpr = 100,

    /**
     * An expression whose specific kind is not exposed via this
     * interface.
     *
     * Unexposed expressions have the same operations as any other kind
     * of expression; one can extract their location information,
     * spelling, children, etc. However, the specific kind of the
     * expression is not reported.
     */
    CXCursor_UnexposedExpr = 100,

    /**
     * An expression that refers to some value declaration, such
     * as a function, variable, or enumerator.
     */
    CXCursor_DeclRefExpr = 101,

    /**
     * An expression that refers to a member of a struct, union,
     * class, Objective-C class, etc.
     */
    CXCursor_MemberRefExpr = 102,

    /** An expression that calls a function. */
    CXCursor_CallExpr = 103,

    /** An expression that sends a message to an Objective-C
     object or class. */
    CXCursor_ObjCMessageExpr = 104,

    /** An expression that represents a block literal. */
    CXCursor_BlockExpr = 105,

    /** An integer literal.
     */
    CXCursor_IntegerLiteral = 106,

    /** A floating point number literal.
     */
    CXCursor_FloatingLiteral = 107,

    /** An imaginary number literal.
     */
    CXCursor_ImaginaryLiteral = 108,

    /** A string literal.
     */
    CXCursor_StringLiteral = 109,

    /** A character literal.
     */
    CXCursor_CharacterLiteral = 110,

    /** A parenthesized expression, e.g. "(1)".
     *
     * This AST node is only formed if full location information is requested.
     */
    CXCursor_ParenExpr = 111,

    /** This represents the unary-expression's (except sizeof and
     * alignof).
     */
    CXCursor_UnaryOperator = 112,

    /** [C99 6.5.2.1] Array Subscripting.
     */
    CXCursor_ArraySubscriptExpr = 113,

    /** A builtin binary operation expression such as "x + y" or
     * "x <= y".
     */
    CXCursor_BinaryOperator = 114,

    /** Compound assignment such as "+=".
     */
    CXCursor_CompoundAssignOperator = 115,

    /** The ?: ternary operator.
     */
    CXCursor_ConditionalOperator = 116,

    /** An explicit cast in C (C99 6.5.4) or a C-style cast in C++
     * (C++ [expr.cast]), which uses the syntax (Type)expr.
     *
     * For example: (int)f.
     */
    CXCursor_CStyleCastExpr = 117,

    /** [C99 6.5.2.5]
     */
    CXCursor_CompoundLiteralExpr = 118,

    /** Describes an C or C++ initializer list.
     */
    CXCursor_InitListExpr = 119,

    /** The GNU address of label extension, representing &&label.
     */
    CXCursor_AddrLabelExpr = 120,

    /** This is the GNU Statement Expression extension: ({int X=4; X;})
     */
    CXCursor_StmtExpr = 121,

    /** Represents a C11 generic selection.
     */
    CXCursor_GenericSelectionExpr = 122,

    /** Implements the GNU __null extension, which is a name for a null
     * pointer constant that has integral type (e.g., int or long) and is the same
     * size and alignment as a pointer.
     *
     * The __null extension is typically only used by system headers, which define
     * NULL as __null in C++ rather than using 0 (which is an integer that may not
     * match the size of a pointer).
     */
    CXCursor_GNUNullExpr = 123,

    /** C++'s static_cast<> expression.
     */
    CXCursor_CXXStaticCastExpr = 124,

    /** C++'s dynamic_cast<> expression.
     */
    CXCursor_CXXDynamicCastExpr = 125,

    /** C++'s reinterpret_cast<> expression.
     */
    CXCursor_CXXReinterpretCastExpr = 126,

    /** C++'s const_cast<> expression.
     */
    CXCursor_CXXConstCastExpr = 127,

    /** Represents an explicit C++ type conversion that uses "functional"
     * notion (C++ [expr.type.conv]).
     *
     * Example:
     * \code
     *   x = int(0.5);
     * \endcode
     */
    CXCursor_CXXFunctionalCastExpr = 128,

    /** A C++ typeid expression (C++ [expr.typeid]).
     */
    CXCursor_CXXTypeidExpr = 129,

    /** [C++ 2.13.5] C++ Boolean Literal.
     */
    CXCursor_CXXBoolLiteralExpr = 130,

    /** [C++0x 2.14.7] C++ Pointer Literal.
     */
    CXCursor_CXXNullPtrLiteralExpr = 131,

    /** Represents the "this" expression in C++
     */
    CXCursor_CXXThisExpr = 132,

    /** [C++ 15] C++ Throw Expression.
     *
     * This handles 'throw' and 'throw' assignment-expression. When
     * assignment-expression isn't present, Op will be null.
     */
    CXCursor_CXXThrowExpr = 133,

    /** A new expression for memory allocation and constructor calls, e.g:
     * "new CXXNewExpr(foo)".
     */
    CXCursor_CXXNewExpr = 134,

    /** A delete expression for memory deallocation and destructor calls,
     * e.g. "delete[] pArray".
     */
    CXCursor_CXXDeleteExpr = 135,

    /** A unary expression. (noexcept, sizeof, or other traits)
     */
    CXCursor_UnaryExpr = 136,

    /** An Objective-C string literal i.e. @"foo".
     */
    CXCursor_ObjCStringLiteral = 137,

    /** An Objective-C \@encode expression.
     */
    CXCursor_ObjCEncodeExpr = 138,

    /** An Objective-C \@selector expression.
     */
    CXCursor_ObjCSelectorExpr = 139,

    /** An Objective-C \@protocol expression.
     */
    CXCursor_ObjCProtocolExpr = 140,

    /** An Objective-C "bridged" cast expression, which casts between
     * Objective-C pointers and C pointers, transferring ownership in the process.
     *
     * \code
     *   NSString *str = (__bridge_transfer NSString *)CFCreateString();
     * \endcode
     */
    CXCursor_ObjCBridgedCastExpr = 141,

    /** Represents a C++0x pack expansion that produces a sequence of
     * expressions.
     *
     * A pack expansion expression contains a pattern (which itself is an
     * expression) followed by an ellipsis. For example:
     *
     * \code
     * template<typename F, typename ...Types>
     * void forward(F f, Types &&...args) {
     *  f(static_cast<Types&&>(args)...);
     * }
     * \endcode
     */
    CXCursor_PackExpansionExpr = 142,

    /** Represents an expression that computes the length of a parameter
     * pack.
     *
     * \code
     * template<typename ...Types>
     * struct count {
     *   static const unsigned value = sizeof...(Types);
     * };
     * \endcode
     */
    CXCursor_SizeOfPackExpr = 143,

    /* Represents a C++ lambda expression that produces a local function
     * object.
     *
     * \code
     * void abssort(float *x, unsigned N) {
     *   std::sort(x, x + N,
     *             [](float a, float b) {
     *               return std::abs(a) < std::abs(b);
     *             });
     * }
     * \endcode
     */
    CXCursor_LambdaExpr = 144,

    /** Objective-c Boolean Literal.
     */
    CXCursor_ObjCBoolLiteralExpr = 145,

    /** Represents the "self" expression in an Objective-C method.
     */
    CXCursor_ObjCSelfExpr = 146,

    /** OpenMP 5.0 [2.1.5, Array Section].
     */
    CXCursor_OMPArraySectionExpr = 147,

    /** Represents an @available(...) check.
     */
    CXCursor_ObjCAvailabilityCheckExpr = 148,

    /**
     * Fixed point literal
     */
    CXCursor_FixedPointLiteral = 149,

    /** OpenMP 5.0 [2.1.4, Array Shaping].
     */
    CXCursor_OMPArrayShapingExpr = 150,

    /**
     * OpenMP 5.0 [2.1.6 Iterators]
     */
    CXCursor_OMPIteratorExpr = 151,

    /** OpenCL's addrspace_cast<> expression.
     */
    CXCursor_CXXAddrspaceCastExpr = 152,

    /**
     * Expression that references a C++20 concept.
     */
    CXCursor_ConceptSpecializationExpr = 153,

    /**
     * Expression that references a C++20 concept.
     */
    CXCursor_RequiresExpr = 154,

    CXCursor_LastExpr = CXCursor_RequiresExpr,

    /* Statements */
    CXCursor_FirstStmt = 200,
    /**
     * A statement whose specific kind is not exposed via this
     * interface.
     *
     * Unexposed statements have the same operations as any other kind of
     * statement; one can extract their location information, spelling,
     * children, etc. However, the specific kind of the statement is not
     * reported.
     */
    CXCursor_UnexposedStmt = 200,

    /** A labelled statement in a function.
     *
     * This cursor kind is used to describe the "start_over:" label statement in
     * the following example:
     *
     * \code
     *   start_over:
     *     ++counter;
     * \endcode
     *
     */
    CXCursor_LabelStmt = 201,

    /** A group of statements like { stmt stmt }.
     *
     * This cursor kind is used to describe compound statements, e.g. function
     * bodies.
     */
    CXCursor_CompoundStmt = 202,

    /** A case statement.
     */
    CXCursor_CaseStmt = 203,

    /** A default statement.
     */
    CXCursor_DefaultStmt = 204,

    /** An if statement
     */
    CXCursor_IfStmt = 205,

    /** A switch statement.
     */
    CXCursor_SwitchStmt = 206,

    /** A while statement.
     */
    CXCursor_WhileStmt = 207,

    /** A do statement.
     */
    CXCursor_DoStmt = 208,

    /** A for statement.
     */
    CXCursor_ForStmt = 209,

    /** A goto statement.
     */
    CXCursor_GotoStmt = 210,

    /** An indirect goto statement.
     */
    CXCursor_IndirectGotoStmt = 211,

    /** A continue statement.
     */
    CXCursor_ContinueStmt = 212,

    /** A break statement.
     */
    CXCursor_BreakStmt = 213,

    /** A return statement.
     */
    CXCursor_ReturnStmt = 214,

    /** A GCC inline assembly statement extension.
     */
    CXCursor_GCCAsmStmt = 215,
    CXCursor_AsmStmt = CXCursor_GCCAsmStmt,

    /** Objective-C's overall \@try-\@catch-\@finally statement.
     */
    CXCursor_ObjCAtTryStmt = 216,

    /** Objective-C's \@catch statement.
     */
    CXCursor_ObjCAtCatchStmt = 217,

    /** Objective-C's \@finally statement.
     */
    CXCursor_ObjCAtFinallyStmt = 218,

    /** Objective-C's \@throw statement.
     */
    CXCursor_ObjCAtThrowStmt = 219,

    /** Objective-C's \@synchronized statement.
     */
    CXCursor_ObjCAtSynchronizedStmt = 220,

    /** Objective-C's autorelease pool statement.
     */
    CXCursor_ObjCAutoreleasePoolStmt = 221,

    /** Objective-C's collection statement.
     */
    CXCursor_ObjCForCollectionStmt = 222,

    /** C++'s catch statement.
     */
    CXCursor_CXXCatchStmt = 223,

    /** C++'s try statement.
     */
    CXCursor_CXXTryStmt = 224,

    /** C++'s for (* : *) statement.
     */
    CXCursor_CXXForRangeStmt = 225,

    /** Windows Structured Exception Handling's try statement.
     */
    CXCursor_SEHTryStmt = 226,

    /** Windows Structured Exception Handling's except statement.
     */
    CXCursor_SEHExceptStmt = 227,

    /** Windows Structured Exception Handling's finally statement.
     */
    CXCursor_SEHFinallyStmt = 228,

    /** A MS inline assembly statement extension.
     */
    CXCursor_MSAsmStmt = 229,

    /** The null statement ";": C99 6.8.3p3.
     *
     * This cursor kind is used to describe the null statement.
     */
    CXCursor_NullStmt = 230,

    /** Adaptor class for mixing declarations with statements and
     * expressions.
     */
    CXCursor_DeclStmt = 231,

    /** OpenMP parallel directive.
     */
    CXCursor_OMPParallelDirective = 232,

    /** OpenMP SIMD directive.
     */
    CXCursor_OMPSimdDirective = 233,

    /** OpenMP for directive.
     */
    CXCursor_OMPForDirective = 234,

    /** OpenMP sections directive.
     */
    CXCursor_OMPSectionsDirective = 235,

    /** OpenMP section directive.
     */
    CXCursor_OMPSectionDirective = 236,

    /** OpenMP single directive.
     */
    CXCursor_OMPSingleDirective = 237,

    /** OpenMP parallel for directive.
     */
    CXCursor_OMPParallelForDirective = 238,

    /** OpenMP parallel sections directive.
     */
    CXCursor_OMPParallelSectionsDirective = 239,

    /** OpenMP task directive.
     */
    CXCursor_OMPTaskDirective = 240,

    /** OpenMP master directive.
     */
    CXCursor_OMPMasterDirective = 241,

    /** OpenMP critical directive.
     */
    CXCursor_OMPCriticalDirective = 242,

    /** OpenMP taskyield directive.
     */
    CXCursor_OMPTaskyieldDirective = 243,

    /** OpenMP barrier directive.
     */
    CXCursor_OMPBarrierDirective = 244,

    /** OpenMP taskwait directive.
     */
    CXCursor_OMPTaskwaitDirective = 245,

    /** OpenMP flush directive.
     */
    CXCursor_OMPFlushDirective = 246,

    /** Windows Structured Exception Handling's leave statement.
     */
    CXCursor_SEHLeaveStmt = 247,

    /** OpenMP ordered directive.
     */
    CXCursor_OMPOrderedDirective = 248,

    /** OpenMP atomic directive.
     */
    CXCursor_OMPAtomicDirective = 249,

    /** OpenMP for SIMD directive.
     */
    CXCursor_OMPForSimdDirective = 250,

    /** OpenMP parallel for SIMD directive.
     */
    CXCursor_OMPParallelForSimdDirective = 251,

    /** OpenMP target directive.
     */
    CXCursor_OMPTargetDirective = 252,

    /** OpenMP teams directive.
     */
    CXCursor_OMPTeamsDirective = 253,

    /** OpenMP taskgroup directive.
     */
    CXCursor_OMPTaskgroupDirective = 254,

    /** OpenMP cancellation point directive.
     */
    CXCursor_OMPCancellationPointDirective = 255,

    /** OpenMP cancel directive.
     */
    CXCursor_OMPCancelDirective = 256,

    /** OpenMP target data directive.
     */
    CXCursor_OMPTargetDataDirective = 257,

    /** OpenMP taskloop directive.
     */
    CXCursor_OMPTaskLoopDirective = 258,

    /** OpenMP taskloop simd directive.
     */
    CXCursor_OMPTaskLoopSimdDirective = 259,

    /** OpenMP distribute directive.
     */
    CXCursor_OMPDistributeDirective = 260,

    /** OpenMP target enter data directive.
     */
    CXCursor_OMPTargetEnterDataDirective = 261,

    /** OpenMP target exit data directive.
     */
    CXCursor_OMPTargetExitDataDirective = 262,

    /** OpenMP target parallel directive.
     */
    CXCursor_OMPTargetParallelDirective = 263,

    /** OpenMP target parallel for directive.
     */
    CXCursor_OMPTargetParallelForDirective = 264,

    /** OpenMP target update directive.
     */
    CXCursor_OMPTargetUpdateDirective = 265,

    /** OpenMP distribute parallel for directive.
     */
    CXCursor_OMPDistributeParallelForDirective = 266,

    /** OpenMP distribute parallel for simd directive.
     */
    CXCursor_OMPDistributeParallelForSimdDirective = 267,

    /** OpenMP distribute simd directive.
     */
    CXCursor_OMPDistributeSimdDirective = 268,

    /** OpenMP target parallel for simd directive.
     */
    CXCursor_OMPTargetParallelForSimdDirective = 269,

    /** OpenMP target simd directive.
     */
    CXCursor_OMPTargetSimdDirective = 270,

    /** OpenMP teams distribute directive.
     */
    CXCursor_OMPTeamsDistributeDirective = 271,

    /** OpenMP teams distribute simd directive.
     */
    CXCursor_OMPTeamsDistributeSimdDirective = 272,

    /** OpenMP teams distribute parallel for simd directive.
     */
    CXCursor_OMPTeamsDistributeParallelForSimdDirective = 273,

    /** OpenMP teams distribute parallel for directive.
     */
    CXCursor_OMPTeamsDistributeParallelForDirective = 274,

    /** OpenMP target teams directive.
     */
    CXCursor_OMPTargetTeamsDirective = 275,

    /** OpenMP target teams distribute directive.
     */
    CXCursor_OMPTargetTeamsDistributeDirective = 276,

    /** OpenMP target teams distribute parallel for directive.
     */
    CXCursor_OMPTargetTeamsDistributeParallelForDirective = 277,

    /** OpenMP target teams distribute parallel for simd directive.
     */
    CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = 278,

    /** OpenMP target teams distribute simd directive.
     */
    CXCursor_OMPTargetTeamsDistributeSimdDirective = 279,

    /** C++2a std::bit_cast expression.
     */
    CXCursor_BuiltinBitCastExpr = 280,

    /** OpenMP master taskloop directive.
     */
    CXCursor_OMPMasterTaskLoopDirective = 281,

    /** OpenMP parallel master taskloop directive.
     */
    CXCursor_OMPParallelMasterTaskLoopDirective = 282,

    /** OpenMP master taskloop simd directive.
     */
    CXCursor_OMPMasterTaskLoopSimdDirective = 283,

    /** OpenMP parallel master taskloop simd directive.
     */
    CXCursor_OMPParallelMasterTaskLoopSimdDirective = 284,

    /** OpenMP parallel master directive.
     */
    CXCursor_OMPParallelMasterDirective = 285,

    /** OpenMP depobj directive.
     */
    CXCursor_OMPDepobjDirective = 286,

    /** OpenMP scan directive.
     */
    CXCursor_OMPScanDirective = 287,

    /** OpenMP tile directive.
     */
    CXCursor_OMPTileDirective = 288,

    /** OpenMP canonical loop.
     */
    CXCursor_OMPCanonicalLoop = 289,

    /** OpenMP interop directive.
     */
    CXCursor_OMPInteropDirective = 290,

    /** OpenMP dispatch directive.
     */
    CXCursor_OMPDispatchDirective = 291,

    /** OpenMP masked directive.
     */
    CXCursor_OMPMaskedDirective = 292,

    /** OpenMP unroll directive.
     */
    CXCursor_OMPUnrollDirective = 293,

    /** OpenMP metadirective directive.
     */
    CXCursor_OMPMetaDirective = 294,

    /** OpenMP loop directive.
     */
    CXCursor_OMPGenericLoopDirective = 295,

    /** OpenMP teams loop directive.
     */
    CXCursor_OMPTeamsGenericLoopDirective = 296,

    /** OpenMP target teams loop directive.
     */
    CXCursor_OMPTargetTeamsGenericLoopDirective = 297,

    /** OpenMP parallel loop directive.
     */
    CXCursor_OMPParallelGenericLoopDirective = 298,

    /** OpenMP target parallel loop directive.
     */
    CXCursor_OMPTargetParallelGenericLoopDirective = 299,

    /** OpenMP parallel masked directive.
     */
    CXCursor_OMPParallelMaskedDirective = 300,

    /** OpenMP masked taskloop directive.
     */
    CXCursor_OMPMaskedTaskLoopDirective = 301,

    /** OpenMP masked taskloop simd directive.
     */
    CXCursor_OMPMaskedTaskLoopSimdDirective = 302,

    /** OpenMP parallel masked taskloop directive.
     */
    CXCursor_OMPParallelMaskedTaskLoopDirective = 303,

    /** OpenMP parallel masked taskloop simd directive.
     */
    CXCursor_OMPParallelMaskedTaskLoopSimdDirective = 304,

    CXCursor_LastStmt = CXCursor_OMPParallelMaskedTaskLoopSimdDirective,

    /**
     * Cursor that represents the translation unit itself.
     *
     * The translation unit cursor exists primarily to act as the root
     * cursor for traversing the contents of a translation unit.
     */
    CXCursor_TranslationUnit = 350,

    /* Attributes */
    CXCursor_FirstAttr = 400,
    /**
     * An attribute whose specific kind is not exposed via this
     * interface.
     */
    CXCursor_UnexposedAttr = 400,

    CXCursor_IBActionAttr = 401,
    CXCursor_IBOutletAttr = 402,
    CXCursor_IBOutletCollectionAttr = 403,
    CXCursor_CXXFinalAttr = 404,
    CXCursor_CXXOverrideAttr = 405,
    CXCursor_AnnotateAttr = 406,
    CXCursor_AsmLabelAttr = 407,
    CXCursor_PackedAttr = 408,
    CXCursor_PureAttr = 409,
    CXCursor_ConstAttr = 410,
    CXCursor_NoDuplicateAttr = 411,
    CXCursor_CUDAConstantAttr = 412,
    CXCursor_CUDADeviceAttr = 413,
    CXCursor_CUDAGlobalAttr = 414,
    CXCursor_CUDAHostAttr = 415,
    CXCursor_CUDASharedAttr = 416,
    CXCursor_VisibilityAttr = 417,
    CXCursor_DLLExport = 418,
    CXCursor_DLLImport = 419,
    CXCursor_NSReturnsRetained = 420,
    CXCursor_NSReturnsNotRetained = 421,
    CXCursor_NSReturnsAutoreleased = 422,
    CXCursor_NSConsumesSelf = 423,
    CXCursor_NSConsumed = 424,
    CXCursor_ObjCException = 425,
    CXCursor_ObjCNSObject = 426,
    CXCursor_ObjCIndependentClass = 427,
    CXCursor_ObjCPreciseLifetime = 428,
    CXCursor_ObjCReturnsInnerPointer = 429,
    CXCursor_ObjCRequiresSuper = 430,
    CXCursor_ObjCRootClass = 431,
    CXCursor_ObjCSubclassingRestricted = 432,
    CXCursor_ObjCExplicitProtocolImpl = 433,
    CXCursor_ObjCDesignatedInitializer = 434,
    CXCursor_ObjCRuntimeVisible = 435,
    CXCursor_ObjCBoxable = 436,
    CXCursor_FlagEnum = 437,
    CXCursor_ConvergentAttr = 438,
    CXCursor_WarnUnusedAttr = 439,
    CXCursor_WarnUnusedResultAttr = 440,
    CXCursor_AlignedAttr = 441,
    CXCursor_LastAttr = CXCursor_AlignedAttr,

    /* Preprocessing */
    CXCursor_PreprocessingDirective = 500,
    CXCursor_MacroDefinition = 501,
    CXCursor_MacroExpansion = 502,
    CXCursor_MacroInstantiation = CXCursor_MacroExpansion,
    CXCursor_InclusionDirective = 503,
    CXCursor_FirstPreprocessing = CXCursor_PreprocessingDirective,
    CXCursor_LastPreprocessing = CXCursor_InclusionDirective,

    /* Extra Declarations */
    /**
     * A module import declaration.
     */
    CXCursor_ModuleImportDecl = 600,
    CXCursor_TypeAliasTemplateDecl = 601,
    /**
     * A static_assert or _Static_assert node
     */
    CXCursor_StaticAssert = 602,
    /**
     * a friend declaration.
     */
    CXCursor_FriendDecl = 603,
    /**
     * a concept declaration.
     */
    CXCursor_ConceptDecl = 604,

    CXCursor_FirstExtraDecl = CXCursor_ModuleImportDecl,
    CXCursor_LastExtraDecl = CXCursor_ConceptDecl,

    /**
     * A code completion overload candidate.
     */
    CXCursor_OverloadCandidate = 700
}

alias CXCursor_UnexposedDecl = CXCursorKind.CXCursor_UnexposedDecl;
alias CXCursor_StructDecl = CXCursorKind.CXCursor_StructDecl;
alias CXCursor_UnionDecl = CXCursorKind.CXCursor_UnionDecl;
alias CXCursor_ClassDecl = CXCursorKind.CXCursor_ClassDecl;
alias CXCursor_EnumDecl = CXCursorKind.CXCursor_EnumDecl;
alias CXCursor_FieldDecl = CXCursorKind.CXCursor_FieldDecl;
alias CXCursor_EnumConstantDecl = CXCursorKind.CXCursor_EnumConstantDecl;
alias CXCursor_FunctionDecl = CXCursorKind.CXCursor_FunctionDecl;
alias CXCursor_VarDecl = CXCursorKind.CXCursor_VarDecl;
alias CXCursor_ParmDecl = CXCursorKind.CXCursor_ParmDecl;
alias CXCursor_ObjCInterfaceDecl = CXCursorKind.CXCursor_ObjCInterfaceDecl;
alias CXCursor_ObjCCategoryDecl = CXCursorKind.CXCursor_ObjCCategoryDecl;
alias CXCursor_ObjCProtocolDecl = CXCursorKind.CXCursor_ObjCProtocolDecl;
alias CXCursor_ObjCPropertyDecl = CXCursorKind.CXCursor_ObjCPropertyDecl;
alias CXCursor_ObjCIvarDecl = CXCursorKind.CXCursor_ObjCIvarDecl;
alias CXCursor_ObjCInstanceMethodDecl = CXCursorKind.CXCursor_ObjCInstanceMethodDecl;
alias CXCursor_ObjCClassMethodDecl = CXCursorKind.CXCursor_ObjCClassMethodDecl;
alias CXCursor_ObjCImplementationDecl = CXCursorKind.CXCursor_ObjCImplementationDecl;
alias CXCursor_ObjCCategoryImplDecl = CXCursorKind.CXCursor_ObjCCategoryImplDecl;
alias CXCursor_TypedefDecl = CXCursorKind.CXCursor_TypedefDecl;
alias CXCursor_CXXMethod = CXCursorKind.CXCursor_CXXMethod;
alias CXCursor_Namespace = CXCursorKind.CXCursor_Namespace;
alias CXCursor_LinkageSpec = CXCursorKind.CXCursor_LinkageSpec;
alias CXCursor_Constructor = CXCursorKind.CXCursor_Constructor;
alias CXCursor_Destructor = CXCursorKind.CXCursor_Destructor;
alias CXCursor_ConversionFunction = CXCursorKind.CXCursor_ConversionFunction;
alias CXCursor_TemplateTypeParameter = CXCursorKind.CXCursor_TemplateTypeParameter;
alias CXCursor_NonTypeTemplateParameter = CXCursorKind.CXCursor_NonTypeTemplateParameter;
alias CXCursor_TemplateTemplateParameter = CXCursorKind.CXCursor_TemplateTemplateParameter;
alias CXCursor_FunctionTemplate = CXCursorKind.CXCursor_FunctionTemplate;
alias CXCursor_ClassTemplate = CXCursorKind.CXCursor_ClassTemplate;
alias CXCursor_ClassTemplatePartialSpecialization = CXCursorKind.CXCursor_ClassTemplatePartialSpecialization;
alias CXCursor_NamespaceAlias = CXCursorKind.CXCursor_NamespaceAlias;
alias CXCursor_UsingDirective = CXCursorKind.CXCursor_UsingDirective;
alias CXCursor_UsingDeclaration = CXCursorKind.CXCursor_UsingDeclaration;
alias CXCursor_TypeAliasDecl = CXCursorKind.CXCursor_TypeAliasDecl;
alias CXCursor_ObjCSynthesizeDecl = CXCursorKind.CXCursor_ObjCSynthesizeDecl;
alias CXCursor_ObjCDynamicDecl = CXCursorKind.CXCursor_ObjCDynamicDecl;
alias CXCursor_CXXAccessSpecifier = CXCursorKind.CXCursor_CXXAccessSpecifier;
alias CXCursor_FirstDecl = CXCursorKind.CXCursor_FirstDecl;
alias CXCursor_LastDecl = CXCursorKind.CXCursor_LastDecl;
alias CXCursor_FirstRef = CXCursorKind.CXCursor_FirstRef;
alias CXCursor_ObjCSuperClassRef = CXCursorKind.CXCursor_ObjCSuperClassRef;
alias CXCursor_ObjCProtocolRef = CXCursorKind.CXCursor_ObjCProtocolRef;
alias CXCursor_ObjCClassRef = CXCursorKind.CXCursor_ObjCClassRef;
alias CXCursor_TypeRef = CXCursorKind.CXCursor_TypeRef;
alias CXCursor_CXXBaseSpecifier = CXCursorKind.CXCursor_CXXBaseSpecifier;
alias CXCursor_TemplateRef = CXCursorKind.CXCursor_TemplateRef;
alias CXCursor_NamespaceRef = CXCursorKind.CXCursor_NamespaceRef;
alias CXCursor_MemberRef = CXCursorKind.CXCursor_MemberRef;
alias CXCursor_LabelRef = CXCursorKind.CXCursor_LabelRef;
alias CXCursor_OverloadedDeclRef = CXCursorKind.CXCursor_OverloadedDeclRef;
alias CXCursor_VariableRef = CXCursorKind.CXCursor_VariableRef;
alias CXCursor_LastRef = CXCursorKind.CXCursor_LastRef;
alias CXCursor_FirstInvalid = CXCursorKind.CXCursor_FirstInvalid;
alias CXCursor_InvalidFile = CXCursorKind.CXCursor_InvalidFile;
alias CXCursor_NoDeclFound = CXCursorKind.CXCursor_NoDeclFound;
alias CXCursor_NotImplemented = CXCursorKind.CXCursor_NotImplemented;
alias CXCursor_InvalidCode = CXCursorKind.CXCursor_InvalidCode;
alias CXCursor_LastInvalid = CXCursorKind.CXCursor_LastInvalid;
alias CXCursor_FirstExpr = CXCursorKind.CXCursor_FirstExpr;
alias CXCursor_UnexposedExpr = CXCursorKind.CXCursor_UnexposedExpr;
alias CXCursor_DeclRefExpr = CXCursorKind.CXCursor_DeclRefExpr;
alias CXCursor_MemberRefExpr = CXCursorKind.CXCursor_MemberRefExpr;
alias CXCursor_CallExpr = CXCursorKind.CXCursor_CallExpr;
alias CXCursor_ObjCMessageExpr = CXCursorKind.CXCursor_ObjCMessageExpr;
alias CXCursor_BlockExpr = CXCursorKind.CXCursor_BlockExpr;
alias CXCursor_IntegerLiteral = CXCursorKind.CXCursor_IntegerLiteral;
alias CXCursor_FloatingLiteral = CXCursorKind.CXCursor_FloatingLiteral;
alias CXCursor_ImaginaryLiteral = CXCursorKind.CXCursor_ImaginaryLiteral;
alias CXCursor_StringLiteral = CXCursorKind.CXCursor_StringLiteral;
alias CXCursor_CharacterLiteral = CXCursorKind.CXCursor_CharacterLiteral;
alias CXCursor_ParenExpr = CXCursorKind.CXCursor_ParenExpr;
alias CXCursor_UnaryOperator = CXCursorKind.CXCursor_UnaryOperator;
alias CXCursor_ArraySubscriptExpr = CXCursorKind.CXCursor_ArraySubscriptExpr;
alias CXCursor_BinaryOperator = CXCursorKind.CXCursor_BinaryOperator;
alias CXCursor_CompoundAssignOperator = CXCursorKind.CXCursor_CompoundAssignOperator;
alias CXCursor_ConditionalOperator = CXCursorKind.CXCursor_ConditionalOperator;
alias CXCursor_CStyleCastExpr = CXCursorKind.CXCursor_CStyleCastExpr;
alias CXCursor_CompoundLiteralExpr = CXCursorKind.CXCursor_CompoundLiteralExpr;
alias CXCursor_InitListExpr = CXCursorKind.CXCursor_InitListExpr;
alias CXCursor_AddrLabelExpr = CXCursorKind.CXCursor_AddrLabelExpr;
alias CXCursor_StmtExpr = CXCursorKind.CXCursor_StmtExpr;
alias CXCursor_GenericSelectionExpr = CXCursorKind.CXCursor_GenericSelectionExpr;
alias CXCursor_GNUNullExpr = CXCursorKind.CXCursor_GNUNullExpr;
alias CXCursor_CXXStaticCastExpr = CXCursorKind.CXCursor_CXXStaticCastExpr;
alias CXCursor_CXXDynamicCastExpr = CXCursorKind.CXCursor_CXXDynamicCastExpr;
alias CXCursor_CXXReinterpretCastExpr = CXCursorKind.CXCursor_CXXReinterpretCastExpr;
alias CXCursor_CXXConstCastExpr = CXCursorKind.CXCursor_CXXConstCastExpr;
alias CXCursor_CXXFunctionalCastExpr = CXCursorKind.CXCursor_CXXFunctionalCastExpr;
alias CXCursor_CXXTypeidExpr = CXCursorKind.CXCursor_CXXTypeidExpr;
alias CXCursor_CXXBoolLiteralExpr = CXCursorKind.CXCursor_CXXBoolLiteralExpr;
alias CXCursor_CXXNullPtrLiteralExpr = CXCursorKind.CXCursor_CXXNullPtrLiteralExpr;
alias CXCursor_CXXThisExpr = CXCursorKind.CXCursor_CXXThisExpr;
alias CXCursor_CXXThrowExpr = CXCursorKind.CXCursor_CXXThrowExpr;
alias CXCursor_CXXNewExpr = CXCursorKind.CXCursor_CXXNewExpr;
alias CXCursor_CXXDeleteExpr = CXCursorKind.CXCursor_CXXDeleteExpr;
alias CXCursor_UnaryExpr = CXCursorKind.CXCursor_UnaryExpr;
alias CXCursor_ObjCStringLiteral = CXCursorKind.CXCursor_ObjCStringLiteral;
alias CXCursor_ObjCEncodeExpr = CXCursorKind.CXCursor_ObjCEncodeExpr;
alias CXCursor_ObjCSelectorExpr = CXCursorKind.CXCursor_ObjCSelectorExpr;
alias CXCursor_ObjCProtocolExpr = CXCursorKind.CXCursor_ObjCProtocolExpr;
alias CXCursor_ObjCBridgedCastExpr = CXCursorKind.CXCursor_ObjCBridgedCastExpr;
alias CXCursor_PackExpansionExpr = CXCursorKind.CXCursor_PackExpansionExpr;
alias CXCursor_SizeOfPackExpr = CXCursorKind.CXCursor_SizeOfPackExpr;
alias CXCursor_LambdaExpr = CXCursorKind.CXCursor_LambdaExpr;
alias CXCursor_ObjCBoolLiteralExpr = CXCursorKind.CXCursor_ObjCBoolLiteralExpr;
alias CXCursor_ObjCSelfExpr = CXCursorKind.CXCursor_ObjCSelfExpr;
alias CXCursor_OMPArraySectionExpr = CXCursorKind.CXCursor_OMPArraySectionExpr;
alias CXCursor_ObjCAvailabilityCheckExpr = CXCursorKind.CXCursor_ObjCAvailabilityCheckExpr;
alias CXCursor_FixedPointLiteral = CXCursorKind.CXCursor_FixedPointLiteral;
alias CXCursor_OMPArrayShapingExpr = CXCursorKind.CXCursor_OMPArrayShapingExpr;
alias CXCursor_OMPIteratorExpr = CXCursorKind.CXCursor_OMPIteratorExpr;
alias CXCursor_CXXAddrspaceCastExpr = CXCursorKind.CXCursor_CXXAddrspaceCastExpr;
alias CXCursor_ConceptSpecializationExpr = CXCursorKind.CXCursor_ConceptSpecializationExpr;
alias CXCursor_RequiresExpr = CXCursorKind.CXCursor_RequiresExpr;
alias CXCursor_LastExpr = CXCursorKind.CXCursor_LastExpr;
alias CXCursor_FirstStmt = CXCursorKind.CXCursor_FirstStmt;
alias CXCursor_UnexposedStmt = CXCursorKind.CXCursor_UnexposedStmt;
alias CXCursor_LabelStmt = CXCursorKind.CXCursor_LabelStmt;
alias CXCursor_CompoundStmt = CXCursorKind.CXCursor_CompoundStmt;
alias CXCursor_CaseStmt = CXCursorKind.CXCursor_CaseStmt;
alias CXCursor_DefaultStmt = CXCursorKind.CXCursor_DefaultStmt;
alias CXCursor_IfStmt = CXCursorKind.CXCursor_IfStmt;
alias CXCursor_SwitchStmt = CXCursorKind.CXCursor_SwitchStmt;
alias CXCursor_WhileStmt = CXCursorKind.CXCursor_WhileStmt;
alias CXCursor_DoStmt = CXCursorKind.CXCursor_DoStmt;
alias CXCursor_ForStmt = CXCursorKind.CXCursor_ForStmt;
alias CXCursor_GotoStmt = CXCursorKind.CXCursor_GotoStmt;
alias CXCursor_IndirectGotoStmt = CXCursorKind.CXCursor_IndirectGotoStmt;
alias CXCursor_ContinueStmt = CXCursorKind.CXCursor_ContinueStmt;
alias CXCursor_BreakStmt = CXCursorKind.CXCursor_BreakStmt;
alias CXCursor_ReturnStmt = CXCursorKind.CXCursor_ReturnStmt;
alias CXCursor_GCCAsmStmt = CXCursorKind.CXCursor_GCCAsmStmt;
alias CXCursor_AsmStmt = CXCursorKind.CXCursor_AsmStmt;
alias CXCursor_ObjCAtTryStmt = CXCursorKind.CXCursor_ObjCAtTryStmt;
alias CXCursor_ObjCAtCatchStmt = CXCursorKind.CXCursor_ObjCAtCatchStmt;
alias CXCursor_ObjCAtFinallyStmt = CXCursorKind.CXCursor_ObjCAtFinallyStmt;
alias CXCursor_ObjCAtThrowStmt = CXCursorKind.CXCursor_ObjCAtThrowStmt;
alias CXCursor_ObjCAtSynchronizedStmt = CXCursorKind.CXCursor_ObjCAtSynchronizedStmt;
alias CXCursor_ObjCAutoreleasePoolStmt = CXCursorKind.CXCursor_ObjCAutoreleasePoolStmt;
alias CXCursor_ObjCForCollectionStmt = CXCursorKind.CXCursor_ObjCForCollectionStmt;
alias CXCursor_CXXCatchStmt = CXCursorKind.CXCursor_CXXCatchStmt;
alias CXCursor_CXXTryStmt = CXCursorKind.CXCursor_CXXTryStmt;
alias CXCursor_CXXForRangeStmt = CXCursorKind.CXCursor_CXXForRangeStmt;
alias CXCursor_SEHTryStmt = CXCursorKind.CXCursor_SEHTryStmt;
alias CXCursor_SEHExceptStmt = CXCursorKind.CXCursor_SEHExceptStmt;
alias CXCursor_SEHFinallyStmt = CXCursorKind.CXCursor_SEHFinallyStmt;
alias CXCursor_MSAsmStmt = CXCursorKind.CXCursor_MSAsmStmt;
alias CXCursor_NullStmt = CXCursorKind.CXCursor_NullStmt;
alias CXCursor_DeclStmt = CXCursorKind.CXCursor_DeclStmt;
alias CXCursor_OMPParallelDirective = CXCursorKind.CXCursor_OMPParallelDirective;
alias CXCursor_OMPSimdDirective = CXCursorKind.CXCursor_OMPSimdDirective;
alias CXCursor_OMPForDirective = CXCursorKind.CXCursor_OMPForDirective;
alias CXCursor_OMPSectionsDirective = CXCursorKind.CXCursor_OMPSectionsDirective;
alias CXCursor_OMPSectionDirective = CXCursorKind.CXCursor_OMPSectionDirective;
alias CXCursor_OMPSingleDirective = CXCursorKind.CXCursor_OMPSingleDirective;
alias CXCursor_OMPParallelForDirective = CXCursorKind.CXCursor_OMPParallelForDirective;
alias CXCursor_OMPParallelSectionsDirective = CXCursorKind.CXCursor_OMPParallelSectionsDirective;
alias CXCursor_OMPTaskDirective = CXCursorKind.CXCursor_OMPTaskDirective;
alias CXCursor_OMPMasterDirective = CXCursorKind.CXCursor_OMPMasterDirective;
alias CXCursor_OMPCriticalDirective = CXCursorKind.CXCursor_OMPCriticalDirective;
alias CXCursor_OMPTaskyieldDirective = CXCursorKind.CXCursor_OMPTaskyieldDirective;
alias CXCursor_OMPBarrierDirective = CXCursorKind.CXCursor_OMPBarrierDirective;
alias CXCursor_OMPTaskwaitDirective = CXCursorKind.CXCursor_OMPTaskwaitDirective;
alias CXCursor_OMPFlushDirective = CXCursorKind.CXCursor_OMPFlushDirective;
alias CXCursor_SEHLeaveStmt = CXCursorKind.CXCursor_SEHLeaveStmt;
alias CXCursor_OMPOrderedDirective = CXCursorKind.CXCursor_OMPOrderedDirective;
alias CXCursor_OMPAtomicDirective = CXCursorKind.CXCursor_OMPAtomicDirective;
alias CXCursor_OMPForSimdDirective = CXCursorKind.CXCursor_OMPForSimdDirective;
alias CXCursor_OMPParallelForSimdDirective = CXCursorKind.CXCursor_OMPParallelForSimdDirective;
alias CXCursor_OMPTargetDirective = CXCursorKind.CXCursor_OMPTargetDirective;
alias CXCursor_OMPTeamsDirective = CXCursorKind.CXCursor_OMPTeamsDirective;
alias CXCursor_OMPTaskgroupDirective = CXCursorKind.CXCursor_OMPTaskgroupDirective;
alias CXCursor_OMPCancellationPointDirective = CXCursorKind.CXCursor_OMPCancellationPointDirective;
alias CXCursor_OMPCancelDirective = CXCursorKind.CXCursor_OMPCancelDirective;
alias CXCursor_OMPTargetDataDirective = CXCursorKind.CXCursor_OMPTargetDataDirective;
alias CXCursor_OMPTaskLoopDirective = CXCursorKind.CXCursor_OMPTaskLoopDirective;
alias CXCursor_OMPTaskLoopSimdDirective = CXCursorKind.CXCursor_OMPTaskLoopSimdDirective;
alias CXCursor_OMPDistributeDirective = CXCursorKind.CXCursor_OMPDistributeDirective;
alias CXCursor_OMPTargetEnterDataDirective = CXCursorKind.CXCursor_OMPTargetEnterDataDirective;
alias CXCursor_OMPTargetExitDataDirective = CXCursorKind.CXCursor_OMPTargetExitDataDirective;
alias CXCursor_OMPTargetParallelDirective = CXCursorKind.CXCursor_OMPTargetParallelDirective;
alias CXCursor_OMPTargetParallelForDirective = CXCursorKind.CXCursor_OMPTargetParallelForDirective;
alias CXCursor_OMPTargetUpdateDirective = CXCursorKind.CXCursor_OMPTargetUpdateDirective;
alias CXCursor_OMPDistributeParallelForDirective = CXCursorKind.CXCursor_OMPDistributeParallelForDirective;
alias CXCursor_OMPDistributeParallelForSimdDirective = CXCursorKind.CXCursor_OMPDistributeParallelForSimdDirective;
alias CXCursor_OMPDistributeSimdDirective = CXCursorKind.CXCursor_OMPDistributeSimdDirective;
alias CXCursor_OMPTargetParallelForSimdDirective = CXCursorKind.CXCursor_OMPTargetParallelForSimdDirective;
alias CXCursor_OMPTargetSimdDirective = CXCursorKind.CXCursor_OMPTargetSimdDirective;
alias CXCursor_OMPTeamsDistributeDirective = CXCursorKind.CXCursor_OMPTeamsDistributeDirective;
alias CXCursor_OMPTeamsDistributeSimdDirective = CXCursorKind.CXCursor_OMPTeamsDistributeSimdDirective;
alias CXCursor_OMPTeamsDistributeParallelForSimdDirective = CXCursorKind.CXCursor_OMPTeamsDistributeParallelForSimdDirective;
alias CXCursor_OMPTeamsDistributeParallelForDirective = CXCursorKind.CXCursor_OMPTeamsDistributeParallelForDirective;
alias CXCursor_OMPTargetTeamsDirective = CXCursorKind.CXCursor_OMPTargetTeamsDirective;
alias CXCursor_OMPTargetTeamsDistributeDirective = CXCursorKind.CXCursor_OMPTargetTeamsDistributeDirective;
alias CXCursor_OMPTargetTeamsDistributeParallelForDirective = CXCursorKind.CXCursor_OMPTargetTeamsDistributeParallelForDirective;
alias CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = CXCursorKind.CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective;
alias CXCursor_OMPTargetTeamsDistributeSimdDirective = CXCursorKind.CXCursor_OMPTargetTeamsDistributeSimdDirective;
alias CXCursor_BuiltinBitCastExpr = CXCursorKind.CXCursor_BuiltinBitCastExpr;
alias CXCursor_OMPMasterTaskLoopDirective = CXCursorKind.CXCursor_OMPMasterTaskLoopDirective;
alias CXCursor_OMPParallelMasterTaskLoopDirective = CXCursorKind.CXCursor_OMPParallelMasterTaskLoopDirective;
alias CXCursor_OMPMasterTaskLoopSimdDirective = CXCursorKind.CXCursor_OMPMasterTaskLoopSimdDirective;
alias CXCursor_OMPParallelMasterTaskLoopSimdDirective = CXCursorKind.CXCursor_OMPParallelMasterTaskLoopSimdDirective;
alias CXCursor_OMPParallelMasterDirective = CXCursorKind.CXCursor_OMPParallelMasterDirective;
alias CXCursor_OMPDepobjDirective = CXCursorKind.CXCursor_OMPDepobjDirective;
alias CXCursor_OMPScanDirective = CXCursorKind.CXCursor_OMPScanDirective;
alias CXCursor_OMPTileDirective = CXCursorKind.CXCursor_OMPTileDirective;
alias CXCursor_OMPCanonicalLoop = CXCursorKind.CXCursor_OMPCanonicalLoop;
alias CXCursor_OMPInteropDirective = CXCursorKind.CXCursor_OMPInteropDirective;
alias CXCursor_OMPDispatchDirective = CXCursorKind.CXCursor_OMPDispatchDirective;
alias CXCursor_OMPMaskedDirective = CXCursorKind.CXCursor_OMPMaskedDirective;
alias CXCursor_OMPUnrollDirective = CXCursorKind.CXCursor_OMPUnrollDirective;
alias CXCursor_OMPMetaDirective = CXCursorKind.CXCursor_OMPMetaDirective;
alias CXCursor_OMPGenericLoopDirective = CXCursorKind.CXCursor_OMPGenericLoopDirective;
alias CXCursor_OMPTeamsGenericLoopDirective = CXCursorKind.CXCursor_OMPTeamsGenericLoopDirective;
alias CXCursor_OMPTargetTeamsGenericLoopDirective = CXCursorKind.CXCursor_OMPTargetTeamsGenericLoopDirective;
alias CXCursor_OMPParallelGenericLoopDirective = CXCursorKind.CXCursor_OMPParallelGenericLoopDirective;
alias CXCursor_OMPTargetParallelGenericLoopDirective = CXCursorKind.CXCursor_OMPTargetParallelGenericLoopDirective;
alias CXCursor_OMPParallelMaskedDirective = CXCursorKind.CXCursor_OMPParallelMaskedDirective;
alias CXCursor_OMPMaskedTaskLoopDirective = CXCursorKind.CXCursor_OMPMaskedTaskLoopDirective;
alias CXCursor_OMPMaskedTaskLoopSimdDirective = CXCursorKind.CXCursor_OMPMaskedTaskLoopSimdDirective;
alias CXCursor_OMPParallelMaskedTaskLoopDirective = CXCursorKind.CXCursor_OMPParallelMaskedTaskLoopDirective;
alias CXCursor_OMPParallelMaskedTaskLoopSimdDirective = CXCursorKind.CXCursor_OMPParallelMaskedTaskLoopSimdDirective;
alias CXCursor_LastStmt = CXCursorKind.CXCursor_LastStmt;
alias CXCursor_TranslationUnit = CXCursorKind.CXCursor_TranslationUnit;
alias CXCursor_FirstAttr = CXCursorKind.CXCursor_FirstAttr;
alias CXCursor_UnexposedAttr = CXCursorKind.CXCursor_UnexposedAttr;
alias CXCursor_IBActionAttr = CXCursorKind.CXCursor_IBActionAttr;
alias CXCursor_IBOutletAttr = CXCursorKind.CXCursor_IBOutletAttr;
alias CXCursor_IBOutletCollectionAttr = CXCursorKind.CXCursor_IBOutletCollectionAttr;
alias CXCursor_CXXFinalAttr = CXCursorKind.CXCursor_CXXFinalAttr;
alias CXCursor_CXXOverrideAttr = CXCursorKind.CXCursor_CXXOverrideAttr;
alias CXCursor_AnnotateAttr = CXCursorKind.CXCursor_AnnotateAttr;
alias CXCursor_AsmLabelAttr = CXCursorKind.CXCursor_AsmLabelAttr;
alias CXCursor_PackedAttr = CXCursorKind.CXCursor_PackedAttr;
alias CXCursor_PureAttr = CXCursorKind.CXCursor_PureAttr;
alias CXCursor_ConstAttr = CXCursorKind.CXCursor_ConstAttr;
alias CXCursor_NoDuplicateAttr = CXCursorKind.CXCursor_NoDuplicateAttr;
alias CXCursor_CUDAConstantAttr = CXCursorKind.CXCursor_CUDAConstantAttr;
alias CXCursor_CUDADeviceAttr = CXCursorKind.CXCursor_CUDADeviceAttr;
alias CXCursor_CUDAGlobalAttr = CXCursorKind.CXCursor_CUDAGlobalAttr;
alias CXCursor_CUDAHostAttr = CXCursorKind.CXCursor_CUDAHostAttr;
alias CXCursor_CUDASharedAttr = CXCursorKind.CXCursor_CUDASharedAttr;
alias CXCursor_VisibilityAttr = CXCursorKind.CXCursor_VisibilityAttr;
alias CXCursor_DLLExport = CXCursorKind.CXCursor_DLLExport;
alias CXCursor_DLLImport = CXCursorKind.CXCursor_DLLImport;
alias CXCursor_NSReturnsRetained = CXCursorKind.CXCursor_NSReturnsRetained;
alias CXCursor_NSReturnsNotRetained = CXCursorKind.CXCursor_NSReturnsNotRetained;
alias CXCursor_NSReturnsAutoreleased = CXCursorKind.CXCursor_NSReturnsAutoreleased;
alias CXCursor_NSConsumesSelf = CXCursorKind.CXCursor_NSConsumesSelf;
alias CXCursor_NSConsumed = CXCursorKind.CXCursor_NSConsumed;
alias CXCursor_ObjCException = CXCursorKind.CXCursor_ObjCException;
alias CXCursor_ObjCNSObject = CXCursorKind.CXCursor_ObjCNSObject;
alias CXCursor_ObjCIndependentClass = CXCursorKind.CXCursor_ObjCIndependentClass;
alias CXCursor_ObjCPreciseLifetime = CXCursorKind.CXCursor_ObjCPreciseLifetime;
alias CXCursor_ObjCReturnsInnerPointer = CXCursorKind.CXCursor_ObjCReturnsInnerPointer;
alias CXCursor_ObjCRequiresSuper = CXCursorKind.CXCursor_ObjCRequiresSuper;
alias CXCursor_ObjCRootClass = CXCursorKind.CXCursor_ObjCRootClass;
alias CXCursor_ObjCSubclassingRestricted = CXCursorKind.CXCursor_ObjCSubclassingRestricted;
alias CXCursor_ObjCExplicitProtocolImpl = CXCursorKind.CXCursor_ObjCExplicitProtocolImpl;
alias CXCursor_ObjCDesignatedInitializer = CXCursorKind.CXCursor_ObjCDesignatedInitializer;
alias CXCursor_ObjCRuntimeVisible = CXCursorKind.CXCursor_ObjCRuntimeVisible;
alias CXCursor_ObjCBoxable = CXCursorKind.CXCursor_ObjCBoxable;
alias CXCursor_FlagEnum = CXCursorKind.CXCursor_FlagEnum;
alias CXCursor_ConvergentAttr = CXCursorKind.CXCursor_ConvergentAttr;
alias CXCursor_WarnUnusedAttr = CXCursorKind.CXCursor_WarnUnusedAttr;
alias CXCursor_WarnUnusedResultAttr = CXCursorKind.CXCursor_WarnUnusedResultAttr;
alias CXCursor_AlignedAttr = CXCursorKind.CXCursor_AlignedAttr;
alias CXCursor_LastAttr = CXCursorKind.CXCursor_LastAttr;
alias CXCursor_PreprocessingDirective = CXCursorKind.CXCursor_PreprocessingDirective;
alias CXCursor_MacroDefinition = CXCursorKind.CXCursor_MacroDefinition;
alias CXCursor_MacroExpansion = CXCursorKind.CXCursor_MacroExpansion;
alias CXCursor_MacroInstantiation = CXCursorKind.CXCursor_MacroInstantiation;
alias CXCursor_InclusionDirective = CXCursorKind.CXCursor_InclusionDirective;
alias CXCursor_FirstPreprocessing = CXCursorKind.CXCursor_FirstPreprocessing;
alias CXCursor_LastPreprocessing = CXCursorKind.CXCursor_LastPreprocessing;
alias CXCursor_ModuleImportDecl = CXCursorKind.CXCursor_ModuleImportDecl;
alias CXCursor_TypeAliasTemplateDecl = CXCursorKind.CXCursor_TypeAliasTemplateDecl;
alias CXCursor_StaticAssert = CXCursorKind.CXCursor_StaticAssert;
alias CXCursor_FriendDecl = CXCursorKind.CXCursor_FriendDecl;
alias CXCursor_ConceptDecl = CXCursorKind.CXCursor_ConceptDecl;
alias CXCursor_FirstExtraDecl = CXCursorKind.CXCursor_FirstExtraDecl;
alias CXCursor_LastExtraDecl = CXCursorKind.CXCursor_LastExtraDecl;
alias CXCursor_OverloadCandidate = CXCursorKind.CXCursor_OverloadCandidate;

/**
 * A cursor representing some element in the abstract syntax tree for
 * a translation unit.
 *
 * The cursor abstraction unifies the different kinds of entities in a
 * program--declaration, statements, expressions, references to declarations,
 * etc.--under a single "cursor" abstraction with a common set of operations.
 * Common operation for a cursor include: getting the physical location in
 * a source file where the cursor points, getting the name associated with a
 * cursor, and retrieving cursors for any child nodes of a particular cursor.
 *
 * Cursors can be produced in two specific ways.
 * clang_getTranslationUnitCursor() produces a cursor for a translation unit,
 * from which one can use clang_visitChildren() to explore the rest of the
 * translation unit. clang_getCursor() maps from a physical source location
 * to the entity that resides at that location, allowing one to map from the
 * source code into the AST.
 */
struct CXCursor
{
    CXCursorKind kind;
    int xdata;
    const(void)*[3] data;
}

/**
 * \defgroup CINDEX_CURSOR_MANIP Cursor manipulations
 *
 * @{
 */

/**
 * Retrieve the NULL cursor, which represents no entity.
 */
CXCursor clang_getNullCursor ();

/**
 * Retrieve the cursor that represents the given translation unit.
 *
 * The translation unit cursor can be used to start traversing the
 * various declarations within the given translation unit.
 */
CXCursor clang_getTranslationUnitCursor (in CXTranslationUnit);

/**
 * Determine whether two cursors are equivalent.
 */
uint clang_equalCursors (in CXCursor, CXCursor) pure;

/**
 * Returns non-zero if \p cursor is null.
 */
int clang_Cursor_isNull (in CXCursor cursor) pure;

/**
 * Compute a hash value for the given cursor.
 */
uint clang_hashCursor (in CXCursor) pure;

/**
 * Retrieve the kind of the given cursor.
 */
CXCursorKind clang_getCursorKind (in CXCursor) pure;

/**
 * Determine whether the given cursor kind represents a declaration.
 */
uint clang_isDeclaration (in CXCursorKind);

/**
 * Determine whether the given declaration is invalid.
 *
 * A declaration is invalid if it could not be parsed successfully.
 *
 * \returns non-zero if the cursor represents a declaration and it is
 * invalid, otherwise NULL.
 */
uint clang_isInvalidDeclaration (in CXCursor);

/**
 * Determine whether the given cursor kind represents a simple
 * reference.
 *
 * Note that other kinds of cursors (such as expressions) can also refer to
 * other cursors. Use clang_getCursorReferenced() to determine whether a
 * particular cursor refers to another entity.
 */
uint clang_isReference (in CXCursorKind);

/**
 * Determine whether the given cursor kind represents an expression.
 */
uint clang_isExpression (in CXCursorKind);

/**
 * Determine whether the given cursor kind represents a statement.
 */
uint clang_isStatement (in CXCursorKind);

/**
 * Determine whether the given cursor kind represents an attribute.
 */
uint clang_isAttribute (in CXCursorKind);

/**
 * Determine whether the given cursor has any attributes.
 */
uint clang_Cursor_hasAttrs (in CXCursor C);

/**
 * Determine whether the given cursor kind represents an invalid
 * cursor.
 */
uint clang_isInvalid (in CXCursorKind) pure;

/**
 * Determine whether the given cursor kind represents a translation
 * unit.
 */
uint clang_isTranslationUnit (in CXCursorKind);

/***
 * Determine whether the given cursor represents a preprocessing
 * element, such as a preprocessor directive or macro instantiation.
 */
uint clang_isPreprocessing (in CXCursorKind);

/***
 * Determine whether the given cursor represents a currently
 *  unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
 */
uint clang_isUnexposed (in CXCursorKind);

/**
 * Describe the linkage of the entity referred to by a cursor.
 */
enum CXLinkageKind
{
    /** This value indicates that no linkage information is available
     * for a provided CXCursor. */
    CXLinkage_Invalid = 0,
    /**
     * This is the linkage for variables, parameters, and so on that
     *  have automatic storage.  This covers normal (non-extern) local variables.
     */
    CXLinkage_NoLinkage = 1,
    /** This is the linkage for static variables and static functions. */
    CXLinkage_Internal = 2,
    /** This is the linkage for entities with external linkage that live
     * in C++ anonymous namespaces.*/
    CXLinkage_UniqueExternal = 3,
    /** This is the linkage for entities with true, external linkage. */
    CXLinkage_External = 4
}

alias CXLinkage_Invalid = CXLinkageKind.CXLinkage_Invalid;
alias CXLinkage_NoLinkage = CXLinkageKind.CXLinkage_NoLinkage;
alias CXLinkage_Internal = CXLinkageKind.CXLinkage_Internal;
alias CXLinkage_UniqueExternal = CXLinkageKind.CXLinkage_UniqueExternal;
alias CXLinkage_External = CXLinkageKind.CXLinkage_External;

/**
 * Determine the linkage of the entity referred to by a given cursor.
 */
CXLinkageKind clang_getCursorLinkage (in CXCursor cursor) pure;

enum CXVisibilityKind
{
    /** This value indicates that no visibility information is available
     * for a provided CXCursor. */
    CXVisibility_Invalid = 0,

    /** Symbol not seen by the linker. */
    CXVisibility_Hidden = 1,
    /** Symbol seen by the linker but resolves to a symbol inside this object. */
    CXVisibility_Protected = 2,
    /** Symbol seen by the linker and acts like a normal symbol. */
    CXVisibility_Default = 3
}

alias CXVisibility_Invalid = CXVisibilityKind.CXVisibility_Invalid;
alias CXVisibility_Hidden = CXVisibilityKind.CXVisibility_Hidden;
alias CXVisibility_Protected = CXVisibilityKind.CXVisibility_Protected;
alias CXVisibility_Default = CXVisibilityKind.CXVisibility_Default;

/**
 * Describe the visibility of the entity referred to by a cursor.
 *
 * This returns the default visibility if not explicitly specified by
 * a visibility attribute. The default visibility may be changed by
 * commandline arguments.
 *
 * \param cursor The cursor to query.
 *
 * \returns The visibility of the cursor.
 */
CXVisibilityKind clang_getCursorVisibility (in CXCursor cursor);

/**
 * Determine the availability of the entity that this cursor refers to,
 * taking the current target platform into account.
 *
 * \param cursor The cursor to query.
 *
 * \returns The availability of the cursor.
 */
CXAvailabilityKind clang_getCursorAvailability (in CXCursor cursor);

/**
 * Describes the availability of a given entity on a particular platform, e.g.,
 * a particular class might only be available on Mac OS 10.7 or newer.
 */
struct CXPlatformAvailability
{
    /**
     * A string that describes the platform for which this structure
     * provides availability information.
     *
     * Possible values are "ios" or "macos".
     */
    //alias CXString = _Anonymous_0; ???
    CXString Platform;
    /**
     * The version number in which this entity was introduced.
     */
    CXVersion Introduced;
    /**
     * The version number in which this entity was deprecated (but is
     * still available).
     */
    CXVersion Deprecated;
    /**
     * The version number in which this entity was obsoleted, and therefore
     * is no longer available.
     */
    CXVersion Obsoleted;
    /**
     * Whether the entity is unconditionally unavailable on this platform.
     */
    int Unavailable;
    /**
     * An optional message to provide to a user of this API, e.g., to
     * suggest replacement APIs.
     */
    CXString Message;
}

/**
 * Determine the availability of the entity that this cursor refers to
 * on any platforms for which availability information is known.
 *
 * \param cursor The cursor to query.
 *
 * \param always_deprecated If non-NULL, will be set to indicate whether the
 * entity is deprecated on all platforms.
 *
 * \param deprecated_message If non-NULL, will be set to the message text
 * provided along with the unconditional deprecation of this entity. The client
 * is responsible for deallocating this string.
 *
 * \param always_unavailable If non-NULL, will be set to indicate whether the
 * entity is unavailable on all platforms.
 *
 * \param unavailable_message If non-NULL, will be set to the message text
 * provided along with the unconditional unavailability of this entity. The
 * client is responsible for deallocating this string.
 *
 * \param availability If non-NULL, an array of CXPlatformAvailability instances
 * that will be populated with platform availability information, up to either
 * the number of platforms for which availability information is available (as
 * returned by this function) or \c availability_size, whichever is smaller.
 *
 * \param availability_size The number of elements available in the
 * \c availability array.
 *
 * \returns The number of platforms (N) for which availability information is
 * available (which is unrelated to \c availability_size).
 *
 * Note that the client is responsible for calling
 * \c clang_disposeCXPlatformAvailability to free each of the
 * platform-availability structures returned. There are
 * \c min(N, availability_size) such structures.
 */
int clang_getCursorPlatformAvailability (
    CXCursor cursor,
    int* always_deprecated,
    CXString* deprecated_message,
    int* always_unavailable,
    CXString* unavailable_message,
    CXPlatformAvailability* availability,
    int availability_size);

/**
 * Free the memory associated with a \c CXPlatformAvailability structure.
 */
void clang_disposeCXPlatformAvailability (in CXPlatformAvailability* availability);

/**
 * If cursor refers to a variable declaration and it has initializer returns
 * cursor referring to the initializer otherwise return null cursor.
 */
CXCursor clang_Cursor_getVarDeclInitializer (in CXCursor cursor);

/**
 * If cursor refers to a variable declaration that has global storage returns 1.
 * If cursor refers to a variable declaration that doesn't have global storage
 * returns 0. Otherwise returns -1.
 */
int clang_Cursor_hasVarDeclGlobalStorage (in CXCursor cursor);

/**
 * If cursor refers to a variable declaration that has external storage
 * returns 1. If cursor refers to a variable declaration that doesn't have
 * external storage returns 0. Otherwise returns -1.
 */
int clang_Cursor_hasVarDeclExternalStorage (in CXCursor cursor);

/**
 * Describe the "language" of the entity referred to by a cursor.
 */
enum CXLanguageKind
{
    CXLanguage_Invalid = 0,
    CXLanguage_C = 1,
    CXLanguage_ObjC = 2,
    CXLanguage_CPlusPlus = 3
}

alias CXLanguage_Invalid = CXLanguageKind.CXLanguage_Invalid;
alias CXLanguage_C = CXLanguageKind.CXLanguage_C;
alias CXLanguage_ObjC = CXLanguageKind.CXLanguage_ObjC;
alias CXLanguage_CPlusPlus = CXLanguageKind.CXLanguage_CPlusPlus;

/**
 * Determine the "language" of the entity referred to by a given cursor.
 */
CXLanguageKind clang_getCursorLanguage (in CXCursor cursor) pure;

/**
 * Describe the "thread-local storage (TLS) kind" of the declaration
 * referred to by a cursor.
 */
enum CXTLSKind
{
    CXTLS_None = 0,
    CXTLS_Dynamic = 1,
    CXTLS_Static = 2
}

alias CXTLS_None = CXTLSKind.CXTLS_None;
alias CXTLS_Dynamic = CXTLSKind.CXTLS_Dynamic;
alias CXTLS_Static = CXTLSKind.CXTLS_Static;

/**
 * Determine the "thread-local storage (TLS) kind" of the declaration
 * referred to by a cursor.
 */
CXTLSKind clang_getCursorTLSKind (in CXCursor cursor);

/**
 * Returns the translation unit that a cursor originated from.
 */
CXTranslationUnit clang_Cursor_getTranslationUnit (in CXCursor) pure;

/**
 * A fast container representing a set of CXCursors.
 */
struct CXCursorSetImpl;
alias CXCursorSet = CXCursorSetImpl*;

/**
 * Creates an empty CXCursorSet.
 */
CXCursorSet clang_createCXCursorSet ();

/**
 * Disposes a CXCursorSet and releases its associated memory.
 */
void clang_disposeCXCursorSet (in CXCursorSet cset);

/**
 * Queries a CXCursorSet to see if it contains a specific CXCursor.
 *
 * \returns non-zero if the set contains the specified cursor.
 */
uint clang_CXCursorSet_contains (in CXCursorSet cset, CXCursor cursor);

/**
 * Inserts a CXCursor into a CXCursorSet.
 *
 * \returns zero if the CXCursor was already in the set, and non-zero otherwise.
 */
uint clang_CXCursorSet_insert (in CXCursorSet cset, CXCursor cursor);

/**
 * Determine the semantic parent of the given cursor.
 *
 * The semantic parent of a cursor is the cursor that semantically contains
 * the given \p cursor. For many declarations, the lexical and semantic parents
 * are equivalent (the lexical parent is returned by
 * \c clang_getCursorLexicalParent()). They diverge when declarations or
 * definitions are provided out-of-line. For example:
 *
 * \code
 * class C {
 *  void f();
 * };
 *
 * void C::f() { }
 * \endcode
 *
 * In the out-of-line definition of \c C::f, the semantic parent is
 * the class \c C, of which this function is a member. The lexical parent is
 * the place where the declaration actually occurs in the source code; in this
 * case, the definition occurs in the translation unit. In general, the
 * lexical parent for a given entity can change without affecting the semantics
 * of the program, and the lexical parent of different declarations of the
 * same entity may be different. Changing the semantic parent of a declaration,
 * on the other hand, can have a major impact on semantics, and redeclarations
 * of a particular entity should all have the same semantic context.
 *
 * In the example above, both declarations of \c C::f have \c C as their
 * semantic context, while the lexical context of the first \c C::f is \c C
 * and the lexical context of the second \c C::f is the translation unit.
 *
 * For global declarations, the semantic parent is the translation unit.
 */
CXCursor clang_getCursorSemanticParent (in CXCursor cursor);

/**
 * Determine the lexical parent of the given cursor.
 *
 * The lexical parent of a cursor is the cursor in which the given \p cursor
 * was actually written. For many declarations, the lexical and semantic parents
 * are equivalent (the semantic parent is returned by
 * \c clang_getCursorSemanticParent()). They diverge when declarations or
 * definitions are provided out-of-line. For example:
 *
 * \code
 * class C {
 *  void f();
 * };
 *
 * void C::f() { }
 * \endcode
 *
 * In the out-of-line definition of \c C::f, the semantic parent is
 * the class \c C, of which this function is a member. The lexical parent is
 * the place where the declaration actually occurs in the source code; in this
 * case, the definition occurs in the translation unit. In general, the
 * lexical parent for a given entity can change without affecting the semantics
 * of the program, and the lexical parent of different declarations of the
 * same entity may be different. Changing the semantic parent of a declaration,
 * on the other hand, can have a major impact on semantics, and redeclarations
 * of a particular entity should all have the same semantic context.
 *
 * In the example above, both declarations of \c C::f have \c C as their
 * semantic context, while the lexical context of the first \c C::f is \c C
 * and the lexical context of the second \c C::f is the translation unit.
 *
 * For declarations written in the global scope, the lexical parent is
 * the translation unit.
 */
CXCursor clang_getCursorLexicalParent (in CXCursor cursor);

/**
 * Determine the set of methods that are overridden by the given
 * method.
 *
 * In both Objective-C and C++, a method (aka virtual member function,
 * in C++) can override a virtual method in a base class. For
 * Objective-C, a method is said to override any method in the class's
 * base class, its protocols, or its categories' protocols, that has the same
 * selector and is of the same kind (class or instance).
 * If no such method exists, the search continues to the class's superclass,
 * its protocols, and its categories, and so on. A method from an Objective-C
 * implementation is considered to override the same methods as its
 * corresponding method in the interface.
 *
 * For C++, a virtual member function overrides any virtual member
 * function with the same signature that occurs in its base
 * classes. With multiple inheritance, a virtual member function can
 * override several virtual member functions coming from different
 * base classes.
 *
 * In all cases, this function determines the immediate overridden
 * method, rather than all of the overridden methods. For example, if
 * a method is originally declared in a class A, then overridden in B
 * (which in inherits from A) and also in C (which inherited from B),
 * then the only overridden method returned from this function when
 * invoked on C's method will be B's method. The client may then
 * invoke this function again, given the previously-found overridden
 * methods, to map out the complete method-override set.
 *
 * \param cursor A cursor representing an Objective-C or C++
 * method. This routine will compute the set of methods that this
 * method overrides.
 *
 * \param overridden A pointer whose pointee will be replaced with a
 * pointer to an array of cursors, representing the set of overridden
 * methods. If there are no overridden methods, the pointee will be
 * set to NULL. The pointee must be freed via a call to
 * \c clang_disposeOverriddenCursors().
 *
 * \param num_overridden A pointer to the number of overridden
 * functions, will be set to the number of overridden functions in the
 * array pointed to by \p overridden.
 */
void clang_getOverriddenCursors (
    CXCursor cursor,
    CXCursor** overridden,
    uint* num_overridden);

/**
 * Free the set of overridden cursors returned by \c
 * clang_getOverriddenCursors().
 */
void clang_disposeOverriddenCursors (in CXCursor* overridden);

/**
 * Retrieve the file that is included by the given inclusion directive
 * cursor.
 */
CXFile clang_getIncludedFile (in CXCursor cursor);

/**
 * @}
 */

/**
 * \defgroup CINDEX_CURSOR_SOURCE Mapping between cursors and source code
 *
 * Cursors represent a location within the Abstract Syntax Tree (AST). These
 * routines help map between cursors and the physical locations where the
 * described entities occur in the source code. The mapping is provided in
 * both directions, so one can map from source code to the AST and back.
 *
 * @{
 */

/**
 * Map a source location to the cursor that describes the entity at that
 * location in the source code.
 *
 * clang_getCursor() maps an arbitrary source location within a translation
 * unit down to the most specific cursor that describes the entity at that
 * location. For example, given an expression \c x + y, invoking
 * clang_getCursor() with a source location pointing to "x" will return the
 * cursor for "x"; similarly for "y". If the cursor points anywhere between
 * "x" or "y" (e.g., on the + or the whitespace around it), clang_getCursor()
 * will return a cursor referring to the "+" expression.
 *
 * \returns a cursor representing the entity at the given source location, or
 * a NULL cursor if no such entity can be found.
 */
CXCursor clang_getCursor (in CXTranslationUnit, CXSourceLocation);

/**
 * Retrieve the physical location of the source constructor referenced
 * by the given cursor.
 *
 * The location of a declaration is typically the location of the name of that
 * declaration, where the name of that declaration would occur if it is
 * unnamed, or some keyword that introduces that particular declaration.
 * The location of a reference is where that reference occurs within the
 * source code.
 */
CXSourceLocation clang_getCursorLocation (in CXCursor);

/**
 * Retrieve the physical extent of the source construct referenced by
 * the given cursor.
 *
 * The extent of a cursor starts with the file/line/column pointing at the
 * first character within the source construct that the cursor refers to and
 * ends with the last character within that source construct. For a
 * declaration, the extent covers the declaration itself. For a reference,
 * the extent covers the location of the reference (e.g., where the referenced
 * entity was actually used).
 */
CXSourceRange clang_getCursorExtent (in CXCursor) pure;

/**
 * @}
 */

/**
 * \defgroup CINDEX_TYPES Type information for CXCursors
 *
 * @{
 */

/**
 * Describes the kind of type
 */
enum CXTypeKind
{
    /**
     * Represents an invalid type (e.g., where no type is available).
     */
    CXType_Invalid = 0,

    /**
     * A type whose specific kind is not exposed via this
     * interface.
     */
    CXType_Unexposed = 1,

    /* Builtin types */
    CXType_Void = 2,
    CXType_Bool = 3,
    CXType_Char_U = 4,
    CXType_UChar = 5,
    CXType_Char16 = 6,
    CXType_Char32 = 7,
    CXType_UShort = 8,
    CXType_UInt = 9,
    CXType_ULong = 10,
    CXType_ULongLong = 11,
    CXType_UInt128 = 12,
    CXType_Char_S = 13,
    CXType_SChar = 14,
    CXType_WChar = 15,
    CXType_Short = 16,
    CXType_Int = 17,
    CXType_Long = 18,
    CXType_LongLong = 19,
    CXType_Int128 = 20,
    CXType_Float = 21,
    CXType_Double = 22,
    CXType_LongDouble = 23,
    CXType_NullPtr = 24,
    CXType_Overload = 25,
    CXType_Dependent = 26,
    CXType_ObjCId = 27,
    CXType_ObjCClass = 28,
    CXType_ObjCSel = 29,
    CXType_Float128 = 30,
    CXType_Half = 31,
    CXType_Float16 = 32,
    CXType_ShortAccum = 33,
    CXType_Accum = 34,
    CXType_LongAccum = 35,
    CXType_UShortAccum = 36,
    CXType_UAccum = 37,
    CXType_ULongAccum = 38,
    CXType_BFloat16 = 39,
    CXType_Ibm128 = 40,
    CXType_FirstBuiltin = CXType_Void,
    CXType_LastBuiltin = CXType_Ibm128,

    CXType_Complex = 100,
    CXType_Pointer = 101,
    CXType_BlockPointer = 102,
    CXType_LValueReference = 103,
    CXType_RValueReference = 104,
    CXType_Record = 105,
    CXType_Enum = 106,
    CXType_Typedef = 107,
    CXType_ObjCInterface = 108,
    CXType_ObjCObjectPointer = 109,
    CXType_FunctionNoProto = 110,
    CXType_FunctionProto = 111,
    CXType_ConstantArray = 112,
    CXType_Vector = 113,
    CXType_IncompleteArray = 114,
    CXType_VariableArray = 115,
    CXType_DependentSizedArray = 116,
    CXType_MemberPointer = 117,
    CXType_Auto = 118,

    /**
     * Represents a type that was referred to using an elaborated type keyword.
     *
     * E.g., struct S, or via a qualified name, e.g., N::M::type, or both.
     */
    CXType_Elaborated = 119,

    /* OpenCL PipeType. */
    CXType_Pipe = 120,

    /* OpenCL builtin types. */
    CXType_OCLImage1dRO = 121,
    CXType_OCLImage1dArrayRO = 122,
    CXType_OCLImage1dBufferRO = 123,
    CXType_OCLImage2dRO = 124,
    CXType_OCLImage2dArrayRO = 125,
    CXType_OCLImage2dDepthRO = 126,
    CXType_OCLImage2dArrayDepthRO = 127,
    CXType_OCLImage2dMSAARO = 128,
    CXType_OCLImage2dArrayMSAARO = 129,
    CXType_OCLImage2dMSAADepthRO = 130,
    CXType_OCLImage2dArrayMSAADepthRO = 131,
    CXType_OCLImage3dRO = 132,
    CXType_OCLImage1dWO = 133,
    CXType_OCLImage1dArrayWO = 134,
    CXType_OCLImage1dBufferWO = 135,
    CXType_OCLImage2dWO = 136,
    CXType_OCLImage2dArrayWO = 137,
    CXType_OCLImage2dDepthWO = 138,
    CXType_OCLImage2dArrayDepthWO = 139,
    CXType_OCLImage2dMSAAWO = 140,
    CXType_OCLImage2dArrayMSAAWO = 141,
    CXType_OCLImage2dMSAADepthWO = 142,
    CXType_OCLImage2dArrayMSAADepthWO = 143,
    CXType_OCLImage3dWO = 144,
    CXType_OCLImage1dRW = 145,
    CXType_OCLImage1dArrayRW = 146,
    CXType_OCLImage1dBufferRW = 147,
    CXType_OCLImage2dRW = 148,
    CXType_OCLImage2dArrayRW = 149,
    CXType_OCLImage2dDepthRW = 150,
    CXType_OCLImage2dArrayDepthRW = 151,
    CXType_OCLImage2dMSAARW = 152,
    CXType_OCLImage2dArrayMSAARW = 153,
    CXType_OCLImage2dMSAADepthRW = 154,
    CXType_OCLImage2dArrayMSAADepthRW = 155,
    CXType_OCLImage3dRW = 156,
    CXType_OCLSampler = 157,
    CXType_OCLEvent = 158,
    CXType_OCLQueue = 159,
    CXType_OCLReserveID = 160,

    CXType_ObjCObject = 161,
    CXType_ObjCTypeParam = 162,
    CXType_Attributed = 163,

    CXType_OCLIntelSubgroupAVCMcePayload = 164,
    CXType_OCLIntelSubgroupAVCImePayload = 165,
    CXType_OCLIntelSubgroupAVCRefPayload = 166,
    CXType_OCLIntelSubgroupAVCSicPayload = 167,
    CXType_OCLIntelSubgroupAVCMceResult = 168,
    CXType_OCLIntelSubgroupAVCImeResult = 169,
    CXType_OCLIntelSubgroupAVCRefResult = 170,
    CXType_OCLIntelSubgroupAVCSicResult = 171,
    CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172,
    CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = 173,
    CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = 174,

    CXType_OCLIntelSubgroupAVCImeDualRefStreamin = 175,

    CXType_ExtVector = 176,
    CXType_Atomic = 177,
    CXType_BTFTagAttributed = 178
}

alias CXType_Invalid = CXTypeKind.CXType_Invalid;
alias CXType_Unexposed = CXTypeKind.CXType_Unexposed;
alias CXType_Void = CXTypeKind.CXType_Void;
alias CXType_Bool = CXTypeKind.CXType_Bool;
alias CXType_Char_U = CXTypeKind.CXType_Char_U;
alias CXType_UChar = CXTypeKind.CXType_UChar;
alias CXType_Char16 = CXTypeKind.CXType_Char16;
alias CXType_Char32 = CXTypeKind.CXType_Char32;
alias CXType_UShort = CXTypeKind.CXType_UShort;
alias CXType_UInt = CXTypeKind.CXType_UInt;
alias CXType_ULong = CXTypeKind.CXType_ULong;
alias CXType_ULongLong = CXTypeKind.CXType_ULongLong;
alias CXType_UInt128 = CXTypeKind.CXType_UInt128;
alias CXType_Char_S = CXTypeKind.CXType_Char_S;
alias CXType_SChar = CXTypeKind.CXType_SChar;
alias CXType_WChar = CXTypeKind.CXType_WChar;
alias CXType_Short = CXTypeKind.CXType_Short;
alias CXType_Int = CXTypeKind.CXType_Int;
alias CXType_Long = CXTypeKind.CXType_Long;
alias CXType_LongLong = CXTypeKind.CXType_LongLong;
alias CXType_Int128 = CXTypeKind.CXType_Int128;
alias CXType_Float = CXTypeKind.CXType_Float;
alias CXType_Double = CXTypeKind.CXType_Double;
alias CXType_LongDouble = CXTypeKind.CXType_LongDouble;
alias CXType_NullPtr = CXTypeKind.CXType_NullPtr;
alias CXType_Overload = CXTypeKind.CXType_Overload;
alias CXType_Dependent = CXTypeKind.CXType_Dependent;
alias CXType_ObjCId = CXTypeKind.CXType_ObjCId;
alias CXType_ObjCClass = CXTypeKind.CXType_ObjCClass;
alias CXType_ObjCSel = CXTypeKind.CXType_ObjCSel;
alias CXType_Float128 = CXTypeKind.CXType_Float128;
alias CXType_Half = CXTypeKind.CXType_Half;
alias CXType_Float16 = CXTypeKind.CXType_Float16;
alias CXType_ShortAccum = CXTypeKind.CXType_ShortAccum;
alias CXType_Accum = CXTypeKind.CXType_Accum;
alias CXType_LongAccum = CXTypeKind.CXType_LongAccum;
alias CXType_UShortAccum = CXTypeKind.CXType_UShortAccum;
alias CXType_UAccum = CXTypeKind.CXType_UAccum;
alias CXType_ULongAccum = CXTypeKind.CXType_ULongAccum;
alias CXType_BFloat16 = CXTypeKind.CXType_BFloat16;
alias CXType_Ibm128 = CXTypeKind.CXType_Ibm128;
alias CXType_FirstBuiltin = CXTypeKind.CXType_FirstBuiltin;
alias CXType_LastBuiltin = CXTypeKind.CXType_LastBuiltin;
alias CXType_Complex = CXTypeKind.CXType_Complex;
alias CXType_Pointer = CXTypeKind.CXType_Pointer;
alias CXType_BlockPointer = CXTypeKind.CXType_BlockPointer;
alias CXType_LValueReference = CXTypeKind.CXType_LValueReference;
alias CXType_RValueReference = CXTypeKind.CXType_RValueReference;
alias CXType_Record = CXTypeKind.CXType_Record;
alias CXType_Enum = CXTypeKind.CXType_Enum;
alias CXType_Typedef = CXTypeKind.CXType_Typedef;
alias CXType_ObjCInterface = CXTypeKind.CXType_ObjCInterface;
alias CXType_ObjCObjectPointer = CXTypeKind.CXType_ObjCObjectPointer;
alias CXType_FunctionNoProto = CXTypeKind.CXType_FunctionNoProto;
alias CXType_FunctionProto = CXTypeKind.CXType_FunctionProto;
alias CXType_ConstantArray = CXTypeKind.CXType_ConstantArray;
alias CXType_Vector = CXTypeKind.CXType_Vector;
alias CXType_IncompleteArray = CXTypeKind.CXType_IncompleteArray;
alias CXType_VariableArray = CXTypeKind.CXType_VariableArray;
alias CXType_DependentSizedArray = CXTypeKind.CXType_DependentSizedArray;
alias CXType_MemberPointer = CXTypeKind.CXType_MemberPointer;
alias CXType_Auto = CXTypeKind.CXType_Auto;
alias CXType_Elaborated = CXTypeKind.CXType_Elaborated;
alias CXType_Pipe = CXTypeKind.CXType_Pipe;
alias CXType_OCLImage1dRO = CXTypeKind.CXType_OCLImage1dRO;
alias CXType_OCLImage1dArrayRO = CXTypeKind.CXType_OCLImage1dArrayRO;
alias CXType_OCLImage1dBufferRO = CXTypeKind.CXType_OCLImage1dBufferRO;
alias CXType_OCLImage2dRO = CXTypeKind.CXType_OCLImage2dRO;
alias CXType_OCLImage2dArrayRO = CXTypeKind.CXType_OCLImage2dArrayRO;
alias CXType_OCLImage2dDepthRO = CXTypeKind.CXType_OCLImage2dDepthRO;
alias CXType_OCLImage2dArrayDepthRO = CXTypeKind.CXType_OCLImage2dArrayDepthRO;
alias CXType_OCLImage2dMSAARO = CXTypeKind.CXType_OCLImage2dMSAARO;
alias CXType_OCLImage2dArrayMSAARO = CXTypeKind.CXType_OCLImage2dArrayMSAARO;
alias CXType_OCLImage2dMSAADepthRO = CXTypeKind.CXType_OCLImage2dMSAADepthRO;
alias CXType_OCLImage2dArrayMSAADepthRO = CXTypeKind.CXType_OCLImage2dArrayMSAADepthRO;
alias CXType_OCLImage3dRO = CXTypeKind.CXType_OCLImage3dRO;
alias CXType_OCLImage1dWO = CXTypeKind.CXType_OCLImage1dWO;
alias CXType_OCLImage1dArrayWO = CXTypeKind.CXType_OCLImage1dArrayWO;
alias CXType_OCLImage1dBufferWO = CXTypeKind.CXType_OCLImage1dBufferWO;
alias CXType_OCLImage2dWO = CXTypeKind.CXType_OCLImage2dWO;
alias CXType_OCLImage2dArrayWO = CXTypeKind.CXType_OCLImage2dArrayWO;
alias CXType_OCLImage2dDepthWO = CXTypeKind.CXType_OCLImage2dDepthWO;
alias CXType_OCLImage2dArrayDepthWO = CXTypeKind.CXType_OCLImage2dArrayDepthWO;
alias CXType_OCLImage2dMSAAWO = CXTypeKind.CXType_OCLImage2dMSAAWO;
alias CXType_OCLImage2dArrayMSAAWO = CXTypeKind.CXType_OCLImage2dArrayMSAAWO;
alias CXType_OCLImage2dMSAADepthWO = CXTypeKind.CXType_OCLImage2dMSAADepthWO;
alias CXType_OCLImage2dArrayMSAADepthWO = CXTypeKind.CXType_OCLImage2dArrayMSAADepthWO;
alias CXType_OCLImage3dWO = CXTypeKind.CXType_OCLImage3dWO;
alias CXType_OCLImage1dRW = CXTypeKind.CXType_OCLImage1dRW;
alias CXType_OCLImage1dArrayRW = CXTypeKind.CXType_OCLImage1dArrayRW;
alias CXType_OCLImage1dBufferRW = CXTypeKind.CXType_OCLImage1dBufferRW;
alias CXType_OCLImage2dRW = CXTypeKind.CXType_OCLImage2dRW;
alias CXType_OCLImage2dArrayRW = CXTypeKind.CXType_OCLImage2dArrayRW;
alias CXType_OCLImage2dDepthRW = CXTypeKind.CXType_OCLImage2dDepthRW;
alias CXType_OCLImage2dArrayDepthRW = CXTypeKind.CXType_OCLImage2dArrayDepthRW;
alias CXType_OCLImage2dMSAARW = CXTypeKind.CXType_OCLImage2dMSAARW;
alias CXType_OCLImage2dArrayMSAARW = CXTypeKind.CXType_OCLImage2dArrayMSAARW;
alias CXType_OCLImage2dMSAADepthRW = CXTypeKind.CXType_OCLImage2dMSAADepthRW;
alias CXType_OCLImage2dArrayMSAADepthRW = CXTypeKind.CXType_OCLImage2dArrayMSAADepthRW;
alias CXType_OCLImage3dRW = CXTypeKind.CXType_OCLImage3dRW;
alias CXType_OCLSampler = CXTypeKind.CXType_OCLSampler;
alias CXType_OCLEvent = CXTypeKind.CXType_OCLEvent;
alias CXType_OCLQueue = CXTypeKind.CXType_OCLQueue;
alias CXType_OCLReserveID = CXTypeKind.CXType_OCLReserveID;
alias CXType_ObjCObject = CXTypeKind.CXType_ObjCObject;
alias CXType_ObjCTypeParam = CXTypeKind.CXType_ObjCTypeParam;
alias CXType_Attributed = CXTypeKind.CXType_Attributed;
alias CXType_OCLIntelSubgroupAVCMcePayload = CXTypeKind.CXType_OCLIntelSubgroupAVCMcePayload;
alias CXType_OCLIntelSubgroupAVCImePayload = CXTypeKind.CXType_OCLIntelSubgroupAVCImePayload;
alias CXType_OCLIntelSubgroupAVCRefPayload = CXTypeKind.CXType_OCLIntelSubgroupAVCRefPayload;
alias CXType_OCLIntelSubgroupAVCSicPayload = CXTypeKind.CXType_OCLIntelSubgroupAVCSicPayload;
alias CXType_OCLIntelSubgroupAVCMceResult = CXTypeKind.CXType_OCLIntelSubgroupAVCMceResult;
alias CXType_OCLIntelSubgroupAVCImeResult = CXTypeKind.CXType_OCLIntelSubgroupAVCImeResult;
alias CXType_OCLIntelSubgroupAVCRefResult = CXTypeKind.CXType_OCLIntelSubgroupAVCRefResult;
alias CXType_OCLIntelSubgroupAVCSicResult = CXTypeKind.CXType_OCLIntelSubgroupAVCSicResult;
alias CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = CXTypeKind.CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout;
alias CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = CXTypeKind.CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout;
alias CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = CXTypeKind.CXType_OCLIntelSubgroupAVCImeSingleRefStreamin;
alias CXType_OCLIntelSubgroupAVCImeDualRefStreamin = CXTypeKind.CXType_OCLIntelSubgroupAVCImeDualRefStreamin;
alias CXType_ExtVector = CXTypeKind.CXType_ExtVector;
alias CXType_Atomic = CXTypeKind.CXType_Atomic;
alias CXType_BTFTagAttributed = CXTypeKind.CXType_BTFTagAttributed;

/**
 * Describes the calling convention of a function type
 */
enum CXCallingConv
{
    CXCallingConv_Default = 0,
    CXCallingConv_C = 1,
    CXCallingConv_X86StdCall = 2,
    CXCallingConv_X86FastCall = 3,
    CXCallingConv_X86ThisCall = 4,
    CXCallingConv_X86Pascal = 5,
    CXCallingConv_AAPCS = 6,
    CXCallingConv_AAPCS_VFP = 7,
    CXCallingConv_X86RegCall = 8,
    CXCallingConv_IntelOclBicc = 9,
    CXCallingConv_Win64 = 10,
    /* Alias for compatibility with older versions of API. */
    CXCallingConv_X86_64Win64 = CXCallingConv_Win64,
    CXCallingConv_X86_64SysV = 11,
    CXCallingConv_X86VectorCall = 12,
    CXCallingConv_Swift = 13,
    CXCallingConv_PreserveMost = 14,
    CXCallingConv_PreserveAll = 15,
    CXCallingConv_AArch64VectorCall = 16,
    CXCallingConv_SwiftAsync = 17,
    CXCallingConv_AArch64SVEPCS = 18,

    CXCallingConv_Invalid = 100,
    CXCallingConv_Unexposed = 200
}

alias CXCallingConv_Default = CXCallingConv.CXCallingConv_Default;
alias CXCallingConv_C = CXCallingConv.CXCallingConv_C;
alias CXCallingConv_X86StdCall = CXCallingConv.CXCallingConv_X86StdCall;
alias CXCallingConv_X86FastCall = CXCallingConv.CXCallingConv_X86FastCall;
alias CXCallingConv_X86ThisCall = CXCallingConv.CXCallingConv_X86ThisCall;
alias CXCallingConv_X86Pascal = CXCallingConv.CXCallingConv_X86Pascal;
alias CXCallingConv_AAPCS = CXCallingConv.CXCallingConv_AAPCS;
alias CXCallingConv_AAPCS_VFP = CXCallingConv.CXCallingConv_AAPCS_VFP;
alias CXCallingConv_X86RegCall = CXCallingConv.CXCallingConv_X86RegCall;
alias CXCallingConv_IntelOclBicc = CXCallingConv.CXCallingConv_IntelOclBicc;
alias CXCallingConv_Win64 = CXCallingConv.CXCallingConv_Win64;
alias CXCallingConv_X86_64Win64 = CXCallingConv.CXCallingConv_X86_64Win64;
alias CXCallingConv_X86_64SysV = CXCallingConv.CXCallingConv_X86_64SysV;
alias CXCallingConv_X86VectorCall = CXCallingConv.CXCallingConv_X86VectorCall;
alias CXCallingConv_Swift = CXCallingConv.CXCallingConv_Swift;
alias CXCallingConv_PreserveMost = CXCallingConv.CXCallingConv_PreserveMost;
alias CXCallingConv_PreserveAll = CXCallingConv.CXCallingConv_PreserveAll;
alias CXCallingConv_AArch64VectorCall = CXCallingConv.CXCallingConv_AArch64VectorCall;
alias CXCallingConv_SwiftAsync = CXCallingConv.CXCallingConv_SwiftAsync;
alias CXCallingConv_AArch64SVEPCS = CXCallingConv.CXCallingConv_AArch64SVEPCS;
alias CXCallingConv_Invalid = CXCallingConv.CXCallingConv_Invalid;
alias CXCallingConv_Unexposed = CXCallingConv.CXCallingConv_Unexposed;

/**
 * The type of an element in the abstract syntax tree.
 *
 */
struct CXType
{
    CXTypeKind kind;
    void*[2] data;
}

/**
 * Retrieve the type of a CXCursor (if any).
 */
CXType clang_getCursorType (in CXCursor C) pure;

/**
 * Pretty-print the underlying type using the rules of the
 * language of the translation unit from which it came.
 *
 * If the type is invalid, an empty string is returned.
 */
CXString clang_getTypeSpelling (in CXType CT);

/**
 * Retrieve the underlying type of a typedef declaration.
 *
 * If the cursor does not reference a typedef declaration, an invalid type is
 * returned.
 */
CXType clang_getTypedefDeclUnderlyingType (in CXCursor C) pure;

/**
 * Retrieve the integer type of an enum declaration.
 *
 * If the cursor does not reference an enum declaration, an invalid type is
 * returned.
 */
CXType clang_getEnumDeclIntegerType (in CXCursor C);

/**
 * Retrieve the integer value of an enum constant declaration as a signed
 *  long long.
 *
 * If the cursor does not reference an enum constant declaration, LLONG_MIN is
 * returned. Since this is also potentially a valid constant value, the kind of
 * the cursor must be verified before calling this function.
 */
long clang_getEnumConstantDeclValue (in CXCursor C) pure;

/**
 * Retrieve the integer value of an enum constant declaration as an unsigned
 *  long long.
 *
 * If the cursor does not reference an enum constant declaration, ULLONG_MAX is
 * returned. Since this is also potentially a valid constant value, the kind of
 * the cursor must be verified before calling this function.
 */
ulong clang_getEnumConstantDeclUnsignedValue (in CXCursor C);

/**
 * Retrieve the bit width of a bit field declaration as an integer.
 *
 * If a cursor that is not a bit field declaration is passed in, -1 is returned.
 */
int clang_getFieldDeclBitWidth (in CXCursor C) pure;

/**
 * Retrieve the number of non-variadic arguments associated with a given
 * cursor.
 *
 * The number of arguments can be determined for calls as well as for
 * declarations of functions or methods. For other cursors -1 is returned.
 */
int clang_Cursor_getNumArguments (in CXCursor C);

/**
 * Retrieve the argument cursor of a function or method.
 *
 * The argument cursor can be determined for calls as well as for declarations
 * of functions or methods. For other cursors and for invalid indices, an
 * invalid cursor is returned.
 */
CXCursor clang_Cursor_getArgument (in CXCursor C, uint i);

/**
 * Describes the kind of a template argument.
 *
 * See the definition of llvm::clang::TemplateArgument::ArgKind for full
 * element descriptions.
 */
enum CXTemplateArgumentKind
{
    CXTemplateArgumentKind_Null = 0,
    CXTemplateArgumentKind_Type = 1,
    CXTemplateArgumentKind_Declaration = 2,
    CXTemplateArgumentKind_NullPtr = 3,
    CXTemplateArgumentKind_Integral = 4,
    CXTemplateArgumentKind_Template = 5,
    CXTemplateArgumentKind_TemplateExpansion = 6,
    CXTemplateArgumentKind_Expression = 7,
    CXTemplateArgumentKind_Pack = 8,
    /* Indicates an error case, preventing the kind from being deduced. */
    CXTemplateArgumentKind_Invalid = 9
}

alias CXTemplateArgumentKind_Null = CXTemplateArgumentKind.CXTemplateArgumentKind_Null;
alias CXTemplateArgumentKind_Type = CXTemplateArgumentKind.CXTemplateArgumentKind_Type;
alias CXTemplateArgumentKind_Declaration = CXTemplateArgumentKind.CXTemplateArgumentKind_Declaration;
alias CXTemplateArgumentKind_NullPtr = CXTemplateArgumentKind.CXTemplateArgumentKind_NullPtr;
alias CXTemplateArgumentKind_Integral = CXTemplateArgumentKind.CXTemplateArgumentKind_Integral;
alias CXTemplateArgumentKind_Template = CXTemplateArgumentKind.CXTemplateArgumentKind_Template;
alias CXTemplateArgumentKind_TemplateExpansion = CXTemplateArgumentKind.CXTemplateArgumentKind_TemplateExpansion;
alias CXTemplateArgumentKind_Expression = CXTemplateArgumentKind.CXTemplateArgumentKind_Expression;
alias CXTemplateArgumentKind_Pack = CXTemplateArgumentKind.CXTemplateArgumentKind_Pack;
alias CXTemplateArgumentKind_Invalid = CXTemplateArgumentKind.CXTemplateArgumentKind_Invalid;

/**
 *Returns the number of template args of a function decl representing a
 * template specialization.
 *
 * If the argument cursor cannot be converted into a template function
 * declaration, -1 is returned.
 *
 * For example, for the following declaration and specialization:
 *   template <typename T, int kInt, bool kBool>
 *   void foo() { ... }
 *
 *   template <>
 *   void foo<float, -7, true>();
 *
 * The value 3 would be returned from this call.
 */
int clang_Cursor_getNumTemplateArguments (in CXCursor C) pure;

/**
 * Retrieve the kind of the I'th template argument of the CXCursor C.
 *
 * If the argument CXCursor does not represent a FunctionDecl, an invalid
 * template argument kind is returned.
 *
 * For example, for the following declaration and specialization:
 *   template <typename T, int kInt, bool kBool>
 *   void foo() { ... }
 *
 *   template <>
 *   void foo<float, -7, true>();
 *
 * For I = 0, 1, and 2, Type, Integral, and Integral will be returned,
 * respectively.
 */
CXTemplateArgumentKind clang_Cursor_getTemplateArgumentKind (
    CXCursor C,
    uint I) pure;

/**
 * Retrieve a CXType representing the type of a TemplateArgument of a
 *  function decl representing a template specialization.
 *
 * If the argument CXCursor does not represent a FunctionDecl whose I'th
 * template argument has a kind of CXTemplateArgKind_Integral, an invalid type
 * is returned.
 *
 * For example, for the following declaration and specialization:
 *   template <typename T, int kInt, bool kBool>
 *   void foo() { ... }
 *
 *   template <>
 *   void foo<float, -7, true>();
 *
 * If called with I = 0, "float", will be returned.
 * Invalid types will be returned for I == 1 or 2.
 */
CXType clang_Cursor_getTemplateArgumentType (in CXCursor C, uint I) pure;

/**
 * Retrieve the value of an Integral TemplateArgument (of a function
 *  decl representing a template specialization) as a signed long long.
 *
 * It is undefined to call this function on a CXCursor that does not represent a
 * FunctionDecl or whose I'th template argument is not an integral value.
 *
 * For example, for the following declaration and specialization:
 *   template <typename T, int kInt, bool kBool>
 *   void foo() { ... }
 *
 *   template <>
 *   void foo<float, -7, true>();
 *
 * If called with I = 1 or 2, -7 or true will be returned, respectively.
 * For I == 0, this function's behavior is undefined.
 */
long clang_Cursor_getTemplateArgumentValue (in CXCursor C, uint I) pure;

/**
 * Retrieve the value of an Integral TemplateArgument (of a function
 *  decl representing a template specialization) as an unsigned long long.
 *
 * It is undefined to call this function on a CXCursor that does not represent a
 * FunctionDecl or whose I'th template argument is not an integral value.
 *
 * For example, for the following declaration and specialization:
 *   template <typename T, int kInt, bool kBool>
 *   void foo() { ... }
 *
 *   template <>
 *   void foo<float, 2147483649, true>();
 *
 * If called with I = 1 or 2, 2147483649 or true will be returned, respectively.
 * For I == 0, this function's behavior is undefined.
 */
ulong clang_Cursor_getTemplateArgumentUnsignedValue (in CXCursor C, uint I);

/**
 * Determine whether two CXTypes represent the same type.
 *
 * \returns non-zero if the CXTypes represent the same type and
 *          zero otherwise.
 */
uint clang_equalTypes (in CXType A, in CXType B);

/**
 * Return the canonical type for a CXType.
 *
 * Clang's type system explicitly models typedefs and all the ways
 * a specific type can be represented.  The canonical type is the underlying
 * type with all the "sugar" removed.  For example, if 'T' is a typedef
 * for 'int', the canonical type for 'T' would be 'int'.
 */
CXType clang_getCanonicalType (in CXType T) pure;

/**
 * Determine whether a CXType has the "const" qualifier set,
 * without looking through typedefs that may have added "const" at a
 * different level.
 */
uint clang_isConstQualifiedType (in CXType T) pure;

/**
 * Determine whether a  CXCursor that is a macro, is
 * function like.
 */
uint clang_Cursor_isMacroFunctionLike (in CXCursor C) pure;

/**
 * Determine whether a  CXCursor that is a macro, is a
 * builtin one.
 */
uint clang_Cursor_isMacroBuiltin (in CXCursor C) pure;

/**
 * Determine whether a  CXCursor that is a function declaration, is an
 * inline declaration.
 */
uint clang_Cursor_isFunctionInlined (in CXCursor C);

/**
 * Determine whether a CXType has the "volatile" qualifier set,
 * without looking through typedefs that may have added "volatile" at
 * a different level.
 */
uint clang_isVolatileQualifiedType (in CXType T) pure;

/**
 * Determine whether a CXType has the "restrict" qualifier set,
 * without looking through typedefs that may have added "restrict" at a
 * different level.
 */
uint clang_isRestrictQualifiedType (in CXType T);

/**
 * Returns the address space of the given type.
 */
uint clang_getAddressSpace (in CXType T);

/**
 * Returns the typedef name of the given type.
 */
CXString clang_getTypedefName (in CXType CT);

/**
 * For pointer types, returns the type of the pointee.
 */
CXType clang_getPointeeType (in CXType T) pure;

/**
 * Return the cursor for the declaration of the given type.
 */
CXCursor clang_getTypeDeclaration (in CXType T) pure;

/**
 * Returns the Objective-C type encoding for the specified declaration.
 */
CXString clang_getDeclObjCTypeEncoding (in CXCursor C);

/**
 * Returns the Objective-C type encoding for the specified CXType.
 */
CXString clang_Type_getObjCEncoding (in CXType type);

/**
 * Retrieve the spelling of a given CXTypeKind.
 */
CXString clang_getTypeKindSpelling (in CXTypeKind K);

/**
 * Retrieve the calling convention associated with a function type.
 *
 * If a non-function type is passed in, CXCallingConv_Invalid is returned.
 */
CXCallingConv clang_getFunctionTypeCallingConv (in CXType T);

/**
 * Retrieve the return type associated with a function type.
 *
 * If a non-function type is passed in, an invalid type is returned.
 */
CXType clang_getResultType (in CXType T) pure;

/**
 * Retrieve the exception specification type associated with a function type.
 * This is a value of type CXCursor_ExceptionSpecificationKind.
 *
 * If a non-function type is passed in, an error code of -1 is returned.
 */
int clang_getExceptionSpecificationType (in CXType T);

/**
 * Retrieve the number of non-variadic parameters associated with a
 * function type.
 *
 * If a non-function type is passed in, -1 is returned.
 */
int clang_getNumArgTypes (in CXType T);

/**
 * Retrieve the type of a parameter of a function type.
 *
 * If a non-function type is passed in or the function does not have enough
 * parameters, an invalid type is returned.
 */
CXType clang_getArgType (in CXType T, uint i);

/**
 * Retrieves the base type of the ObjCObjectType.
 *
 * If the type is not an ObjC object, an invalid type is returned.
 */
CXType clang_Type_getObjCObjectBaseType (in CXType T);

/**
 * Retrieve the number of protocol references associated with an ObjC object/id.
 *
 * If the type is not an ObjC object, 0 is returned.
 */
uint clang_Type_getNumObjCProtocolRefs (in CXType T);

/**
 * Retrieve the decl for a protocol reference for an ObjC object/id.
 *
 * If the type is not an ObjC object or there are not enough protocol
 * references, an invalid cursor is returned.
 */
CXCursor clang_Type_getObjCProtocolDecl (in CXType T, uint i);

/**
 * Retrieve the number of type arguments associated with an ObjC object.
 *
 * If the type is not an ObjC object, 0 is returned.
 */
uint clang_Type_getNumObjCTypeArgs (in CXType T);

/**
 * Retrieve a type argument associated with an ObjC object.
 *
 * If the type is not an ObjC or the index is not valid,
 * an invalid type is returned.
 */
CXType clang_Type_getObjCTypeArg (in CXType T, uint i);

/**
 * Return 1 if the CXType is a variadic function type, and 0 otherwise.
 */
uint clang_isFunctionTypeVariadic (in CXType T) pure;

/**
 * Retrieve the return type associated with a given cursor.
 *
 * This only returns a valid type if the cursor refers to a function or method.
 */
CXType clang_getCursorResultType (in CXCursor C) pure;

/**
 * Retrieve the exception specification type associated with a given cursor.
 * This is a value of type CXCursor_ExceptionSpecificationKind.
 *
 * This only returns a valid result if the cursor refers to a function or
 * method.
 */
int clang_getCursorExceptionSpecificationType (in CXCursor C);

/**
 * Return 1 if the CXType is a POD (plain old data) type, and 0
 *  otherwise.
 */
uint clang_isPODType (in CXType T);

/**
 * Return the element type of an array, complex, or vector type.
 *
 * If a type is passed in that is not an array, complex, or vector type,
 * an invalid type is returned.
 */
CXType clang_getElementType (in CXType T) pure;

/**
 * Return the number of elements of an array or vector type.
 *
 * If a type is passed in that is not an array or vector type,
 * -1 is returned.
 */
long clang_getNumElements (in CXType T) pure;

/**
 * Return the element type of an array type.
 *
 * If a non-array type is passed in, an invalid type is returned.
 */
CXType clang_getArrayElementType (in CXType T);

/**
 * Return the array size of a constant array.
 *
 * If a non-array type is passed in, -1 is returned.
 */
long clang_getArraySize (in CXType T) pure;

/**
 * Retrieve the type named by the qualified-id.
 *
 * If a non-elaborated type is passed in, an invalid type is returned.
 */
CXType clang_Type_getNamedType (in CXType T) pure;

/**
 * Determine if a typedef is 'transparent' tag.
 *
 * A typedef is considered 'transparent' if it shares a name and spelling
 * location with its underlying tag type, as is the case with the NS_ENUM macro.
 *
 * \returns non-zero if transparent and zero otherwise.
 */
uint clang_Type_isTransparentTagTypedef (in CXType T);

enum CXTypeNullabilityKind
{
    /**
     * Values of this type can never be null.
     */
    CXTypeNullability_NonNull = 0,
    /**
     * Values of this type can be null.
     */
    CXTypeNullability_Nullable = 1,
    /**
     * Whether values of this type can be null is (explicitly)
     * unspecified. This captures a (fairly rare) case where we
     * can't conclude anything about the nullability of the type even
     * though it has been considered.
     */
    CXTypeNullability_Unspecified = 2,
    /**
     * Nullability is not applicable to this type.
     */
    CXTypeNullability_Invalid = 3,

    /**
     * Generally behaves like Nullable, except when used in a block parameter that
     * was imported into a swift async method. There, swift will assume that the
     * parameter can get null even if no error occurred. _Nullable parameters are
     * assumed to only get null on error.
     */
    CXTypeNullability_NullableResult = 4
}

alias CXTypeNullability_NonNull = CXTypeNullabilityKind.CXTypeNullability_NonNull;
alias CXTypeNullability_Nullable = CXTypeNullabilityKind.CXTypeNullability_Nullable;
alias CXTypeNullability_Unspecified = CXTypeNullabilityKind.CXTypeNullability_Unspecified;
alias CXTypeNullability_Invalid = CXTypeNullabilityKind.CXTypeNullability_Invalid;
alias CXTypeNullability_NullableResult = CXTypeNullabilityKind.CXTypeNullability_NullableResult;

/**
 * Retrieve the nullability kind of a pointer type.
 */
CXTypeNullabilityKind clang_Type_getNullability (in CXType T);

/**
 * List the possible error codes for \c clang_Type_getSizeOf,
 *   \c clang_Type_getAlignOf, \c clang_Type_getOffsetOf and
 *   \c clang_Cursor_getOffsetOf.
 *
 * A value of this enumeration type can be returned if the target type is not
 * a valid argument to sizeof, alignof or offsetof.
 */
enum CXTypeLayoutError
{
    /**
     * Type is of kind CXType_Invalid.
     */
    CXTypeLayoutError_Invalid = -1,
    /**
     * The type is an incomplete Type.
     */
    CXTypeLayoutError_Incomplete = -2,
    /**
     * The type is a dependent Type.
     */
    CXTypeLayoutError_Dependent = -3,
    /**
     * The type is not a constant size type.
     */
    CXTypeLayoutError_NotConstantSize = -4,
    /**
     * The Field name is not valid for this record.
     */
    CXTypeLayoutError_InvalidFieldName = -5,
    /**
     * The type is undeduced.
     */
    CXTypeLayoutError_Undeduced = -6
}

alias CXTypeLayoutError_Invalid = CXTypeLayoutError.CXTypeLayoutError_Invalid;
alias CXTypeLayoutError_Incomplete = CXTypeLayoutError.CXTypeLayoutError_Incomplete;
alias CXTypeLayoutError_Dependent = CXTypeLayoutError.CXTypeLayoutError_Dependent;
alias CXTypeLayoutError_NotConstantSize = CXTypeLayoutError.CXTypeLayoutError_NotConstantSize;
alias CXTypeLayoutError_InvalidFieldName = CXTypeLayoutError.CXTypeLayoutError_InvalidFieldName;
alias CXTypeLayoutError_Undeduced = CXTypeLayoutError.CXTypeLayoutError_Undeduced;

/**
 * Return the alignment of a type in bytes as per C++[expr.alignof]
 *   standard.
 *
 * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
 * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
 *   is returned.
 * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
 *   returned.
 * If the type declaration is not a constant size type,
 *   CXTypeLayoutError_NotConstantSize is returned.
 */
long clang_Type_getAlignOf (in CXType T);

/**
 * Return the class type of an member pointer type.
 *
 * If a non-member-pointer type is passed in, an invalid type is returned.
 */
CXType clang_Type_getClassType (in CXType T);

/**
 * Return the size of a type in bytes as per C++[expr.sizeof] standard.
 *
 * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
 * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
 *   is returned.
 * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
 *   returned.
 */
long clang_Type_getSizeOf (in CXType T);

/**
 * Return the offset of a field named S in a record of type T in bits
 *   as it would be returned by __offsetof__ as per C++11[18.2p4]
 *
 * If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
 *   is returned.
 * If the field's type declaration is an incomplete type,
 *   CXTypeLayoutError_Incomplete is returned.
 * If the field's type declaration is a dependent type,
 *   CXTypeLayoutError_Dependent is returned.
 * If the field's name S is not found,
 *   CXTypeLayoutError_InvalidFieldName is returned.
 */
long clang_Type_getOffsetOf (in CXType T, const(char)* S);

/**
 * Return the type that was modified by this attributed type.
 *
 * If the type is not an attributed type, an invalid type is returned.
 */
CXType clang_Type_getModifiedType (in CXType T);

/**
 * Gets the type contained by this atomic type.
 *
 * If a non-atomic type is passed in, an invalid type is returned.
 */
CXType clang_Type_getValueType (in CXType CT);

/**
 * Return the offset of the field represented by the Cursor.
 *
 * If the cursor is not a field declaration, -1 is returned.
 * If the cursor semantic parent is not a record field declaration,
 *   CXTypeLayoutError_Invalid is returned.
 * If the field's type declaration is an incomplete type,
 *   CXTypeLayoutError_Incomplete is returned.
 * If the field's type declaration is a dependent type,
 *   CXTypeLayoutError_Dependent is returned.
 * If the field's name S is not found,
 *   CXTypeLayoutError_InvalidFieldName is returned.
 */
long clang_Cursor_getOffsetOfField (in CXCursor C);

/**
 * Determine whether the given cursor represents an anonymous
 * tag or namespace
 */
uint clang_Cursor_isAnonymous (in CXCursor C) pure;

/**
 * Determine whether the given cursor represents an anonymous record
 * declaration.
 */
uint clang_Cursor_isAnonymousRecordDecl (in CXCursor C);

/**
 * Determine whether the given cursor represents an inline namespace
 * declaration.
 */
uint clang_Cursor_isInlineNamespace (in CXCursor C);

enum CXRefQualifierKind
{
    /** No ref-qualifier was provided. */
    CXRefQualifier_None = 0,
    /** An lvalue ref-qualifier was provided (\c &). */
    CXRefQualifier_LValue = 1,
    /** An rvalue ref-qualifier was provided (\c &&). */
    CXRefQualifier_RValue = 2
}

alias CXRefQualifier_None = CXRefQualifierKind.CXRefQualifier_None;
alias CXRefQualifier_LValue = CXRefQualifierKind.CXRefQualifier_LValue;
alias CXRefQualifier_RValue = CXRefQualifierKind.CXRefQualifier_RValue;

/**
 * Returns the number of template arguments for given template
 * specialization, or -1 if type \c T is not a template specialization.
 */
int clang_Type_getNumTemplateArguments (in CXType T);

/**
 * Returns the type template argument of a template class specialization
 * at given index.
 *
 * This function only returns template type arguments and does not handle
 * template template arguments or variadic packs.
 */
CXType clang_Type_getTemplateArgumentAsType (in CXType T, uint i);

/**
 * Retrieve the ref-qualifier kind of a function or method.
 *
 * The ref-qualifier is returned for C++ functions or methods. For other types
 * or non-C++ declarations, CXRefQualifier_None is returned.
 */
CXRefQualifierKind clang_Type_getCXXRefQualifier (in CXType T);

/**
 * Returns non-zero if the cursor specifies a Record member that is a
 *   bitfield.
 */
uint clang_Cursor_isBitField (in CXCursor C) pure;

/**
 * Returns 1 if the base class specified by the cursor with kind
 *   CX_CXXBaseSpecifier is virtual.
 */
uint clang_isVirtualBase (in CXCursor);

/**
 * Represents the C++ access control level to a base class for a
 * cursor with kind CX_CXXBaseSpecifier.
 */
enum CX_CXXAccessSpecifier
{
    CX_CXXInvalidAccessSpecifier = 0,
    CX_CXXPublic = 1,
    CX_CXXProtected = 2,
    CX_CXXPrivate = 3
}

alias CX_CXXInvalidAccessSpecifier = CX_CXXAccessSpecifier.CX_CXXInvalidAccessSpecifier;
alias CX_CXXPublic = CX_CXXAccessSpecifier.CX_CXXPublic;
alias CX_CXXProtected = CX_CXXAccessSpecifier.CX_CXXProtected;
alias CX_CXXPrivate = CX_CXXAccessSpecifier.CX_CXXPrivate;

/**
 * Returns the access control level for the referenced object.
 *
 * If the cursor refers to a C++ declaration, its access control level within
 * its parent scope is returned. Otherwise, if the cursor refers to a base
 * specifier or access specifier, the specifier itself is returned.
 */
CX_CXXAccessSpecifier clang_getCXXAccessSpecifier (in CXCursor) pure;

/**
 * Represents the storage classes as declared in the source. CX_SC_Invalid
 * was added for the case that the passed cursor in not a declaration.
 */
enum CX_StorageClass
{
    CX_SC_Invalid = 0,
    CX_SC_None = 1,
    CX_SC_Extern = 2,
    CX_SC_Static = 3,
    CX_SC_PrivateExtern = 4,
    CX_SC_OpenCLWorkGroupLocal = 5,
    CX_SC_Auto = 6,
    CX_SC_Register = 7
}

alias CX_SC_Invalid = CX_StorageClass.CX_SC_Invalid;
alias CX_SC_None = CX_StorageClass.CX_SC_None;
alias CX_SC_Extern = CX_StorageClass.CX_SC_Extern;
alias CX_SC_Static = CX_StorageClass.CX_SC_Static;
alias CX_SC_PrivateExtern = CX_StorageClass.CX_SC_PrivateExtern;
alias CX_SC_OpenCLWorkGroupLocal = CX_StorageClass.CX_SC_OpenCLWorkGroupLocal;
alias CX_SC_Auto = CX_StorageClass.CX_SC_Auto;
alias CX_SC_Register = CX_StorageClass.CX_SC_Register;

/**
 * Returns the storage class for a function or variable declaration.
 *
 * If the passed in Cursor is not a function or variable declaration,
 * CX_SC_Invalid is returned else the storage class.
 */
CX_StorageClass clang_Cursor_getStorageClass (in CXCursor) pure;

/**
 * Determine the number of overloaded declarations referenced by a
 * \c CXCursor_OverloadedDeclRef cursor.
 *
 * \param cursor The cursor whose overloaded declarations are being queried.
 *
 * \returns The number of overloaded declarations referenced by \c cursor. If it
 * is not a \c CXCursor_OverloadedDeclRef cursor, returns 0.
 */
uint clang_getNumOverloadedDecls (in CXCursor cursor) pure;

/**
 * Retrieve a cursor for one of the overloaded declarations referenced
 * by a \c CXCursor_OverloadedDeclRef cursor.
 *
 * \param cursor The cursor whose overloaded declarations are being queried.
 *
 * \param index The zero-based index into the set of overloaded declarations in
 * the cursor.
 *
 * \returns A cursor representing the declaration referenced by the given
 * \c cursor at the specified \c index. If the cursor does not have an
 * associated set of overloaded declarations, or if the index is out of bounds,
 * returns \c clang_getNullCursor();
 */
CXCursor clang_getOverloadedDecl (in CXCursor cursor, uint index);

/**
 * @}
 */

/**
 * \defgroup CINDEX_ATTRIBUTES Information for attributes
 *
 * @{
 */

/**
 * For cursors representing an iboutletcollection attribute,
 *  this function returns the collection element type.
 *
 */
CXType clang_getIBOutletCollectionType (in CXCursor);

/**
 * @}
 */

/**
 * \defgroup CINDEX_CURSOR_TRAVERSAL Traversing the AST with cursors
 *
 * These routines provide the ability to traverse the abstract syntax tree
 * using cursors.
 *
 * @{
 */

/**
 * Describes how the traversal of the children of a particular
 * cursor should proceed after visiting a particular child cursor.
 *
 * A value of this enumeration type should be returned by each
 * \c CXCursorVisitor to indicate how clang_visitChildren() proceed.
 */
enum CXChildVisitResult
{
    /**
     * Terminates the cursor traversal.
     */
    CXChildVisit_Break = 0,
    /**
     * Continues the cursor traversal with the next sibling of
     * the cursor just visited, without visiting its children.
     */
    CXChildVisit_Continue = 1,
    /**
     * Recursively traverse the children of this cursor, using
     * the same visitor and client data.
     */
    CXChildVisit_Recurse = 2
}

alias CXChildVisit_Break = CXChildVisitResult.CXChildVisit_Break;
alias CXChildVisit_Continue = CXChildVisitResult.CXChildVisit_Continue;
alias CXChildVisit_Recurse = CXChildVisitResult.CXChildVisit_Recurse;

/**
 * Visitor invoked for each cursor found by a traversal.
 *
 * This visitor block will be invoked for each cursor found by
 * clang_visitChildrenWithBlock(). Its first argument is the cursor being
 * visited, its second argument is the parent visitor for that cursor.
 *
 * The visitor should return one of the \c CXChildVisitResult values
 * to direct clang_visitChildrenWithBlock().
 */

/**
 * Visits the children of a cursor using the specified block.  Behaves
 * identically to clang_visitChildren() in all other respects.
 */

/**
 * @}
 */

/**
 * \defgroup CINDEX_CURSOR_XREF Cross-referencing in the AST
 *
 * These routines provide the ability to determine references within and
 * across translation units, by providing the names of the entities referenced
 * by cursors, follow reference cursors to the declarations they reference,
 * and associate declarations with their definitions.
 *
 * @{
 */

/**
 * Retrieve a Unified Symbol Resolution (USR) for the entity referenced
 * by the given cursor.
 *
 * A Unified Symbol Resolution (USR) is a string that identifies a particular
 * entity (function, class, variable, etc.) within a program. USRs can be
 * compared across translation units to determine, e.g., when references in
 * one translation refer to an entity defined in another translation unit.
 */
CXString clang_getCursorUSR (in CXCursor);

/**
 * Construct a USR for a specified Objective-C class.
 */
CXString clang_constructUSR_ObjCClass (const(char)* class_name);

/**
 * Construct a USR for a specified Objective-C category.
 */
CXString clang_constructUSR_ObjCCategory (
    const(char)* class_name,
    const(char)* category_name);

/**
 * Construct a USR for a specified Objective-C protocol.
 */
CXString clang_constructUSR_ObjCProtocol (const(char)* protocol_name);

/**
 * Construct a USR for a specified Objective-C instance variable and
 *   the USR for its containing class.
 */
CXString clang_constructUSR_ObjCIvar (const(char)* name, CXString classUSR);

/**
 * Construct a USR for a specified Objective-C method and
 *   the USR for its containing class.
 */
CXString clang_constructUSR_ObjCMethod (
    const(char)* name,
    uint isInstanceMethod,
    CXString classUSR);

/**
 * Construct a USR for a specified Objective-C property and the USR
 *  for its containing class.
 */
CXString clang_constructUSR_ObjCProperty (
    const(char)* property,
    CXString classUSR);

/**
 * Retrieve a name for the entity referenced by this cursor.
 */
CXString clang_getCursorSpelling (in CXCursor) pure;

/**
 * Retrieve a range for a piece that forms the cursors spelling name.
 * Most of the times there is only one range for the complete spelling but for
 * Objective-C methods and Objective-C message expressions, there are multiple
 * pieces for each selector identifier.
 *
 * \param pieceIndex the index of the spelling name piece. If this is greater
 * than the actual number of pieces, it will return a NULL (invalid) range.
 *
 * \param options Reserved.
 */
CXSourceRange clang_Cursor_getSpellingNameRange (
    CXCursor,
    uint pieceIndex,
    uint options);

/**
 * Opaque pointer representing a policy that controls pretty printing
 * for \c clang_getCursorPrettyPrinted.
 */
alias CXPrintingPolicy = void*;

/**
 * Properties for the printing policy.
 *
 * See \c clang::PrintingPolicy for more information.
 */
enum CXPrintingPolicyProperty
{
    CXPrintingPolicy_Indentation = 0,
    CXPrintingPolicy_SuppressSpecifiers = 1,
    CXPrintingPolicy_SuppressTagKeyword = 2,
    CXPrintingPolicy_IncludeTagDefinition = 3,
    CXPrintingPolicy_SuppressScope = 4,
    CXPrintingPolicy_SuppressUnwrittenScope = 5,
    CXPrintingPolicy_SuppressInitializers = 6,
    CXPrintingPolicy_ConstantArraySizeAsWritten = 7,
    CXPrintingPolicy_AnonymousTagLocations = 8,
    CXPrintingPolicy_SuppressStrongLifetime = 9,
    CXPrintingPolicy_SuppressLifetimeQualifiers = 10,
    CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors = 11,
    CXPrintingPolicy_Bool = 12,
    CXPrintingPolicy_Restrict = 13,
    CXPrintingPolicy_Alignof = 14,
    CXPrintingPolicy_UnderscoreAlignof = 15,
    CXPrintingPolicy_UseVoidForZeroParams = 16,
    CXPrintingPolicy_TerseOutput = 17,
    CXPrintingPolicy_PolishForDeclaration = 18,
    CXPrintingPolicy_Half = 19,
    CXPrintingPolicy_MSWChar = 20,
    CXPrintingPolicy_IncludeNewlines = 21,
    CXPrintingPolicy_MSVCFormatting = 22,
    CXPrintingPolicy_ConstantsAsWritten = 23,
    CXPrintingPolicy_SuppressImplicitBase = 24,
    CXPrintingPolicy_FullyQualifiedName = 25,

    CXPrintingPolicy_LastProperty = CXPrintingPolicy_FullyQualifiedName
}

alias CXPrintingPolicy_Indentation = CXPrintingPolicyProperty.CXPrintingPolicy_Indentation;
alias CXPrintingPolicy_SuppressSpecifiers = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressSpecifiers;
alias CXPrintingPolicy_SuppressTagKeyword = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressTagKeyword;
alias CXPrintingPolicy_IncludeTagDefinition = CXPrintingPolicyProperty.CXPrintingPolicy_IncludeTagDefinition;
alias CXPrintingPolicy_SuppressScope = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressScope;
alias CXPrintingPolicy_SuppressUnwrittenScope = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressUnwrittenScope;
alias CXPrintingPolicy_SuppressInitializers = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressInitializers;
alias CXPrintingPolicy_ConstantArraySizeAsWritten = CXPrintingPolicyProperty.CXPrintingPolicy_ConstantArraySizeAsWritten;
alias CXPrintingPolicy_AnonymousTagLocations = CXPrintingPolicyProperty.CXPrintingPolicy_AnonymousTagLocations;
alias CXPrintingPolicy_SuppressStrongLifetime = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressStrongLifetime;
alias CXPrintingPolicy_SuppressLifetimeQualifiers = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressLifetimeQualifiers;
alias CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors;
alias CXPrintingPolicy_Bool = CXPrintingPolicyProperty.CXPrintingPolicy_Bool;
alias CXPrintingPolicy_Restrict = CXPrintingPolicyProperty.CXPrintingPolicy_Restrict;
alias CXPrintingPolicy_Alignof = CXPrintingPolicyProperty.CXPrintingPolicy_Alignof;
alias CXPrintingPolicy_UnderscoreAlignof = CXPrintingPolicyProperty.CXPrintingPolicy_UnderscoreAlignof;
alias CXPrintingPolicy_UseVoidForZeroParams = CXPrintingPolicyProperty.CXPrintingPolicy_UseVoidForZeroParams;
alias CXPrintingPolicy_TerseOutput = CXPrintingPolicyProperty.CXPrintingPolicy_TerseOutput;
alias CXPrintingPolicy_PolishForDeclaration = CXPrintingPolicyProperty.CXPrintingPolicy_PolishForDeclaration;
alias CXPrintingPolicy_Half = CXPrintingPolicyProperty.CXPrintingPolicy_Half;
alias CXPrintingPolicy_MSWChar = CXPrintingPolicyProperty.CXPrintingPolicy_MSWChar;
alias CXPrintingPolicy_IncludeNewlines = CXPrintingPolicyProperty.CXPrintingPolicy_IncludeNewlines;
alias CXPrintingPolicy_MSVCFormatting = CXPrintingPolicyProperty.CXPrintingPolicy_MSVCFormatting;
alias CXPrintingPolicy_ConstantsAsWritten = CXPrintingPolicyProperty.CXPrintingPolicy_ConstantsAsWritten;
alias CXPrintingPolicy_SuppressImplicitBase = CXPrintingPolicyProperty.CXPrintingPolicy_SuppressImplicitBase;
alias CXPrintingPolicy_FullyQualifiedName = CXPrintingPolicyProperty.CXPrintingPolicy_FullyQualifiedName;
alias CXPrintingPolicy_LastProperty = CXPrintingPolicyProperty.CXPrintingPolicy_LastProperty;

/**
 * Get a property value for the given printing policy.
 */
uint clang_PrintingPolicy_getProperty (
    CXPrintingPolicy Policy,
    CXPrintingPolicyProperty Property);

/**
 * Set a property value for the given printing policy.
 */
void clang_PrintingPolicy_setProperty (
    CXPrintingPolicy Policy,
    CXPrintingPolicyProperty Property,
    uint Value);

/**
 * Retrieve the default policy for the cursor.
 *
 * The policy should be released after use with \c
 * clang_PrintingPolicy_dispose.
 */
CXPrintingPolicy clang_getCursorPrintingPolicy (in CXCursor);

/**
 * Release a printing policy.
 */
void clang_PrintingPolicy_dispose (in CXPrintingPolicy Policy);

/**
 * Pretty print declarations.
 *
 * \param Cursor The cursor representing a declaration.
 *
 * \param Policy The policy to control the entities being printed. If
 * NULL, a default policy is used.
 *
 * \returns The pretty printed declaration or the empty string for
 * other cursors.
 */
CXString clang_getCursorPrettyPrinted (
    CXCursor Cursor,
    CXPrintingPolicy Policy);

/**
 * Retrieve the display name for the entity referenced by this cursor.
 *
 * The display name contains extra information that helps identify the cursor,
 * such as the parameters of a function or template or the arguments of a
 * class template specialization.
 */
CXString clang_getCursorDisplayName (in CXCursor) pure;

/** For a cursor that is a reference, retrieve a cursor representing the
 * entity that it references.
 *
 * Reference cursors refer to other entities in the AST. For example, an
 * Objective-C superclass reference cursor refers to an Objective-C class.
 * This function produces the cursor for the Objective-C class from the
 * cursor for the superclass reference. If the input cursor is a declaration or
 * definition, it returns that declaration or definition unchanged.
 * Otherwise, returns the NULL cursor.
 */
CXCursor clang_getCursorReferenced (in CXCursor);

/**
 *  For a cursor that is either a reference to or a declaration
 *  of some entity, retrieve a cursor that describes the definition of
 *  that entity.
 *
 *  Some entities can be declared multiple times within a translation
 *  unit, but only one of those declarations can also be a
 *  definition. For example, given:
 *
 *  \code
 *  int f(int, int);
 *  int g(int x, int y) { return f(x, y); }
 *  int f(int a, int b) { return a + b; }
 *  int f(int, int);
 *  \endcode
 *
 *  there are three declarations of the function "f", but only the
 *  second one is a definition. The clang_getCursorDefinition()
 *  function will take any cursor pointing to a declaration of "f"
 *  (the first or fourth lines of the example) or a cursor referenced
 *  that uses "f" (the call to "f' inside "g") and will return a
 *  declaration cursor pointing to the definition (the second "f"
 *  declaration).
 *
 *  If given a cursor for which there is no corresponding definition,
 *  e.g., because there is no definition of that entity within this
 *  translation unit, returns a NULL cursor.
 */
CXCursor clang_getCursorDefinition (in CXCursor);

/**
 * Determine whether the declaration pointed to by this cursor
 * is also a definition of that entity.
 */
uint clang_isCursorDefinition (in CXCursor) pure;

/**
 * Retrieve the canonical cursor corresponding to the given cursor.
 *
 * In the C family of languages, many kinds of entities can be declared several
 * times within a single translation unit. For example, a structure type can
 * be forward-declared (possibly multiple times) and later defined:
 *
 * \code
 * struct X;
 * struct X;
 * struct X {
 *   int member;
 * };
 * \endcode
 *
 * The declarations and the definition of \c X are represented by three
 * different cursors, all of which are declarations of the same underlying
 * entity. One of these cursor is considered the "canonical" cursor, which
 * is effectively the representative for the underlying entity. One can
 * determine if two cursors are declarations of the same underlying entity by
 * comparing their canonical cursors.
 *
 * \returns The canonical cursor for the entity referred to by the given cursor.
 */
CXCursor clang_getCanonicalCursor (in CXCursor) pure;

/**
 * If the cursor points to a selector identifier in an Objective-C
 * method or message expression, this returns the selector index.
 *
 * After getting a cursor with #clang_getCursor, this can be called to
 * determine if the location points to a selector identifier.
 *
 * \returns The selector index if the cursor is an Objective-C method or message
 * expression and the cursor is pointing to a selector identifier, or -1
 * otherwise.
 */
int clang_Cursor_getObjCSelectorIndex (in CXCursor);

/**
 * Given a cursor pointing to a C++ method call or an Objective-C
 * message, returns non-zero if the method/message is "dynamic", meaning:
 *
 * For a C++ method: the call is virtual.
 * For an Objective-C message: the receiver is an object instance, not 'super'
 * or a specific class.
 *
 * If the method/message is "static" or the cursor does not point to a
 * method/message, it will return zero.
 */
int clang_Cursor_isDynamicCall (in CXCursor C);

/**
 * Given a cursor pointing to an Objective-C message or property
 * reference, or C++ method call, returns the CXType of the receiver.
 */
CXType clang_Cursor_getReceiverType (in CXCursor C);

/**
 * Property attributes for a \c CXCursor_ObjCPropertyDecl.
 */
enum CXObjCPropertyAttrKind
{
    CXObjCPropertyAttr_noattr = 0x00,
    CXObjCPropertyAttr_readonly = 0x01,
    CXObjCPropertyAttr_getter = 0x02,
    CXObjCPropertyAttr_assign = 0x04,
    CXObjCPropertyAttr_readwrite = 0x08,
    CXObjCPropertyAttr_retain = 0x10,
    CXObjCPropertyAttr_copy = 0x20,
    CXObjCPropertyAttr_nonatomic = 0x40,
    CXObjCPropertyAttr_setter = 0x80,
    CXObjCPropertyAttr_atomic = 0x100,
    CXObjCPropertyAttr_weak = 0x200,
    CXObjCPropertyAttr_strong = 0x400,
    CXObjCPropertyAttr_unsafe_unretained = 0x800,
    CXObjCPropertyAttr_class = 0x1000
}

mixin EnumC!CXObjCPropertyAttrKind;
// alias CXObjCPropertyAttr_noattr = .CXObjCPropertyAttr_noattr;
// alias CXObjCPropertyAttr_readonly = .CXObjCPropertyAttr_readonly;
// alias CXObjCPropertyAttr_getter = .CXObjCPropertyAttr_getter;
// alias CXObjCPropertyAttr_assign = .CXObjCPropertyAttr_assign;
// alias CXObjCPropertyAttr_readwrite = .CXObjCPropertyAttr_readwrite;
// alias CXObjCPropertyAttr_retain = .CXObjCPropertyAttr_retain;
// alias CXObjCPropertyAttr_copy = .CXObjCPropertyAttr_copy;
// alias CXObjCPropertyAttr_nonatomic = .CXObjCPropertyAttr_nonatomic;
// alias CXObjCPropertyAttr_setter = .CXObjCPropertyAttr_setter;
// alias CXObjCPropertyAttr_atomic = .CXObjCPropertyAttr_atomic;
// alias CXObjCPropertyAttr_weak = .CXObjCPropertyAttr_weak;
// alias CXObjCPropertyAttr_strong = .CXObjCPropertyAttr_strong;
// alias CXObjCPropertyAttr_unsafe_unretained = .CXObjCPropertyAttr_unsafe_unretained;
// alias CXObjCPropertyAttr_class = .CXObjCPropertyAttr_class;

/**
 * Given a cursor that represents a property declaration, return the
 * associated property attributes. The bits are formed from
 * \c CXObjCPropertyAttrKind.
 *
 * \param reserved Reserved for future use, pass 0.
 */
uint clang_Cursor_getObjCPropertyAttributes (in CXCursor C, uint reserved);

/**
 * Given a cursor that represents a property declaration, return the
 * name of the method that implements the getter.
 */
CXString clang_Cursor_getObjCPropertyGetterName (in CXCursor C);

/**
 * Given a cursor that represents a property declaration, return the
 * name of the method that implements the setter, if any.
 */
CXString clang_Cursor_getObjCPropertySetterName (in CXCursor C);

/**
 * 'Qualifiers' written next to the return and parameter types in
 * Objective-C method declarations.
 */
enum CXObjCDeclQualifierKind
{
    CXObjCDeclQualifier_None = 0x0,
    CXObjCDeclQualifier_In = 0x1,
    CXObjCDeclQualifier_Inout = 0x2,
    CXObjCDeclQualifier_Out = 0x4,
    CXObjCDeclQualifier_Bycopy = 0x8,
    CXObjCDeclQualifier_Byref = 0x10,
    CXObjCDeclQualifier_Oneway = 0x20
}
mixin EnumC!CXObjCDeclQualifierKind;

// alias CXObjCDeclQualifier_None = .CXObjCDeclQualifier_None;
// alias CXObjCDeclQualifier_In = .CXObjCDeclQualifier_In;
// alias CXObjCDeclQualifier_Inout = .CXObjCDeclQualifier_Inout;
// alias CXObjCDeclQualifier_Out = .CXObjCDeclQualifier_Out;
// alias CXObjCDeclQualifier_Bycopy = .CXObjCDeclQualifier_Bycopy;
// alias CXObjCDeclQualifier_Byref = .CXObjCDeclQualifier_Byref;
// alias CXObjCDeclQualifier_Oneway = .CXObjCDeclQualifier_Oneway;

/**
 * Given a cursor that represents an Objective-C method or parameter
 * declaration, return the associated Objective-C qualifiers for the return
 * type or the parameter respectively. The bits are formed from
 * CXObjCDeclQualifierKind.
 */
uint clang_Cursor_getObjCDeclQualifiers (in CXCursor C);

/**
 * Given a cursor that represents an Objective-C method or property
 * declaration, return non-zero if the declaration was affected by "\@optional".
 * Returns zero if the cursor is not such a declaration or it is "\@required".
 */
uint clang_Cursor_isObjCOptional (in CXCursor C);

/**
 * Returns non-zero if the given cursor is a variadic function or method.
 */
uint clang_Cursor_isVariadic (in CXCursor C);

/**
 * Returns non-zero if the given cursor points to a symbol marked with
 * external_source_symbol attribute.
 *
 * \param language If non-NULL, and the attribute is present, will be set to
 * the 'language' string from the attribute.
 *
 * \param definedIn If non-NULL, and the attribute is present, will be set to
 * the 'definedIn' string from the attribute.
 *
 * \param isGenerated If non-NULL, and the attribute is present, will be set to
 * non-zero if the 'generated_declaration' is set in the attribute.
 */
uint clang_Cursor_isExternalSymbol (
    CXCursor C,
    CXString* language,
    CXString* definedIn,
    uint* isGenerated);

/**
 * Given a cursor that represents a declaration, return the associated
 * comment's source range.  The range may include multiple consecutive comments
 * with whitespace in between.
 */
CXSourceRange clang_Cursor_getCommentRange (in CXCursor C);

/**
 * Given a cursor that represents a declaration, return the associated
 * comment text, including comment markers.
 */
CXString clang_Cursor_getRawCommentText (in CXCursor C) pure;

/**
 * Given a cursor that represents a documentable entity (e.g.,
 * declaration), return the associated \paragraph; otherwise return the
 * first paragraph.
 */
CXString clang_Cursor_getBriefCommentText (in CXCursor C);

/**
 * @}
 */

/** \defgroup CINDEX_MANGLE Name Mangling API Functions
 *
 * @{
 */

/**
 * Retrieve the CXString representing the mangled name of the cursor.
 */
CXString clang_Cursor_getMangling (in CXCursor) pure;

/**
 * Retrieve the CXStrings representing the mangled symbols of the C++
 * constructor or destructor at the cursor.
 */
CXStringSet* clang_Cursor_getCXXManglings (in CXCursor) pure;

/**
 * Retrieve the CXStrings representing the mangled symbols of the ObjC
 * class interface or implementation at the cursor.
 */
CXStringSet* clang_Cursor_getObjCManglings (in CXCursor);

/**
 * @}
 */

/**
 * \defgroup CINDEX_MODULE Module introspection
 *
 * The functions in this group provide access to information about modules.
 *
 * @{
 */

alias CXModule = void*;

/**
 * Given a CXCursor_ModuleImportDecl cursor, return the associated module.
 */
CXModule clang_Cursor_getModule (in CXCursor C);

/**
 * Given a CXFile header file, return the module that contains it, if one
 * exists.
 */
CXModule clang_getModuleForFile (in CXTranslationUnit, CXFile);

/**
 * \param Module a module object.
 *
 * \returns the module file where the provided module object came from.
 */
CXFile clang_Module_getASTFile (in CXModule Module);

/**
 * \param Module a module object.
 *
 * \returns the parent of a sub-module or NULL if the given module is top-level,
 * e.g. for 'std.vector' it will return the 'std' module.
 */
CXModule clang_Module_getParent (in CXModule Module);

/**
 * \param Module a module object.
 *
 * \returns the name of the module, e.g. for the 'std.vector' sub-module it
 * will return "vector".
 */
CXString clang_Module_getName (in CXModule Module);

/**
 * \param Module a module object.
 *
 * \returns the full name of the module, e.g. "std.vector".
 */
CXString clang_Module_getFullName (in CXModule Module);

/**
 * \param Module a module object.
 *
 * \returns non-zero if the module is a system one.
 */
int clang_Module_isSystem (in CXModule Module);

/**
 * \param Module a module object.
 *
 * \returns the number of top level headers associated with this module.
 */
uint clang_Module_getNumTopLevelHeaders (in CXTranslationUnit, CXModule Module);

/**
 * \param Module a module object.
 *
 * \param Index top level header index (zero-based).
 *
 * \returns the specified top level header associated with the module.
 */
CXFile clang_Module_getTopLevelHeader (
    CXTranslationUnit,
    CXModule Module,
    uint Index);

/**
 * @}
 */

/**
 * \defgroup CINDEX_CPP C++ AST introspection
 *
 * The routines in this group provide access information in the ASTs specific
 * to C++ language features.
 *
 * @{
 */

/**
 * Determine if a C++ constructor is a converting constructor.
 */
uint clang_CXXConstructor_isConvertingConstructor (in CXCursor C);

/**
 * Determine if a C++ constructor is a copy constructor.
 */
uint clang_CXXConstructor_isCopyConstructor (in CXCursor C) pure;

/**
 * Determine if a C++ constructor is the default constructor.
 */
uint clang_CXXConstructor_isDefaultConstructor (in CXCursor C);

/**
 * Determine if a C++ constructor is a move constructor.
 */
uint clang_CXXConstructor_isMoveConstructor (in CXCursor C) pure;

/**
 * Determine if a C++ field is declared 'mutable'.
 */
uint clang_CXXField_isMutable (in CXCursor C);

/**
 * Determine if a C++ method is declared '= default'.
 */
uint clang_CXXMethod_isDefaulted (in CXCursor C);

/**
 * Determine if a C++ member function or member function template is
 * pure virtual.
 */
uint clang_CXXMethod_isPureVirtual (in CXCursor C) pure;

/**
 * Determine if a C++ member function or member function template is
 * declared 'static'.
 */
uint clang_CXXMethod_isStatic (in CXCursor C);

/**
 * Determine if a C++ member function or member function template is
 * explicitly declared 'virtual' or if it overrides a virtual method from
 * one of the base classes.
 */
uint clang_CXXMethod_isVirtual (in CXCursor C) pure;

/**
 * Determine if a C++ record is abstract, i.e. whether a class or struct
 * has a pure virtual member function.
 */
uint clang_CXXRecord_isAbstract (in CXCursor C);

/**
 * Determine if an enum declaration refers to a scoped enum.
 */
uint clang_EnumDecl_isScoped (in CXCursor C);

/**
 * Determine if a C++ member function or member function template is
 * declared 'const'.
 */
uint clang_CXXMethod_isConst (in CXCursor C) pure;

/**
 * Given a cursor that represents a template, determine
 * the cursor kind of the specializations would be generated by instantiating
 * the template.
 *
 * This routine can be used to determine what flavor of function template,
 * class template, or class template partial specialization is stored in the
 * cursor. For example, it can describe whether a class template cursor is
 * declared with "struct", "class" or "union".
 *
 * \param C The cursor to query. This cursor should represent a template
 * declaration.
 *
 * \returns The cursor kind of the specializations that would be generated
 * by instantiating the template \p C. If \p C is not a template, returns
 * \c CXCursor_NoDeclFound.
 */
CXCursorKind clang_getTemplateCursorKind (in CXCursor C);

/**
 * Given a cursor that may represent a specialization or instantiation
 * of a template, retrieve the cursor that represents the template that it
 * specializes or from which it was instantiated.
 *
 * This routine determines the template involved both for explicit
 * specializations of templates and for implicit instantiations of the template,
 * both of which are referred to as "specializations". For a class template
 * specialization (e.g., \c std::vector<bool>), this routine will return
 * either the primary template (\c std::vector) or, if the specialization was
 * instantiated from a class template partial specialization, the class template
 * partial specialization. For a class template partial specialization and a
 * function template specialization (including instantiations), this
 * this routine will return the specialized template.
 *
 * For members of a class template (e.g., member functions, member classes, or
 * static data members), returns the specialized or instantiated member.
 * Although not strictly "templates" in the C++ language, members of class
 * templates have the same notions of specializations and instantiations that
 * templates do, so this routine treats them similarly.
 *
 * \param C A cursor that may be a specialization of a template or a member
 * of a template.
 *
 * \returns If the given cursor is a specialization or instantiation of a
 * template or a member thereof, the template or member that it specializes or
 * from which it was instantiated. Otherwise, returns a NULL cursor.
 */
CXCursor clang_getSpecializedCursorTemplate (in CXCursor C) pure;

/**
 * Given a cursor that references something else, return the source range
 * covering that reference.
 *
 * \param C A cursor pointing to a member reference, a declaration reference, or
 * an operator call.
 * \param NameFlags A bitset with three independent flags:
 * CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
 * CXNameRange_WantSinglePiece.
 * \param PieceIndex For contiguous names or when passing the flag
 * CXNameRange_WantSinglePiece, only one piece with index 0 is
 * available. When the CXNameRange_WantSinglePiece flag is not passed for a
 * non-contiguous names, this index can be used to retrieve the individual
 * pieces of the name. See also CXNameRange_WantSinglePiece.
 *
 * \returns The piece of the name pointed to by the given cursor. If there is no
 * name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
 */
CXSourceRange clang_getCursorReferenceNameRange (
    CXCursor C,
    uint NameFlags,
    uint PieceIndex);

enum CXNameRefFlags
{
    /**
     * Include the nested-name-specifier, e.g. Foo:: in x.Foo::y, in the
     * range.
     */
    CXNameRange_WantQualifier = 0x1,

    /**
     * Include the explicit template arguments, e.g. \<int> in x.f<int>,
     * in the range.
     */
    CXNameRange_WantTemplateArgs = 0x2,

    /**
     * If the name is non-contiguous, return the full spanning range.
     *
     * Non-contiguous names occur in Objective-C when a selector with two or more
     * parameters is used, or in C++ when using an operator:
     * \code
     * [object doSomething:here withValue:there]; // Objective-C
     * return some_vector[1]; // C++
     * \endcode
     */
    CXNameRange_WantSinglePiece = 0x4
}

alias CXNameRange_WantQualifier = CXNameRefFlags.CXNameRange_WantQualifier;
alias CXNameRange_WantTemplateArgs = CXNameRefFlags.CXNameRange_WantTemplateArgs;
alias CXNameRange_WantSinglePiece = CXNameRefFlags.CXNameRange_WantSinglePiece;

/**
 * @}
 */

/**
 * \defgroup CINDEX_LEX Token extraction and manipulation
 *
 * The routines in this group provide access to the tokens within a
 * translation unit, along with a semantic mapping of those tokens to
 * their corresponding cursors.
 *
 * @{
 */

/**
 * Describes a kind of token.
 */
enum CXTokenKind
{
    /**
     * A token that contains some kind of punctuation.
     */
    CXToken_Punctuation = 0,

    /**
     * A language keyword.
     */
    CXToken_Keyword = 1,

    /**
     * An identifier (that is not a keyword).
     */
    CXToken_Identifier = 2,

    /**
     * A numeric, string, or character literal.
     */
    CXToken_Literal = 3,

    /**
     * A comment.
     */
    CXToken_Comment = 4
}

alias CXToken_Punctuation = CXTokenKind.CXToken_Punctuation;
alias CXToken_Keyword = CXTokenKind.CXToken_Keyword;
alias CXToken_Identifier = CXTokenKind.CXToken_Identifier;
alias CXToken_Literal = CXTokenKind.CXToken_Literal;
alias CXToken_Comment = CXTokenKind.CXToken_Comment;

/**
 * Describes a single preprocessing token.
 */
struct CXToken
{
    uint[4] int_data;
    void* ptr_data;
}

/**
 * Get the raw lexical token starting with the given location.
 *
 * \param TU the translation unit whose text is being tokenized.
 *
 * \param Location the source location with which the token starts.
 *
 * \returns The token starting with the given location or NULL if no such token
 * exist. The returned pointer must be freed with clang_disposeTokens before the
 * translation unit is destroyed.
 */
CXToken* clang_getToken (in CXTranslationUnit TU, CXSourceLocation Location);

/**
 * Determine the kind of the given token.
 */
CXTokenKind clang_getTokenKind (in CXToken);

/**
 * Determine the spelling of the given token.
 *
 * The spelling of a token is the textual representation of that token, e.g.,
 * the text of an identifier or keyword.
 */
CXString clang_getTokenSpelling (in CXTranslationUnit, CXToken);

/**
 * Retrieve the source location of the given token.
 */
CXSourceLocation clang_getTokenLocation (in CXTranslationUnit, CXToken);

/**
 * Retrieve a source range that covers the given token.
 */
CXSourceRange clang_getTokenExtent (in CXTranslationUnit, CXToken);

/**
 * Tokenize the source code described by the given range into raw
 * lexical tokens.
 *
 * \param TU the translation unit whose text is being tokenized.
 *
 * \param Range the source range in which text should be tokenized. All of the
 * tokens produced by tokenization will fall within this source range,
 *
 * \param Tokens this pointer will be set to point to the array of tokens
 * that occur within the given source range. The returned pointer must be
 * freed with clang_disposeTokens() before the translation unit is destroyed.
 *
 * \param NumTokens will be set to the number of tokens in the \c *Tokens
 * array.
 *
 */
void clang_tokenize (
    CXTranslationUnit TU,
    CXSourceRange Range,
    CXToken** Tokens,
    uint* NumTokens);

/**
 * Annotate the given set of tokens by providing cursors for each token
 * that can be mapped to a specific entity within the abstract syntax tree.
 *
 * This token-annotation routine is equivalent to invoking
 * clang_getCursor() for the source locations of each of the
 * tokens. The cursors provided are filtered, so that only those
 * cursors that have a direct correspondence to the token are
 * accepted. For example, given a function call \c f(x),
 * clang_getCursor() would provide the following cursors:
 *
 *   * when the cursor is over the 'f', a DeclRefExpr cursor referring to 'f'.
 *   * when the cursor is over the '(' or the ')', a CallExpr referring to 'f'.
 *   * when the cursor is over the 'x', a DeclRefExpr cursor referring to 'x'.
 *
 * Only the first and last of these cursors will occur within the
 * annotate, since the tokens "f" and "x' directly refer to a function
 * and a variable, respectively, but the parentheses are just a small
 * part of the full syntax of the function call expression, which is
 * not provided as an annotation.
 *
 * \param TU the translation unit that owns the given tokens.
 *
 * \param Tokens the set of tokens to annotate.
 *
 * \param NumTokens the number of tokens in \p Tokens.
 *
 * \param Cursors an array of \p NumTokens cursors, whose contents will be
 * replaced with the cursors corresponding to each token.
 */
void clang_annotateTokens (
    CXTranslationUnit TU,
    CXToken* Tokens,
    uint NumTokens,
    CXCursor* Cursors);

/**
 * Free the given set of tokens.
 */
void clang_disposeTokens (
    CXTranslationUnit TU,
    CXToken* Tokens,
    uint NumTokens);

/**
 * @}
 */

/**
 * \defgroup CINDEX_DEBUG Debugging facilities
 *
 * These routines are used for testing and debugging, only, and should not
 * be relied upon.
 *
 * @{
 */

/* for debug/testing */
CXString clang_getCursorKindSpelling (in CXCursorKind Kind);
void clang_getDefinitionSpellingAndExtent (
    CXCursor,
    const(char*)* startBuf,
    const(char*)* endBuf,
    uint* startLine,
    uint* startColumn,
    uint* endLine,
    uint* endColumn);
void clang_enableStackTraces ();
void clang_executeOnThread (
    void function (void*) fn,
    void* user_data,
    uint stack_size);

/**
 * @}
 */

/**
 * \defgroup CINDEX_CODE_COMPLET Code completion
 *
 * Code completion involves taking an (incomplete) source file, along with
 * knowledge of where the user is actively editing that file, and suggesting
 * syntactically- and semantically-valid constructs that the user might want to
 * use at that particular point in the source code. These data structures and
 * routines provide support for code completion.
 *
 * @{
 */

/**
 * A semantic string that describes a code-completion result.
 *
 * A semantic string that describes the formatting of a code-completion
 * result as a single "template" of text that should be inserted into the
 * source buffer when a particular code-completion result is selected.
 * Each semantic string is made up of some number of "chunks", each of which
 * contains some text along with a description of what that text means, e.g.,
 * the name of the entity being referenced, whether the text chunk is part of
 * the template, or whether it is a "placeholder" that the user should replace
 * with actual code,of a specific kind. See \c CXCompletionChunkKind for a
 * description of the different kinds of chunks.
 */
alias CXCompletionString = void*;

/**
 * A single result of code completion.
 */
struct CXCompletionResult
{
    /**
     * The kind of entity that this completion refers to.
     *
     * The cursor kind will be a macro, keyword, or a declaration (one of the
     * *Decl cursor kinds), describing the entity that the completion is
     * referring to.
     *
     * \todo In the future, we would like to provide a full cursor, to allow
     * the client to extract additional information from declaration.
     */
    CXCursorKind CursorKind;

    /**
     * The code-completion string that describes how to insert this
     * code-completion result into the editing buffer.
     */
    CXCompletionString CompletionString;
}

/**
 * Describes a single piece of text within a code-completion string.
 *
 * Each "chunk" within a code-completion string (\c CXCompletionString) is
 * either a piece of text with a specific "kind" that describes how that text
 * should be interpreted by the client or is another completion string.
 */
enum CXCompletionChunkKind
{
    /**
     * A code-completion string that describes "optional" text that
     * could be a part of the template (but is not required).
     *
     * The Optional chunk is the only kind of chunk that has a code-completion
     * string for its representation, which is accessible via
     * \c clang_getCompletionChunkCompletionString(). The code-completion string
     * describes an additional part of the template that is completely optional.
     * For example, optional chunks can be used to describe the placeholders for
     * arguments that match up with defaulted function parameters, e.g. given:
     *
     * \code
     * void f(int x, float y = 3.14, double z = 2.71828);
     * \endcode
     *
     * The code-completion string for this function would contain:
     *   - a TypedText chunk for "f".
     *   - a LeftParen chunk for "(".
     *   - a Placeholder chunk for "int x"
     *   - an Optional chunk containing the remaining defaulted arguments, e.g.,
     *       - a Comma chunk for ","
     *       - a Placeholder chunk for "float y"
     *       - an Optional chunk containing the last defaulted argument:
     *           - a Comma chunk for ","
     *           - a Placeholder chunk for "double z"
     *   - a RightParen chunk for ")"
     *
     * There are many ways to handle Optional chunks. Two simple approaches are:
     *   - Completely ignore optional chunks, in which case the template for the
     *     function "f" would only include the first parameter ("int x").
     *   - Fully expand all optional chunks, in which case the template for the
     *     function "f" would have all of the parameters.
     */
    CXCompletionChunk_Optional = 0,
    /**
     * Text that a user would be expected to type to get this
     * code-completion result.
     *
     * There will be exactly one "typed text" chunk in a semantic string, which
     * will typically provide the spelling of a keyword or the name of a
     * declaration that could be used at the current code point. Clients are
     * expected to filter the code-completion results based on the text in this
     * chunk.
     */
    CXCompletionChunk_TypedText = 1,
    /**
     * Text that should be inserted as part of a code-completion result.
     *
     * A "text" chunk represents text that is part of the template to be
     * inserted into user code should this particular code-completion result
     * be selected.
     */
    CXCompletionChunk_Text = 2,
    /**
     * Placeholder text that should be replaced by the user.
     *
     * A "placeholder" chunk marks a place where the user should insert text
     * into the code-completion template. For example, placeholders might mark
     * the function parameters for a function declaration, to indicate that the
     * user should provide arguments for each of those parameters. The actual
     * text in a placeholder is a suggestion for the text to display before
     * the user replaces the placeholder with real code.
     */
    CXCompletionChunk_Placeholder = 3,
    /**
     * Informative text that should be displayed but never inserted as
     * part of the template.
     *
     * An "informative" chunk contains annotations that can be displayed to
     * help the user decide whether a particular code-completion result is the
     * right option, but which is not part of the actual template to be inserted
     * by code completion.
     */
    CXCompletionChunk_Informative = 4,
    /**
     * Text that describes the current parameter when code-completion is
     * referring to function call, message send, or template specialization.
     *
     * A "current parameter" chunk occurs when code-completion is providing
     * information about a parameter corresponding to the argument at the
     * code-completion point. For example, given a function
     *
     * \code
     * int add(int x, int y);
     * \endcode
     *
     * and the source code \c add(, where the code-completion point is after the
     * "(", the code-completion string will contain a "current parameter" chunk
     * for "int x", indicating that the current argument will initialize that
     * parameter. After typing further, to \c add(17, (where the code-completion
     * point is after the ","), the code-completion string will contain a
     * "current parameter" chunk to "int y".
     */
    CXCompletionChunk_CurrentParameter = 5,
    /**
     * A left parenthesis ('('), used to initiate a function call or
     * signal the beginning of a function parameter list.
     */
    CXCompletionChunk_LeftParen = 6,
    /**
     * A right parenthesis (')'), used to finish a function call or
     * signal the end of a function parameter list.
     */
    CXCompletionChunk_RightParen = 7,
    /**
     * A left bracket ('[').
     */
    CXCompletionChunk_LeftBracket = 8,
    /**
     * A right bracket (']').
     */
    CXCompletionChunk_RightBracket = 9,
    /**
     * A left brace ('{').
     */
    CXCompletionChunk_LeftBrace = 10,
    /**
     * A right brace ('}').
     */
    CXCompletionChunk_RightBrace = 11,
    /**
     * A left angle bracket ('<').
     */
    CXCompletionChunk_LeftAngle = 12,
    /**
     * A right angle bracket ('>').
     */
    CXCompletionChunk_RightAngle = 13,
    /**
     * A comma separator (',').
     */
    CXCompletionChunk_Comma = 14,
    /**
     * Text that specifies the result type of a given result.
     *
     * This special kind of informative chunk is not meant to be inserted into
     * the text buffer. Rather, it is meant to illustrate the type that an
     * expression using the given completion string would have.
     */
    CXCompletionChunk_ResultType = 15,
    /**
     * A colon (':').
     */
    CXCompletionChunk_Colon = 16,
    /**
     * A semicolon (';').
     */
    CXCompletionChunk_SemiColon = 17,
    /**
     * An '=' sign.
     */
    CXCompletionChunk_Equal = 18,
    /**
     * Horizontal space (' ').
     */
    CXCompletionChunk_HorizontalSpace = 19,
    /**
     * Vertical space ('\\n'), after which it is generally a good idea to
     * perform indentation.
     */
    CXCompletionChunk_VerticalSpace = 20
}

alias CXCompletionChunk_Optional = CXCompletionChunkKind.CXCompletionChunk_Optional;
alias CXCompletionChunk_TypedText = CXCompletionChunkKind.CXCompletionChunk_TypedText;
alias CXCompletionChunk_Text = CXCompletionChunkKind.CXCompletionChunk_Text;
alias CXCompletionChunk_Placeholder = CXCompletionChunkKind.CXCompletionChunk_Placeholder;
alias CXCompletionChunk_Informative = CXCompletionChunkKind.CXCompletionChunk_Informative;
alias CXCompletionChunk_CurrentParameter = CXCompletionChunkKind.CXCompletionChunk_CurrentParameter;
alias CXCompletionChunk_LeftParen = CXCompletionChunkKind.CXCompletionChunk_LeftParen;
alias CXCompletionChunk_RightParen = CXCompletionChunkKind.CXCompletionChunk_RightParen;
alias CXCompletionChunk_LeftBracket = CXCompletionChunkKind.CXCompletionChunk_LeftBracket;
alias CXCompletionChunk_RightBracket = CXCompletionChunkKind.CXCompletionChunk_RightBracket;
alias CXCompletionChunk_LeftBrace = CXCompletionChunkKind.CXCompletionChunk_LeftBrace;
alias CXCompletionChunk_RightBrace = CXCompletionChunkKind.CXCompletionChunk_RightBrace;
alias CXCompletionChunk_LeftAngle = CXCompletionChunkKind.CXCompletionChunk_LeftAngle;
alias CXCompletionChunk_RightAngle = CXCompletionChunkKind.CXCompletionChunk_RightAngle;
alias CXCompletionChunk_Comma = CXCompletionChunkKind.CXCompletionChunk_Comma;
alias CXCompletionChunk_ResultType = CXCompletionChunkKind.CXCompletionChunk_ResultType;
alias CXCompletionChunk_Colon = CXCompletionChunkKind.CXCompletionChunk_Colon;
alias CXCompletionChunk_SemiColon = CXCompletionChunkKind.CXCompletionChunk_SemiColon;
alias CXCompletionChunk_Equal = CXCompletionChunkKind.CXCompletionChunk_Equal;
alias CXCompletionChunk_HorizontalSpace = CXCompletionChunkKind.CXCompletionChunk_HorizontalSpace;
alias CXCompletionChunk_VerticalSpace = CXCompletionChunkKind.CXCompletionChunk_VerticalSpace;

/**
 * Determine the kind of a particular chunk within a completion string.
 *
 * \param completion_string the completion string to query.
 *
 * \param chunk_number the 0-based index of the chunk in the completion string.
 *
 * \returns the kind of the chunk at the index \c chunk_number.
 */
CXCompletionChunkKind clang_getCompletionChunkKind (
    CXCompletionString completion_string,
    uint chunk_number);

/**
 * Retrieve the text associated with a particular chunk within a
 * completion string.
 *
 * \param completion_string the completion string to query.
 *
 * \param chunk_number the 0-based index of the chunk in the completion string.
 *
 * \returns the text associated with the chunk at index \c chunk_number.
 */
CXString clang_getCompletionChunkText (
    CXCompletionString completion_string,
    uint chunk_number);

/**
 * Retrieve the completion string associated with a particular chunk
 * within a completion string.
 *
 * \param completion_string the completion string to query.
 *
 * \param chunk_number the 0-based index of the chunk in the completion string.
 *
 * \returns the completion string associated with the chunk at index
 * \c chunk_number.
 */
CXCompletionString clang_getCompletionChunkCompletionString (
    CXCompletionString completion_string,
    uint chunk_number);

/**
 * Retrieve the number of chunks in the given code-completion string.
 */
uint clang_getNumCompletionChunks (in CXCompletionString completion_string);

/**
 * Determine the priority of this code completion.
 *
 * The priority of a code completion indicates how likely it is that this
 * particular completion is the completion that the user will select. The
 * priority is selected by various internal heuristics.
 *
 * \param completion_string The completion string to query.
 *
 * \returns The priority of this completion string. Smaller values indicate
 * higher-priority (more likely) completions.
 */
uint clang_getCompletionPriority (in CXCompletionString completion_string);

/**
 * Determine the availability of the entity that this code-completion
 * string refers to.
 *
 * \param completion_string The completion string to query.
 *
 * \returns The availability of the completion string.
 */
CXAvailabilityKind clang_getCompletionAvailability (
    CXCompletionString completion_string);

/**
 * Retrieve the number of annotations associated with the given
 * completion string.
 *
 * \param completion_string the completion string to query.
 *
 * \returns the number of annotations associated with the given completion
 * string.
 */
uint clang_getCompletionNumAnnotations (in CXCompletionString completion_string);

/**
 * Retrieve the annotation associated with the given completion string.
 *
 * \param completion_string the completion string to query.
 *
 * \param annotation_number the 0-based index of the annotation of the
 * completion string.
 *
 * \returns annotation string associated with the completion at index
 * \c annotation_number, or a NULL string if that annotation is not available.
 */
CXString clang_getCompletionAnnotation (
    CXCompletionString completion_string,
    uint annotation_number);

/**
 * Retrieve the parent context of the given completion string.
 *
 * The parent context of a completion string is the semantic parent of
 * the declaration (if any) that the code completion represents. For example,
 * a code completion for an Objective-C method would have the method's class
 * or protocol as its context.
 *
 * \param completion_string The code completion string whose parent is
 * being queried.
 *
 * \param kind DEPRECATED: always set to CXCursor_NotImplemented if non-NULL.
 *
 * \returns The name of the completion parent, e.g., "NSObject" if
 * the completion string represents a method in the NSObject class.
 */
CXString clang_getCompletionParent (
    CXCompletionString completion_string,
    CXCursorKind* kind);

/**
 * Retrieve the brief documentation comment attached to the declaration
 * that corresponds to the given completion string.
 */
CXString clang_getCompletionBriefComment (in CXCompletionString completion_string);

/**
 * Retrieve a completion string for an arbitrary declaration or macro
 * definition cursor.
 *
 * \param cursor The cursor to query.
 *
 * \returns A non-context-sensitive completion string for declaration and macro
 * definition cursors, or NULL for other kinds of cursors.
 */
CXCompletionString clang_getCursorCompletionString (in CXCursor cursor);

/**
 * Contains the results of code-completion.
 *
 * This data structure contains the results of code completion, as
 * produced by \c clang_codeCompleteAt(). Its contents must be freed by
 * \c clang_disposeCodeCompleteResults.
 */
struct CXCodeCompleteResults
{
    /**
     * The code-completion results.
     */
    CXCompletionResult* Results;

    /**
     * The number of code-completion results stored in the
     * \c Results array.
     */
    uint NumResults;
}

/**
 * Retrieve the number of fix-its for the given completion index.
 *
 * Calling this makes sense only if CXCodeComplete_IncludeCompletionsWithFixIts
 * option was set.
 *
 * \param results The structure keeping all completion results
 *
 * \param completion_index The index of the completion
 *
 * \return The number of fix-its which must be applied before the completion at
 * completion_index can be applied
 */
uint clang_getCompletionNumFixIts (
    CXCodeCompleteResults* results,
    uint completion_index);

/**
 * Fix-its that *must* be applied before inserting the text for the
 * corresponding completion.
 *
 * By default, clang_codeCompleteAt() only returns completions with empty
 * fix-its. Extra completions with non-empty fix-its should be explicitly
 * requested by setting CXCodeComplete_IncludeCompletionsWithFixIts.
 *
 * For the clients to be able to compute position of the cursor after applying
 * fix-its, the following conditions are guaranteed to hold for
 * replacement_range of the stored fix-its:
 *  - Ranges in the fix-its are guaranteed to never contain the completion
 *  point (or identifier under completion point, if any) inside them, except
 *  at the start or at the end of the range.
 *  - If a fix-it range starts or ends with completion point (or starts or
 *  ends after the identifier under completion point), it will contain at
 *  least one character. It allows to unambiguously recompute completion
 *  point after applying the fix-it.
 *
 * The intuition is that provided fix-its change code around the identifier we
 * complete, but are not allowed to touch the identifier itself or the
 * completion point. One example of completions with corrections are the ones
 * replacing '.' with '->' and vice versa:
 *
 * std::unique_ptr<std::vector<int>> vec_ptr;
 * In 'vec_ptr.^', one of the completions is 'push_back', it requires
 * replacing '.' with '->'.
 * In 'vec_ptr->^', one of the completions is 'release', it requires
 * replacing '->' with '.'.
 *
 * \param results The structure keeping all completion results
 *
 * \param completion_index The index of the completion
 *
 * \param fixit_index The index of the fix-it for the completion at
 * completion_index
 *
 * \param replacement_range The fix-it range that must be replaced before the
 * completion at completion_index can be applied
 *
 * \returns The fix-it string that must replace the code at replacement_range
 * before the completion at completion_index can be applied
 */
CXString clang_getCompletionFixIt (
    CXCodeCompleteResults* results,
    uint completion_index,
    uint fixit_index,
    CXSourceRange* replacement_range);

/**
 * Flags that can be passed to \c clang_codeCompleteAt() to
 * modify its behavior.
 *
 * The enumerators in this enumeration can be bitwise-OR'd together to
 * provide multiple options to \c clang_codeCompleteAt().
 */
enum CXCodeComplete_Flags
{
    /**
     * Whether to include macros within the set of code
     * completions returned.
     */
    CXCodeComplete_IncludeMacros = 0x01,

    /**
     * Whether to include code patterns for language constructs
     * within the set of code completions, e.g., for loops.
     */
    CXCodeComplete_IncludeCodePatterns = 0x02,

    /**
     * Whether to include brief documentation within the set of code
     * completions returned.
     */
    CXCodeComplete_IncludeBriefComments = 0x04,

    /**
     * Whether to speed up completion by omitting top- or namespace-level entities
     * defined in the preamble. There's no guarantee any particular entity is
     * omitted. This may be useful if the headers are indexed externally.
     */
    CXCodeComplete_SkipPreamble = 0x08,

    /**
     * Whether to include completions with small
     * fix-its, e.g. change '.' to '->' on member access, etc.
     */
    CXCodeComplete_IncludeCompletionsWithFixIts = 0x10
}

alias CXCodeComplete_IncludeMacros = CXCodeComplete_Flags.CXCodeComplete_IncludeMacros;
alias CXCodeComplete_IncludeCodePatterns = CXCodeComplete_Flags.CXCodeComplete_IncludeCodePatterns;
alias CXCodeComplete_IncludeBriefComments = CXCodeComplete_Flags.CXCodeComplete_IncludeBriefComments;
alias CXCodeComplete_SkipPreamble = CXCodeComplete_Flags.CXCodeComplete_SkipPreamble;
alias CXCodeComplete_IncludeCompletionsWithFixIts = CXCodeComplete_Flags.CXCodeComplete_IncludeCompletionsWithFixIts;

/**
 * Bits that represent the context under which completion is occurring.
 *
 * The enumerators in this enumeration may be bitwise-OR'd together if multiple
 * contexts are occurring simultaneously.
 */
enum CXCompletionContext
{
    /**
     * The context for completions is unexposed, as only Clang results
     * should be included. (This is equivalent to having no context bits set.)
     */
    CXCompletionContext_Unexposed = 0,

    /**
     * Completions for any possible type should be included in the results.
     */
    CXCompletionContext_AnyType = 1 << 0,

    /**
     * Completions for any possible value (variables, function calls, etc.)
     * should be included in the results.
     */
    CXCompletionContext_AnyValue = 1 << 1,
    /**
     * Completions for values that resolve to an Objective-C object should
     * be included in the results.
     */
    CXCompletionContext_ObjCObjectValue = 1 << 2,
    /**
     * Completions for values that resolve to an Objective-C selector
     * should be included in the results.
     */
    CXCompletionContext_ObjCSelectorValue = 1 << 3,
    /**
     * Completions for values that resolve to a C++ class type should be
     * included in the results.
     */
    CXCompletionContext_CXXClassTypeValue = 1 << 4,

    /**
     * Completions for fields of the member being accessed using the dot
     * operator should be included in the results.
     */
    CXCompletionContext_DotMemberAccess = 1 << 5,
    /**
     * Completions for fields of the member being accessed using the arrow
     * operator should be included in the results.
     */
    CXCompletionContext_ArrowMemberAccess = 1 << 6,
    /**
     * Completions for properties of the Objective-C object being accessed
     * using the dot operator should be included in the results.
     */
    CXCompletionContext_ObjCPropertyAccess = 1 << 7,

    /**
     * Completions for enum tags should be included in the results.
     */
    CXCompletionContext_EnumTag = 1 << 8,
    /**
     * Completions for union tags should be included in the results.
     */
    CXCompletionContext_UnionTag = 1 << 9,
    /**
     * Completions for struct tags should be included in the results.
     */
    CXCompletionContext_StructTag = 1 << 10,

    /**
     * Completions for C++ class names should be included in the results.
     */
    CXCompletionContext_ClassTag = 1 << 11,
    /**
     * Completions for C++ namespaces and namespace aliases should be
     * included in the results.
     */
    CXCompletionContext_Namespace = 1 << 12,
    /**
     * Completions for C++ nested name specifiers should be included in
     * the results.
     */
    CXCompletionContext_NestedNameSpecifier = 1 << 13,

    /**
     * Completions for Objective-C interfaces (classes) should be included
     * in the results.
     */
    CXCompletionContext_ObjCInterface = 1 << 14,
    /**
     * Completions for Objective-C protocols should be included in
     * the results.
     */
    CXCompletionContext_ObjCProtocol = 1 << 15,
    /**
     * Completions for Objective-C categories should be included in
     * the results.
     */
    CXCompletionContext_ObjCCategory = 1 << 16,
    /**
     * Completions for Objective-C instance messages should be included
     * in the results.
     */
    CXCompletionContext_ObjCInstanceMessage = 1 << 17,
    /**
     * Completions for Objective-C class messages should be included in
     * the results.
     */
    CXCompletionContext_ObjCClassMessage = 1 << 18,
    /**
     * Completions for Objective-C selector names should be included in
     * the results.
     */
    CXCompletionContext_ObjCSelectorName = 1 << 19,

    /**
     * Completions for preprocessor macro names should be included in
     * the results.
     */
    CXCompletionContext_MacroName = 1 << 20,

    /**
     * Natural language completions should be included in the results.
     */
    CXCompletionContext_NaturalLanguage = 1 << 21,

    /**
     * #include file completions should be included in the results.
     */
    CXCompletionContext_IncludedFile = 1 << 22,

    /**
     * The current context is unknown, so set all contexts.
     */
    CXCompletionContext_Unknown = (1 << 23) - 1
}

alias CXCompletionContext_Unexposed = CXCompletionContext.CXCompletionContext_Unexposed;
alias CXCompletionContext_AnyType = CXCompletionContext.CXCompletionContext_AnyType;
alias CXCompletionContext_AnyValue = CXCompletionContext.CXCompletionContext_AnyValue;
alias CXCompletionContext_ObjCObjectValue = CXCompletionContext.CXCompletionContext_ObjCObjectValue;
alias CXCompletionContext_ObjCSelectorValue = CXCompletionContext.CXCompletionContext_ObjCSelectorValue;
alias CXCompletionContext_CXXClassTypeValue = CXCompletionContext.CXCompletionContext_CXXClassTypeValue;
alias CXCompletionContext_DotMemberAccess = CXCompletionContext.CXCompletionContext_DotMemberAccess;
alias CXCompletionContext_ArrowMemberAccess = CXCompletionContext.CXCompletionContext_ArrowMemberAccess;
alias CXCompletionContext_ObjCPropertyAccess = CXCompletionContext.CXCompletionContext_ObjCPropertyAccess;
alias CXCompletionContext_EnumTag = CXCompletionContext.CXCompletionContext_EnumTag;
alias CXCompletionContext_UnionTag = CXCompletionContext.CXCompletionContext_UnionTag;
alias CXCompletionContext_StructTag = CXCompletionContext.CXCompletionContext_StructTag;
alias CXCompletionContext_ClassTag = CXCompletionContext.CXCompletionContext_ClassTag;
alias CXCompletionContext_Namespace = CXCompletionContext.CXCompletionContext_Namespace;
alias CXCompletionContext_NestedNameSpecifier = CXCompletionContext.CXCompletionContext_NestedNameSpecifier;
alias CXCompletionContext_ObjCInterface = CXCompletionContext.CXCompletionContext_ObjCInterface;
alias CXCompletionContext_ObjCProtocol = CXCompletionContext.CXCompletionContext_ObjCProtocol;
alias CXCompletionContext_ObjCCategory = CXCompletionContext.CXCompletionContext_ObjCCategory;
alias CXCompletionContext_ObjCInstanceMessage = CXCompletionContext.CXCompletionContext_ObjCInstanceMessage;
alias CXCompletionContext_ObjCClassMessage = CXCompletionContext.CXCompletionContext_ObjCClassMessage;
alias CXCompletionContext_ObjCSelectorName = CXCompletionContext.CXCompletionContext_ObjCSelectorName;
alias CXCompletionContext_MacroName = CXCompletionContext.CXCompletionContext_MacroName;
alias CXCompletionContext_NaturalLanguage = CXCompletionContext.CXCompletionContext_NaturalLanguage;
alias CXCompletionContext_IncludedFile = CXCompletionContext.CXCompletionContext_IncludedFile;
alias CXCompletionContext_Unknown = CXCompletionContext.CXCompletionContext_Unknown;

/**
 * Returns a default set of code-completion options that can be
 * passed to\c clang_codeCompleteAt().
 */
uint clang_defaultCodeCompleteOptions ();

/**
 * Perform code completion at a given location in a translation unit.
 *
 * This function performs code completion at a particular file, line, and
 * column within source code, providing results that suggest potential
 * code snippets based on the context of the completion. The basic model
 * for code completion is that Clang will parse a complete source file,
 * performing syntax checking up to the location where code-completion has
 * been requested. At that point, a special code-completion token is passed
 * to the parser, which recognizes this token and determines, based on the
 * current location in the C/Objective-C/C++ grammar and the state of
 * semantic analysis, what completions to provide. These completions are
 * returned via a new \c CXCodeCompleteResults structure.
 *
 * Code completion itself is meant to be triggered by the client when the
 * user types punctuation characters or whitespace, at which point the
 * code-completion location will coincide with the cursor. For example, if \c p
 * is a pointer, code-completion might be triggered after the "-" and then
 * after the ">" in \c p->. When the code-completion location is after the ">",
 * the completion results will provide, e.g., the members of the struct that
 * "p" points to. The client is responsible for placing the cursor at the
 * beginning of the token currently being typed, then filtering the results
 * based on the contents of the token. For example, when code-completing for
 * the expression \c p->get, the client should provide the location just after
 * the ">" (e.g., pointing at the "g") to this code-completion hook. Then, the
 * client can filter the results based on the current token text ("get"), only
 * showing those results that start with "get". The intent of this interface
 * is to separate the relatively high-latency acquisition of code-completion
 * results from the filtering of results on a per-character basis, which must
 * have a lower latency.
 *
 * \param TU The translation unit in which code-completion should
 * occur. The source files for this translation unit need not be
 * completely up-to-date (and the contents of those source files may
 * be overridden via \p unsaved_files). Cursors referring into the
 * translation unit may be invalidated by this invocation.
 *
 * \param complete_filename The name of the source file where code
 * completion should be performed. This filename may be any file
 * included in the translation unit.
 *
 * \param complete_line The line at which code-completion should occur.
 *
 * \param complete_column The column at which code-completion should occur.
 * Note that the column should point just after the syntactic construct that
 * initiated code completion, and not in the middle of a lexical token.
 *
 * \param unsaved_files the Files that have not yet been saved to disk
 * but may be required for parsing or code completion, including the
 * contents of those files.  The contents and name of these files (as
 * specified by CXUnsavedFile) are copied when necessary, so the
 * client only needs to guarantee their validity until the call to
 * this function returns.
 *
 * \param num_unsaved_files The number of unsaved file entries in \p
 * unsaved_files.
 *
 * \param options Extra options that control the behavior of code
 * completion, expressed as a bitwise OR of the enumerators of the
 * CXCodeComplete_Flags enumeration. The
 * \c clang_defaultCodeCompleteOptions() function returns a default set
 * of code-completion options.
 *
 * \returns If successful, a new \c CXCodeCompleteResults structure
 * containing code-completion results, which should eventually be
 * freed with \c clang_disposeCodeCompleteResults(). If code
 * completion fails, returns NULL.
 */
CXCodeCompleteResults* clang_codeCompleteAt (
    CXTranslationUnit TU,
    const(char)* complete_filename,
    uint complete_line,
    uint complete_column,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    uint options);

/**
 * Sort the code-completion results in case-insensitive alphabetical
 * order.
 *
 * \param Results The set of results to sort.
 * \param NumResults The number of results in \p Results.
 */
void clang_sortCodeCompletionResults (
    CXCompletionResult* Results,
    uint NumResults);

/**
 * Free the given set of code-completion results.
 */
void clang_disposeCodeCompleteResults (in CXCodeCompleteResults* Results);

/**
 * Determine the number of diagnostics produced prior to the
 * location where code completion was performed.
 */
uint clang_codeCompleteGetNumDiagnostics (in CXCodeCompleteResults* Results);

/**
 * Retrieve a diagnostic associated with the given code completion.
 *
 * \param Results the code completion results to query.
 * \param Index the zero-based diagnostic number to retrieve.
 *
 * \returns the requested diagnostic. This diagnostic must be freed
 * via a call to \c clang_disposeDiagnostic().
 */
CXDiagnostic clang_codeCompleteGetDiagnostic (
    CXCodeCompleteResults* Results,
    uint Index);

/**
 * Determines what completions are appropriate for the context
 * the given code completion.
 *
 * \param Results the code completion results to query
 *
 * \returns the kinds of completions that are appropriate for use
 * along with the given code completion results.
 */
ulong clang_codeCompleteGetContexts (in CXCodeCompleteResults* Results);

/**
 * Returns the cursor kind for the container for the current code
 * completion context. The container is only guaranteed to be set for
 * contexts where a container exists (i.e. member accesses or Objective-C
 * message sends); if there is not a container, this function will return
 * CXCursor_InvalidCode.
 *
 * \param Results the code completion results to query
 *
 * \param IsIncomplete on return, this value will be false if Clang has complete
 * information about the container. If Clang does not have complete
 * information, this value will be true.
 *
 * \returns the container kind, or CXCursor_InvalidCode if there is not a
 * container
 */
CXCursorKind clang_codeCompleteGetContainerKind (
    CXCodeCompleteResults* Results,
    uint* IsIncomplete);

/**
 * Returns the USR for the container for the current code completion
 * context. If there is not a container for the current context, this
 * function will return the empty string.
 *
 * \param Results the code completion results to query
 *
 * \returns the USR for the container
 */
CXString clang_codeCompleteGetContainerUSR (in CXCodeCompleteResults* Results);

/**
 * Returns the currently-entered selector for an Objective-C message
 * send, formatted like "initWithFoo:bar:". Only guaranteed to return a
 * non-empty string for CXCompletionContext_ObjCInstanceMessage and
 * CXCompletionContext_ObjCClassMessage.
 *
 * \param Results the code completion results to query
 *
 * \returns the selector (or partial selector) that has been entered thus far
 * for an Objective-C message send.
 */
CXString clang_codeCompleteGetObjCSelector (in CXCodeCompleteResults* Results);

/**
 * @}
 */

/**
 * \defgroup CINDEX_MISC Miscellaneous utility functions
 *
 * @{
 */

/**
 * Return a version string, suitable for showing to a user, but not
 *        intended to be parsed (the format is not guaranteed to be stable).
 */
CXString clang_getClangVersion ();

/**
 * Enable/disable crash recovery.
 *
 * \param isEnabled Flag to indicate if crash recovery is enabled.  A non-zero
 *        value enables crash recovery, while 0 disables it.
 */
void clang_toggleCrashRecovery (uint isEnabled);

/**
 * Visitor invoked for each file in a translation unit
 *        (used with clang_getInclusions()).
 *
 * This visitor function will be invoked by clang_getInclusions() for each
 * file included (either at the top-level or by \#include directives) within
 * a translation unit.  The first argument is the file being included, and
 * the second and third arguments provide the inclusion stack.  The
 * array is sorted in order of immediate inclusion.  For example,
 * the first element refers to the location that included 'included_file'.
 */
alias CXInclusionVisitor = void function (
    CXFile included_file,
    CXSourceLocation* inclusion_stack,
    uint include_len,
    CXClientData client_data);

/**
 * Visit the set of preprocessor inclusions in a translation unit.
 *   The visitor function is called with the provided data for every included
 *   file.  This does not include headers included by the PCH file (unless one
 *   is inspecting the inclusions in the PCH file itself).
 */
void clang_getInclusions (
    CXTranslationUnit tu,
    CXInclusionVisitor visitor,
    CXClientData client_data);

enum CXEvalResultKind
{
    CXEval_Int = 1,
    CXEval_Float = 2,
    CXEval_ObjCStrLiteral = 3,
    CXEval_StrLiteral = 4,
    CXEval_CFStr = 5,
    CXEval_Other = 6,

    CXEval_UnExposed = 0
}

mixin EnumC!CXEvalResultKind;
// alias CXEval_Int = .CXEval_Int;
// alias CXEval_Float = .CXEval_Float;
// alias CXEval_ObjCStrLiteral = .CXEval_ObjCStrLiteral;
// alias CXEval_StrLiteral = .CXEval_StrLiteral;
// alias CXEval_CFStr = .CXEval_CFStr;
// alias CXEval_Other = .CXEval_Other;
// alias CXEval_UnExposed = .CXEval_UnExposed;

/**
 * Evaluation result of a cursor
 */
alias CXEvalResult = void*;

/**
 * If cursor is a statement declaration tries to evaluate the
 * statement and if its variable, tries to evaluate its initializer,
 * into its corresponding type.
 * If it's an expression, tries to evaluate the expression.
 */
CXEvalResult clang_Cursor_Evaluate (in CXCursor C);

/**
 * Returns the kind of the evaluated result.
 */
CXEvalResultKind clang_EvalResult_getKind (in CXEvalResult E);

/**
 * Returns the evaluation result as integer if the
 * kind is Int.
 */
int clang_EvalResult_getAsInt (in CXEvalResult E);

/**
 * Returns the evaluation result as a long long integer if the
 * kind is Int. This prevents overflows that may happen if the result is
 * returned with clang_EvalResult_getAsInt.
 */
long clang_EvalResult_getAsLongLong (in CXEvalResult E);

/**
 * Returns a non-zero value if the kind is Int and the evaluation
 * result resulted in an unsigned integer.
 */
uint clang_EvalResult_isUnsignedInt (in CXEvalResult E);

/**
 * Returns the evaluation result as an unsigned integer if
 * the kind is Int and clang_EvalResult_isUnsignedInt is non-zero.
 */
ulong clang_EvalResult_getAsUnsigned (in CXEvalResult E);

/**
 * Returns the evaluation result as double if the
 * kind is double.
 */
double clang_EvalResult_getAsDouble (in CXEvalResult E);

/**
 * Returns the evaluation result as a constant string if the
 * kind is other than Int or float. User must not free this pointer,
 * instead call clang_EvalResult_dispose on the CXEvalResult returned
 * by clang_Cursor_Evaluate.
 */
const(char)* clang_EvalResult_getAsStr (in CXEvalResult E);

/**
 * Disposes the created Eval memory.
 */
void clang_EvalResult_dispose (in CXEvalResult E);
/**
 * @}
 */

/** \defgroup CINDEX_REMAPPING Remapping functions
 *
 * @{
 */

/**
 * A remapping of original source files and their translated files.
 */
alias CXRemapping = void*;

/**
 * Retrieve a remapping.
 *
 * \param path the path that contains metadata about remappings.
 *
 * \returns the requested remapping. This remapping must be freed
 * via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
 */
CXRemapping clang_getRemappings (const(char)* path);

/**
 * Retrieve a remapping.
 *
 * \param filePaths pointer to an array of file paths containing remapping info.
 *
 * \param numFiles number of file paths.
 *
 * \returns the requested remapping. This remapping must be freed
 * via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
 */
CXRemapping clang_getRemappingsFromFileList (
    const(char*)* filePaths,
    uint numFiles);

/**
 * Determine the number of remappings.
 */
uint clang_remap_getNumFiles (in CXRemapping);

/**
 * Get the original and the associated filename from the remapping.
 *
 * \param original If non-NULL, will be set to the original filename.
 *
 * \param transformed If non-NULL, will be set to the filename that the original
 * is associated with.
 */
void clang_remap_getFilenames (
    CXRemapping,
    uint index,
    CXString* original,
    CXString* transformed);

/**
 * Dispose the remapping.
 */
void clang_remap_dispose (in CXRemapping);

/**
 * @}
 */

/** \defgroup CINDEX_HIGH Higher level API functions
 *
 * @{
 */

enum CXVisitorResult
{
    CXVisit_Break = 0,
    CXVisit_Continue = 1
}

alias CXVisit_Break = CXVisitorResult.CXVisit_Break;
alias CXVisit_Continue = CXVisitorResult.CXVisit_Continue;

struct CXCursorAndRangeVisitor
{
    void* context;
    CXVisitorResult function (void* context, CXCursor, CXSourceRange) visit;
}

enum CXResult
{
    /**
     * Function returned successfully.
     */
    CXResult_Success = 0,
    /**
     * One of the parameters was invalid for the function.
     */
    CXResult_Invalid = 1,
    /**
     * The function was terminated by a callback (e.g. it returned
     * CXVisit_Break)
     */
    CXResult_VisitBreak = 2
}

mixin EnumC!CXResult;
// alias CXResult_Success = .CXResult_Success;
// alias CXResult_Invalid = .CXResult_Invalid;
// alias CXResult_VisitBreak = .CXResult_VisitBreak;

/**
 * Find references of a declaration in a specific file.
 *
 * \param cursor pointing to a declaration or a reference of one.
 *
 * \param file to search for references.
 *
 * \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
 * each reference found.
 * The CXSourceRange will point inside the file; if the reference is inside
 * a macro (and not a macro argument) the CXSourceRange will be invalid.
 *
 * \returns one of the CXResult enumerators.
 */
CXResult clang_findReferencesInFile (
    CXCursor cursor,
    CXFile file,
    CXCursorAndRangeVisitor visitor);

/**
 * Find #import/#include directives in a specific file.
 *
 * \param TU translation unit containing the file to query.
 *
 * \param file to search for #import/#include directives.
 *
 * \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
 * each directive found.
 *
 * \returns one of the CXResult enumerators.
 */
CXResult clang_findIncludesInFile (
    CXTranslationUnit TU,
    CXFile file,
    CXCursorAndRangeVisitor visitor);

/**
 * The client's data object that is associated with a CXFile.
 */
alias CXIdxClientFile = void*;

/**
 * The client's data object that is associated with a semantic entity.
 */
alias CXIdxClientEntity = void*;

/**
 * The client's data object that is associated with a semantic container
 * of entities.
 */
alias CXIdxClientContainer = void*;

/**
 * The client's data object that is associated with an AST file (PCH
 * or module).
 */
alias CXIdxClientASTFile = void*;

/**
 * Source location passed to index callbacks.
 */
struct CXIdxLoc
{
    void*[2] ptr_data;
    uint int_data;
}

/**
 * Data for ppIncludedFile callback.
 */
struct CXIdxIncludedFileInfo
{
    /**
     * Location of '#' in the \#include/\#import directive.
     */
    CXIdxLoc hashLoc;
    /**
     * Filename as written in the \#include/\#import directive.
     */
    const(char)* filename;
    /**
     * The actual file that the \#include/\#import directive resolved to.
     */
    CXFile file;
    int isImport;
    int isAngled;
    /**
     * Non-zero if the directive was automatically turned into a module
     * import.
     */
    int isModuleImport;
}

/**
 * Data for IndexerCallbacks#importedASTFile.
 */
struct CXIdxImportedASTFileInfo
{
    /**
     * Top level AST file containing the imported PCH, module or submodule.
     */
    CXFile file;
    /**
     * The imported module or NULL if the AST file is a PCH.
     */
    CXModule module_;
    /**
     * Location where the file is imported. Applicable only for modules.
     */
    CXIdxLoc loc;
    /**
     * Non-zero if an inclusion directive was automatically turned into
     * a module import. Applicable only for modules.
     */
    int isImplicit;
}

enum CXIdxEntityKind
{
    CXIdxEntity_Unexposed = 0,
    CXIdxEntity_Typedef = 1,
    CXIdxEntity_Function = 2,
    CXIdxEntity_Variable = 3,
    CXIdxEntity_Field = 4,
    CXIdxEntity_EnumConstant = 5,

    CXIdxEntity_ObjCClass = 6,
    CXIdxEntity_ObjCProtocol = 7,
    CXIdxEntity_ObjCCategory = 8,

    CXIdxEntity_ObjCInstanceMethod = 9,
    CXIdxEntity_ObjCClassMethod = 10,
    CXIdxEntity_ObjCProperty = 11,
    CXIdxEntity_ObjCIvar = 12,

    CXIdxEntity_Enum = 13,
    CXIdxEntity_Struct = 14,
    CXIdxEntity_Union = 15,

    CXIdxEntity_CXXClass = 16,
    CXIdxEntity_CXXNamespace = 17,
    CXIdxEntity_CXXNamespaceAlias = 18,
    CXIdxEntity_CXXStaticVariable = 19,
    CXIdxEntity_CXXStaticMethod = 20,
    CXIdxEntity_CXXInstanceMethod = 21,
    CXIdxEntity_CXXConstructor = 22,
    CXIdxEntity_CXXDestructor = 23,
    CXIdxEntity_CXXConversionFunction = 24,
    CXIdxEntity_CXXTypeAlias = 25,
    CXIdxEntity_CXXInterface = 26,
    CXIdxEntity_CXXConcept = 27
}

mixin EnumC!CXIdxEntityKind;
// alias CXIdxEntity_Unexposed = .CXIdxEntity_Unexposed;
// alias CXIdxEntity_Typedef = .CXIdxEntity_Typedef;
// alias CXIdxEntity_Function = .CXIdxEntity_Function;
// alias CXIdxEntity_Variable = .CXIdxEntity_Variable;
// alias CXIdxEntity_Field = .CXIdxEntity_Field;
// alias CXIdxEntity_EnumConstant = .CXIdxEntity_EnumConstant;
// alias CXIdxEntity_ObjCClass = .CXIdxEntity_ObjCClass;
// alias CXIdxEntity_ObjCProtocol = .CXIdxEntity_ObjCProtocol;
// alias CXIdxEntity_ObjCCategory = .CXIdxEntity_ObjCCategory;
// alias CXIdxEntity_ObjCInstanceMethod = .CXIdxEntity_ObjCInstanceMethod;
// alias CXIdxEntity_ObjCClassMethod = .CXIdxEntity_ObjCClassMethod;
// alias CXIdxEntity_ObjCProperty = .CXIdxEntity_ObjCProperty;
// alias CXIdxEntity_ObjCIvar = .CXIdxEntity_ObjCIvar;
// alias CXIdxEntity_Enum = .CXIdxEntity_Enum;
// alias CXIdxEntity_Struct = .CXIdxEntity_Struct;
// alias CXIdxEntity_Union = .CXIdxEntity_Union;
// alias CXIdxEntity_CXXClass = .CXIdxEntity_CXXClass;
// alias CXIdxEntity_CXXNamespace = .CXIdxEntity_CXXNamespace;
// alias CXIdxEntity_CXXNamespaceAlias = .CXIdxEntity_CXXNamespaceAlias;
// alias CXIdxEntity_CXXStaticVariable = .CXIdxEntity_CXXStaticVariable;
// alias CXIdxEntity_CXXStaticMethod = .CXIdxEntity_CXXStaticMethod;
// alias CXIdxEntity_CXXInstanceMethod = .CXIdxEntity_CXXInstanceMethod;
// alias CXIdxEntity_CXXConstructor = .CXIdxEntity_CXXConstructor;
// alias CXIdxEntity_CXXDestructor = .CXIdxEntity_CXXDestructor;
// alias CXIdxEntity_CXXConversionFunction = .CXIdxEntity_CXXConversionFunction;
// alias CXIdxEntity_CXXTypeAlias = .CXIdxEntity_CXXTypeAlias;
// alias CXIdxEntity_CXXInterface = .CXIdxEntity_CXXInterface;
// alias CXIdxEntity_CXXConcept = .CXIdxEntity_CXXConcept;

enum CXIdxEntityLanguage
{
    CXIdxEntityLang_None = 0,
    CXIdxEntityLang_C = 1,
    CXIdxEntityLang_ObjC = 2,
    CXIdxEntityLang_CXX = 3,
    CXIdxEntityLang_Swift = 4
}

mixin EnumC!CXIdxEntityLanguage;
// alias CXIdxEntityLang_None = .CXIdxEntityLang_None;
// alias CXIdxEntityLang_C = .CXIdxEntityLang_C;
// alias CXIdxEntityLang_ObjC = .CXIdxEntityLang_ObjC;
// alias CXIdxEntityLang_CXX = .CXIdxEntityLang_CXX;
// alias CXIdxEntityLang_Swift = .CXIdxEntityLang_Swift;

/**
 * Extra C++ template information for an entity. This can apply to:
 * CXIdxEntity_Function
 * CXIdxEntity_CXXClass
 * CXIdxEntity_CXXStaticMethod
 * CXIdxEntity_CXXInstanceMethod
 * CXIdxEntity_CXXConstructor
 * CXIdxEntity_CXXConversionFunction
 * CXIdxEntity_CXXTypeAlias
 */
enum CXIdxEntityCXXTemplateKind
{
    CXIdxEntity_NonTemplate = 0,
    CXIdxEntity_Template = 1,
    CXIdxEntity_TemplatePartialSpecialization = 2,
    CXIdxEntity_TemplateSpecialization = 3
}

mixin EnumC!CXIdxEntityCXXTemplateKind;
// alias CXIdxEntity_NonTemplate = .CXIdxEntity_NonTemplate;
// alias CXIdxEntity_Template = .CXIdxEntity_Template;
// alias CXIdxEntity_TemplatePartialSpecialization = .CXIdxEntity_TemplatePartialSpecialization;
// alias CXIdxEntity_TemplateSpecialization = .CXIdxEntity_TemplateSpecialization;

enum CXIdxAttrKind
{
    CXIdxAttr_Unexposed = 0,
    CXIdxAttr_IBAction = 1,
    CXIdxAttr_IBOutlet = 2,
    CXIdxAttr_IBOutletCollection = 3
}

mixin EnumC!CXIdxAttrKind;
// alias CXIdxAttr_Unexposed = .CXIdxAttr_Unexposed;
// alias CXIdxAttr_IBAction = .CXIdxAttr_IBAction;
// alias CXIdxAttr_IBOutlet = .CXIdxAttr_IBOutlet;
// alias CXIdxAttr_IBOutletCollection = .CXIdxAttr_IBOutletCollection;

struct CXIdxAttrInfo
{
    CXIdxAttrKind kind;
    CXCursor cursor;
    CXIdxLoc loc;
}

struct CXIdxEntityInfo
{
    CXIdxEntityKind kind;
    CXIdxEntityCXXTemplateKind templateKind;
    CXIdxEntityLanguage lang;
    const(char)* name;
    const(char)* USR;
    CXCursor cursor;
    const(CXIdxAttrInfo*)* attributes;
    uint numAttributes;
}

struct CXIdxContainerInfo
{
    CXCursor cursor;
}

struct CXIdxIBOutletCollectionAttrInfo
{
    const(CXIdxAttrInfo)* attrInfo;
    const(CXIdxEntityInfo)* objcClass;
    CXCursor classCursor;
    CXIdxLoc classLoc;
}

enum CXIdxDeclInfoFlags
{
    CXIdxDeclFlag_Skipped = 0x1
}

alias CXIdxDeclFlag_Skipped = CXIdxDeclInfoFlags.CXIdxDeclFlag_Skipped;

struct CXIdxDeclInfo
{
    const(CXIdxEntityInfo)* entityInfo;
    CXCursor cursor;
    CXIdxLoc loc;
    const(CXIdxContainerInfo)* semanticContainer;
    /**
     * Generally same as #semanticContainer but can be different in
     * cases like out-of-line C++ member functions.
     */
    const(CXIdxContainerInfo)* lexicalContainer;
    int isRedeclaration;
    int isDefinition;
    int isContainer;
    const(CXIdxContainerInfo)* declAsContainer;
    /**
     * Whether the declaration exists in code or was created implicitly
     * by the compiler, e.g. implicit Objective-C methods for properties.
     */
    int isImplicit;
    const(CXIdxAttrInfo*)* attributes;
    uint numAttributes;

    uint flags;
}

enum CXIdxObjCContainerKind
{
    CXIdxObjCContainer_ForwardRef = 0,
    CXIdxObjCContainer_Interface = 1,
    CXIdxObjCContainer_Implementation = 2
}

mixin EnumC!CXIdxObjCContainerKind;
// alias CXIdxObjCContainer_ForwardRef = .CXIdxObjCContainer_ForwardRef;
// alias CXIdxObjCContainer_Interface = .CXIdxObjCContainer_Interface;
// alias CXIdxObjCContainer_Implementation = .CXIdxObjCContainer_Implementation;

struct CXIdxObjCContainerDeclInfo
{
    const(CXIdxDeclInfo)* declInfo;
    CXIdxObjCContainerKind kind;
}

struct CXIdxBaseClassInfo
{
    const(CXIdxEntityInfo)* base;
    CXCursor cursor;
    CXIdxLoc loc;
}

struct CXIdxObjCProtocolRefInfo
{
    const(CXIdxEntityInfo)* protocol;
    CXCursor cursor;
    CXIdxLoc loc;
}

struct CXIdxObjCProtocolRefListInfo
{
    const(CXIdxObjCProtocolRefInfo*)* protocols;
    uint numProtocols;
}

struct CXIdxObjCInterfaceDeclInfo
{
    const(CXIdxObjCContainerDeclInfo)* containerInfo;
    const(CXIdxBaseClassInfo)* superInfo;
    const(CXIdxObjCProtocolRefListInfo)* protocols;
}

struct CXIdxObjCCategoryDeclInfo
{
    const(CXIdxObjCContainerDeclInfo)* containerInfo;
    const(CXIdxEntityInfo)* objcClass;
    CXCursor classCursor;
    CXIdxLoc classLoc;
    const(CXIdxObjCProtocolRefListInfo)* protocols;
}

struct CXIdxObjCPropertyDeclInfo
{
    const(CXIdxDeclInfo)* declInfo;
    const(CXIdxEntityInfo)* getter;
    const(CXIdxEntityInfo)* setter;
}

struct CXIdxCXXClassDeclInfo
{
    const(CXIdxDeclInfo)* declInfo;
    const(CXIdxBaseClassInfo*)* bases;
    uint numBases;
}

/**
 * Data for IndexerCallbacks#indexEntityReference.
 *
 * This may be deprecated in a future version as this duplicates
 * the \c CXSymbolRole_Implicit bit in \c CXSymbolRole.
 */
enum CXIdxEntityRefKind
{
    /**
     * The entity is referenced directly in user's code.
     */
    CXIdxEntityRef_Direct = 1,
    /**
     * An implicit reference, e.g. a reference of an Objective-C method
     * via the dot syntax.
     */
    CXIdxEntityRef_Implicit = 2
}

mixin EnumC!CXIdxEntityRefKind;
// alias CXIdxEntityRef_Direct = .CXIdxEntityRef_Direct;
// alias CXIdxEntityRef_Implicit = .CXIdxEntityRef_Implicit;

/**
 * Roles that are attributed to symbol occurrences.
 *
 * Internal: this currently mirrors low 9 bits of clang::index::SymbolRole with
 * higher bits zeroed. These high bits may be exposed in the future.
 */
enum CXSymbolRole
{
    CXSymbolRole_None = 0,
    CXSymbolRole_Declaration = 1 << 0,
    CXSymbolRole_Definition = 1 << 1,
    CXSymbolRole_Reference = 1 << 2,
    CXSymbolRole_Read = 1 << 3,
    CXSymbolRole_Write = 1 << 4,
    CXSymbolRole_Call = 1 << 5,
    CXSymbolRole_Dynamic = 1 << 6,
    CXSymbolRole_AddressOf = 1 << 7,
    CXSymbolRole_Implicit = 1 << 8
}

mixin EnumC!CXSymbolRole;
// alias CXSymbolRole_None = .CXSymbolRole_None;
// alias CXSymbolRole_Declaration = .CXSymbolRole_Declaration;
// alias CXSymbolRole_Definition = .CXSymbolRole_Definition;
// alias CXSymbolRole_Reference = .CXSymbolRole_Reference;
// alias CXSymbolRole_Read = .CXSymbolRole_Read;
// alias CXSymbolRole_Write = .CXSymbolRole_Write;
// alias CXSymbolRole_Call = .CXSymbolRole_Call;
// alias CXSymbolRole_Dynamic = .CXSymbolRole_Dynamic;
// alias CXSymbolRole_AddressOf = .CXSymbolRole_AddressOf;
// alias CXSymbolRole_Implicit = .CXSymbolRole_Implicit;

/**
 * Data for IndexerCallbacks#indexEntityReference.
 */
struct CXIdxEntityRefInfo
{
    CXIdxEntityRefKind kind;
    /**
     * Reference cursor.
     */
    CXCursor cursor;
    CXIdxLoc loc;
    /**
     * The entity that gets referenced.
     */
    const(CXIdxEntityInfo)* referencedEntity;
    /**
     * Immediate "parent" of the reference. For example:
     *
     * \code
     * Foo *var;
     * \endcode
     *
     * The parent of reference of type 'Foo' is the variable 'var'.
     * For references inside statement bodies of functions/methods,
     * the parentEntity will be the function/method.
     */
    const(CXIdxEntityInfo)* parentEntity;
    /**
     * Lexical container context of the reference.
     */
    const(CXIdxContainerInfo)* container;
    /**
     * Sets of symbol roles of the reference.
     */
    CXSymbolRole role;
}

/**
 * A group of callbacks used by #clang_indexSourceFile and
 * #clang_indexTranslationUnit.
 */
struct IndexerCallbacks
{
    /**
     * Called periodically to check whether indexing should be aborted.
     * Should return 0 to continue, and non-zero to abort.
     */
    int function (in CXClientData client_data, void* reserved) abortQuery;

    /**
     * Called at the end of indexing; passes the complete diagnostic set.
     */
    void function (in CXClientData client_data, CXDiagnosticSet, void* reserved) diagnostic;

    CXIdxClientFile function (
        CXClientData client_data,
        CXFile mainFile,
        void* reserved) enteredMainFile;

    /**
     * Called when a file gets \#included/\#imported.
     */
    CXIdxClientFile function (
        CXClientData client_data,
        const(CXIdxIncludedFileInfo)*) ppIncludedFile;

    /**
     * Called when a AST file (PCH or module) gets imported.
     *
     * AST files will not get indexed (there will not be callbacks to index all
     * the entities in an AST file). The recommended action is that, if the AST
     * file is not already indexed, to initiate a new indexing job specific to
     * the AST file.
     */
    CXIdxClientASTFile function (
        CXClientData client_data,
        const(CXIdxImportedASTFileInfo)*) importedASTFile;

    /**
     * Called at the beginning of indexing a translation unit.
     */
    CXIdxClientContainer function (
        CXClientData client_data,
        void* reserved) startedTranslationUnit;

    void function (in CXClientData client_data, const(CXIdxDeclInfo)*) indexDeclaration;

    /**
     * Called to index a reference of an entity.
     */
    void function (
        CXClientData client_data,
        const(CXIdxEntityRefInfo)*) indexEntityReference;
}

int clang_index_isEntityObjCContainerKind (in CXIdxEntityKind);
const(CXIdxObjCContainerDeclInfo)* clang_index_getObjCContainerDeclInfo (
    const(CXIdxDeclInfo)*);

const(CXIdxObjCInterfaceDeclInfo)* clang_index_getObjCInterfaceDeclInfo (
    const(CXIdxDeclInfo)*);

const(CXIdxObjCCategoryDeclInfo)* clang_index_getObjCCategoryDeclInfo (
    const(CXIdxDeclInfo)*);

const(CXIdxObjCProtocolRefListInfo)* clang_index_getObjCProtocolRefListInfo (
    const(CXIdxDeclInfo)*);

const(CXIdxObjCPropertyDeclInfo)* clang_index_getObjCPropertyDeclInfo (
    const(CXIdxDeclInfo)*);

const(CXIdxIBOutletCollectionAttrInfo)* clang_index_getIBOutletCollectionAttrInfo (
    const(CXIdxAttrInfo)*);

const(CXIdxCXXClassDeclInfo)* clang_index_getCXXClassDeclInfo (
    const(CXIdxDeclInfo)*);

/**
 * For retrieving a custom CXIdxClientContainer attached to a
 * container.
 */
CXIdxClientContainer clang_index_getClientContainer (
    const(CXIdxContainerInfo)*);

/**
 * For setting a custom CXIdxClientContainer attached to a
 * container.
 */
void clang_index_setClientContainer (
    const(CXIdxContainerInfo)*,
    CXIdxClientContainer);

/**
 * For retrieving a custom CXIdxClientEntity attached to an entity.
 */
CXIdxClientEntity clang_index_getClientEntity (const(CXIdxEntityInfo)*);

/**
 * For setting a custom CXIdxClientEntity attached to an entity.
 */
void clang_index_setClientEntity (const(CXIdxEntityInfo)*, CXIdxClientEntity);

/**
 * An indexing action/session, to be applied to one or multiple
 * translation units.
 */
alias CXIndexAction = void*;

/**
 * An indexing action/session, to be applied to one or multiple
 * translation units.
 *
 * \param CIdx The index object with which the index action will be associated.
 */
CXIndexAction clang_IndexAction_create (in CXIndex CIdx);

/**
 * Destroy the given index action.
 *
 * The index action must not be destroyed until all of the translation units
 * created within that index action have been destroyed.
 */
void clang_IndexAction_dispose (in CXIndexAction);

enum CXIndexOptFlags
{
    /**
     * Used to indicate that no special indexing options are needed.
     */
    CXIndexOpt_None = 0x0,

    /**
     * Used to indicate that IndexerCallbacks#indexEntityReference should
     * be invoked for only one reference of an entity per source file that does
     * not also include a declaration/definition of the entity.
     */
    CXIndexOpt_SuppressRedundantRefs = 0x1,

    /**
     * Function-local symbols should be indexed. If this is not set
     * function-local symbols will be ignored.
     */
    CXIndexOpt_IndexFunctionLocalSymbols = 0x2,

    /**
     * Implicit function/class template instantiations should be indexed.
     * If this is not set, implicit instantiations will be ignored.
     */
    CXIndexOpt_IndexImplicitTemplateInstantiations = 0x4,

    /**
     * Suppress all compiler warnings when parsing for indexing.
     */
    CXIndexOpt_SuppressWarnings = 0x8,

    /**
     * Skip a function/method body that was already parsed during an
     * indexing session associated with a \c CXIndexAction object.
     * Bodies in system headers are always skipped.
     */
    CXIndexOpt_SkipParsedBodiesInSession = 0x10
}

mixin EnumC!CXIndexOptFlags;
// alias CXIndexOpt_None = .CXIndexOpt_None;
// alias CXIndexOpt_SuppressRedundantRefs = .CXIndexOpt_SuppressRedundantRefs;
// alias CXIndexOpt_IndexFunctionLocalSymbols = .CXIndexOpt_IndexFunctionLocalSymbols;
// alias CXIndexOpt_IndexImplicitTemplateInstantiations = .CXIndexOpt_IndexImplicitTemplateInstantiations;
// alias CXIndexOpt_SuppressWarnings = .CXIndexOpt_SuppressWarnings;
// alias CXIndexOpt_SkipParsedBodiesInSession = .CXIndexOpt_SkipParsedBodiesInSession;

/**
 * Index the given source file and the translation unit corresponding
 * to that file via callbacks implemented through #IndexerCallbacks.
 *
 * \param client_data pointer data supplied by the client, which will
 * be passed to the invoked callbacks.
 *
 * \param index_callbacks Pointer to indexing callbacks that the client
 * implements.
 *
 * \param index_callbacks_size Size of #IndexerCallbacks structure that gets
 * passed in index_callbacks.
 *
 * \param index_options A bitmask of options that affects how indexing is
 * performed. This should be a bitwise OR of the CXIndexOpt_XXX flags.
 *
 * \param[out] out_TU pointer to store a \c CXTranslationUnit that can be
 * reused after indexing is finished. Set to \c NULL if you do not require it.
 *
 * \returns 0 on success or if there were errors from which the compiler could
 * recover.  If there is a failure from which there is no recovery, returns
 * a non-zero \c CXErrorCode.
 *
 * The rest of the parameters are the same as #clang_parseTranslationUnit.
 */
int clang_indexSourceFile (
    CXIndexAction,
    CXClientData client_data,
    IndexerCallbacks* index_callbacks,
    uint index_callbacks_size,
    uint index_options,
    const(char)* source_filename,
    const(char*)* command_line_args,
    int num_command_line_args,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    CXTranslationUnit* out_TU,
    uint TU_options);

/**
 * Same as clang_indexSourceFile but requires a full command line
 * for \c command_line_args including argv[0]. This is useful if the standard
 * library paths are relative to the binary.
 */
int clang_indexSourceFileFullArgv (
    CXIndexAction,
    CXClientData client_data,
    IndexerCallbacks* index_callbacks,
    uint index_callbacks_size,
    uint index_options,
    const(char)* source_filename,
    const(char*)* command_line_args,
    int num_command_line_args,
    CXUnsavedFile* unsaved_files,
    uint num_unsaved_files,
    CXTranslationUnit* out_TU,
    uint TU_options);

/**
 * Index the given translation unit via callbacks implemented through
 * #IndexerCallbacks.
 *
 * The order of callback invocations is not guaranteed to be the same as
 * when indexing a source file. The high level order will be:
 *
 *   -Preprocessor callbacks invocations
 *   -Declaration/reference callbacks invocations
 *   -Diagnostic callback invocations
 *
 * The parameters are the same as #clang_indexSourceFile.
 *
 * \returns If there is a failure from which there is no recovery, returns
 * non-zero, otherwise returns 0.
 */
int clang_indexTranslationUnit (
    CXIndexAction,
    CXClientData client_data,
    IndexerCallbacks* index_callbacks,
    uint index_callbacks_size,
    uint index_options,
    CXTranslationUnit);

/**
 * Retrieve the CXIdxFile, file, line, column, and offset represented by
 * the given CXIdxLoc.
 *
 * If the location refers into a macro expansion, retrieves the
 * location of the macro expansion and if it refers into a macro argument
 * retrieves the location of the argument.
 */
void clang_indexLoc_getFileLocation (
    CXIdxLoc loc,
    CXIdxClientFile* indexFile,
    CXFile* file,
    uint* line,
    uint* column,
    uint* offset);

/**
 * Retrieve the CXSourceLocation represented by the given CXIdxLoc.
 */
CXSourceLocation clang_indexLoc_getCXSourceLocation (in CXIdxLoc loc);

/**
 * Visitor invoked for each field found by a traversal.
 *
 * This visitor function will be invoked for each field found by
 * \c clang_Type_visitFields. Its first argument is the cursor being
 * visited, its second argument is the client data provided to
 * \c clang_Type_visitFields.
 *
 * The visitor should return one of the \c CXVisitorResult values
 * to direct \c clang_Type_visitFields.
 */
alias CXFieldVisitor = CXVisitorResult function (
    CXCursor C,
    CXClientData client_data);

/**
 * Visit the fields of a particular type.
 *
 * This function visits all the direct fields of the given cursor,
 * invoking the given \p visitor function with the cursors of each
 * visited field. The traversal may be ended prematurely, if
 * the visitor returns \c CXFieldVisit_Break.
 *
 * \param T the record type whose field may be visited.
 *
 * \param visitor the visitor function that will be invoked for each
 * field of \p T.
 *
 * \param client_data pointer data supplied by the client, which will
 * be passed to the visitor each time it is invoked.
 *
 * \returns a non-zero value if the traversal was terminated
 * prematurely by the visitor returning \c CXFieldVisit_Break.
 */
uint clang_Type_visitFields (
    CXType T,
    CXFieldVisitor visitor,
    CXClientData client_data);

/**
 * @}
 */

/**
 * @}
 */
