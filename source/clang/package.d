module clang;

import clang.c.index;
import clang.c.util: EnumD;

mixin EnumD!("TranslationUnitFlags", CXTranslationUnit_Flags, "CXTranslationUnit_");


TranslationUnit parse(in string fileName, in TranslationUnitFlags translUnitflags)
    @safe nothrow
{
    return parse(fileName, [], translUnitflags);
}


TranslationUnit parse(in string fileName, in string[] commandLineArgs, in TranslationUnitFlags translUnitflags)
    @safe nothrow
{

    import std.string: toStringz;
    import std.algorithm: map;
    import std.array: array;

    auto index = clang_createIndex(0, 0);
    CXUnsavedFile[] unsavedFiles;
    const commandLineArgz = commandLineArgs.map!(a => a.toStringz).array;

    auto cx = clang_parseTranslationUnit(
        index,
        fileName.toStringz,
        () @trusted {  return commandLineArgz.ptr; }(), // .ptr since the length can be 0
        cast(int)commandLineArgz.length,
        () @trusted { return unsavedFiles.ptr; }(), // .ptr since the length can be 0
        cast(uint)unsavedFiles.length,
        translUnitflags,
    );

    return TranslationUnit(cx);
}

mixin EnumD!("ChildVisitResult", CXChildVisitResult, "CXChildVisit_");

alias CursorVisitor = ChildVisitResult delegate(Cursor cursor, Cursor parent);

struct TranslationUnit {

    CXTranslationUnit cx;
    Cursor cursor;

    this(CXTranslationUnit cx) @safe nothrow {
        this.cx = cx;
        this.cursor = Cursor(clang_getTranslationUnitCursor(cx));
    }

    void visitChildren(CursorVisitor visitor) @safe nothrow {
        cursor.visitChildren(visitor);
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) @safe block) @safe nothrow const {
        return cursor.opApply(block);
    }

    int opApply(scope int delegate(Cursor cursor) @safe block) @safe nothrow const {
        return cursor.opApply(block);
    }
}

string toString(CXString cxString) @safe pure nothrow {
    import std.conv: to;
    auto cstr = clang_getCString(cxString);
    scope(exit) clang_disposeString(cxString);
    return () @trusted { return cstr.to!string; }();
}

struct Cursor {

    mixin EnumD!("Kind", CXCursorKind, "CXCursor_");

    CXCursor cx;
    Cursor[] children;
    Kind kind;
    string spelling;
    Type type;
    Type returnType; // only if the cursor is a function
    SourceRange sourceRange;

    this(CXCursor cx) @safe nothrow {
        this.cx = cx;
        kind = cast(Kind) clang_getCursorKind(cx);
        spelling = clang_getCursorSpelling(cx).toString;
        type = Type(clang_getCursorType(cx));
        sourceRange = SourceRange(clang_getCursorExtent(cx));

        if(kind == Kind.FunctionDecl)
            returnType = Type(clang_getCursorResultType(cx));

        // calling Cursor.visitChildren here would cause infinite recursion
        // because cvisitor constructs a Cursor out of the parent
        clang_visitChildren(cx, &ctorVisitor, &this);
    }

    private static extern(C) CXChildVisitResult ctorVisitor(CXCursor cursor,
                                                            CXCursor parent,
                                                            void* clientData_)
        @safe nothrow
    {
        auto self = () @trusted { return cast(typeof(&this)) clientData_; }();
        self.children ~= Cursor(cursor);
        return CXChildVisit_Continue;
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this(kind, spelling, Type());
    }

    this(in Kind kind, in string spelling, Type type) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
        this.type = type;
    }

    /**
       Constructs a function declaration cursor.
     */
    static Cursor functionDecl(in string spelling, in string proto, Type returnType)
        @safe pure nothrow
    {
        auto cursor = Cursor(Kind.FunctionDecl,
                             spelling,
                             Type(Type.Kind.FunctionProto, proto));
        cursor.returnType = returnType;
        return cursor;
    }

    /**
       For TypedefDecl cursors, return the underlying type
     */
    Type underlyingType() @safe pure nothrow const {
        assert(kind == Cursor.Kind.TypedefDecl, "Not a TypedefDecl cursor");
        return Type(clang_getTypedefDeclUnderlyingType(cx));
    }

    string toString() @safe pure nothrow const {
        import std.conv: text;
        try {
            const returnTypeStr = kind == Kind.FunctionDecl
                ? text(", ", returnType)
                : "";

            return text("Cursor(", kind, `, "`, spelling, `", `, type, returnTypeStr, ")");
        } catch(Exception e)
            assert(false, "Fatal error in Cursor.toString: " ~ e.msg);
    }

    bool isPredefined() @safe @nogc pure nothrow const {
        // FIXME
        return false;
    }

    void visitChildren(CursorVisitor visitor) @safe nothrow const {
        clang_visitChildren(cx, &cvisitor, new ClientData(visitor));
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) @safe block) @safe nothrow const {
        return opApplyN(block);
    }

    int opApply(scope int delegate(Cursor cursor) @safe block) @safe nothrow const {
        return opApplyN(block);
    }

    private int opApplyN(T...)(int delegate(T args) @safe block) const {
        int stop = 0;

        visitChildren((cursor, parent) {

            static if(T.length == 2)
                stop = block(cursor, parent);
            else static if(T.length == 1)
                stop = block(cursor);
            else
                static assert(false);

            return stop
                ? ChildVisitResult.Break
                : ChildVisitResult.Continue;
        });

        return stop;
    }
}


struct SourceRange {
    CXSourceRange cx;
    string path;
    SourceLocation start;
    SourceLocation end;

    this(CXSourceRange cx) @safe pure nothrow {
        this.cx = cx;
        this.start = clang_getRangeStart(cx);
        this.end = clang_getRangeEnd(cx);
        this.path = start.path;
    }
}

struct SourceLocation {
    CXSourceLocation cx;
    string path;
    uint line;
    uint column;
    uint offset;

    this(CXSourceLocation cx) @safe pure nothrow {
        this.cx = cx;

        CXFile file;
        () @trusted { clang_getExpansionLocation(cx, &file, null, null, null); }();
        this.path = clang_getFileName(file).toString;

        () @trusted { clang_getSpellingLocation(cx, &file, &line, &column, &offset); }();
    }
}

private struct ClientData {
    /**
       The D visitor delegate
     */
    CursorVisitor dvisitor;
}

// This is the C function actually passed to libclang's clang_visitChildren
// The context (clientData) contains the D delegate that's then called on the
// (cursor, parent) pair
private extern(C) CXChildVisitResult cvisitor(CXCursor cursor, CXCursor parent, void* clientData_) {
    auto clientData = cast(ClientData*) clientData_;
    return cast(CXChildVisitResult) clientData.dvisitor(Cursor(cursor), Cursor(parent));
}


struct Type {

    mixin EnumD!("Kind", CXTypeKind, "CXType_");

    CXType cx;
    Kind kind;
    string spelling;

    this(CXType cx) @safe pure nothrow {
        this.kind = cast(Kind) cx.kind;
        spelling = clang_getTypeSpelling(cx).toString;
    }

    this(in Kind kind) @safe @nogc pure nothrow {
        this(kind, "");
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
    }

    string toString() @safe pure const nothrow {
        import std.conv: text;
        try
            return text("Type(", kind, `, "`, spelling, `")`);
        catch(Exception e)
            assert(false, "Fatal error in Type.toString: " ~ e.msg);
    }
}
