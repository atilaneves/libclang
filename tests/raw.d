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
        string[] commandLineArgs = [fileName];
        CXUnsavedFile[] unsavedFiles;
        auto translUnit = clang_parseTranslationUnit(
            index,
            fileName.toStringz,
            &commandLineArgs.map!(a => a.toStringz).array[0],
            cast(int)commandLineArgs.length,
            unsavedFiles.ptr,
            cast(uint)unsavedFiles.length,
            CXTranslationUnit_None,
        );
        auto cursor = clang_getTranslationUnitCursor(translUnit);

        void* clientData = null;
        clang_visitChildren(cursor, &foo, clientData);
    }
}

extern(C) CXChildVisitResult foo(CXCursor cursor, CXCursor parent, void* clientData) {
    static int cursorIndex;

    assert(false);

    switch(cursorIndex) {

    default:
        assert(false);

    case 0:
        //clang_getCursorKind(cursor).shouldEqual(CXCursor_StructDecl);
        clang_getCursorKind(cursor).shouldEqual(42);
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

    return CXChildVisit_Recurse;
}
