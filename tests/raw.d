import test.infra;
import clang.c.index;

@("C++ file with one simple struct")
@system unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        import std.string: toStringz;
        import std.algorithm: map;
        import std.array: array;

        auto index = clang_createIndex(0, 0);
        const(char)*[] commandLineArgs;
        CXUnsavedFile[] unsavedFiles;

        auto translUnit = clang_parseTranslationUnit(
            index,
            fileName.toStringz,
            commandLineArgs.ptr,
            cast(int)commandLineArgs.length,
            unsavedFiles.ptr,
            cast(uint)unsavedFiles.length,
            CXTranslationUnit_None,
        );
        auto cursor = clang_getTranslationUnitCursor(translUnit);

        void* clientData = null;
        clang_visitChildren(cursor, &fooCppVisitor, clientData);
    }
}

private extern(C) CXChildVisitResult fooCppVisitor(CXCursor cursor, CXCursor parent, void* clientData) {
    static int cursorIndex;

    switch(cursorIndex) {

    default:
        assert(false);

    case 0:
        clang_getCursorKind(cursor).shouldEqual(CXCursor_StructDecl);
        clang_getCursorKind(parent).shouldEqual(CXCursor_TranslationUnit);
        break;

    case 1:
        clang_getCursorKind(cursor).shouldEqual(CXCursor_FieldDecl);
        clang_getCursorKind(parent).shouldEqual(CXCursor_StructDecl);
        break;

    case 2:
        clang_getCursorKind(cursor).shouldEqual(CXCursor_FieldDecl);
        clang_getCursorKind(parent).shouldEqual(CXCursor_StructDecl);
        break;
    }

    ++cursorIndex;
    return CXChildVisit_Recurse;
}

@("C++ file with one simple struct and throwing visitor")
@system unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        import std.string: toStringz;
        import std.algorithm: map;
        import std.array: array;

        auto index = clang_createIndex(0, 0);
        const(char)*[] commandLineArgs;
        CXUnsavedFile[] unsavedFiles;

        auto translUnit = clang_parseTranslationUnit(
            index,
            fileName.toStringz,
            commandLineArgs.ptr,
            cast(int)commandLineArgs.length,
            unsavedFiles.ptr,
            cast(uint)unsavedFiles.length,
            CXTranslationUnit_None,
        );
        auto cursor = clang_getTranslationUnitCursor(translUnit);

        void* clientData = null;
        clang_visitChildren(cursor, &throwingVisitor, clientData).shouldThrow;
    }
}

private extern(C) CXChildVisitResult throwingVisitor(CXCursor cursor, CXCursor parent, void* clientData) {
    throw new Exception("oops");
}
