module clang;

import clang.c.index;
import clang.c.util: EnumD;

mixin EnumD!("TranslationUnitFlags", CXTranslationUnit_Flags, "CXTranslationUnit_");


TranslationUnit parse(in string fileName, in TranslationUnitFlags translUnitflags)
    @safe
{
    return parse(fileName, [], translUnitflags);
}


TranslationUnit parse(in string fileName, in string[] commandLineArgs, in TranslationUnitFlags translUnitflags)
    @trusted
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
        commandLineArgz.ptr,
        cast(int)commandLineArgz.length,
        unsavedFiles.ptr,
        cast(uint)unsavedFiles.length,
        CXTranslationUnit_None,
    );

    return TranslationUnit(cx);
}

mixin EnumD!("ChildVisitResult", CXChildVisitResult, "CXChildVisit_");

alias CursorVisitor = ChildVisitResult delegate(Cursor cursor, Cursor parent);

struct TranslationUnit {

    CXTranslationUnit _cx;

    Cursor cursor() @trusted const {
        return Cursor(clang_getTranslationUnitCursor(_cx));
    }

    void visitChildren(CursorVisitor visitor) @safe {
        cursor.visitChildren(visitor);
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) @safe block) @safe const {
        return cursor.opApply(block);
    }

    int opApply(scope int delegate(Cursor cursor) @safe block) @safe const {
        return cursor.opApply(block);
    }
}

string toString(CXString cxString) @safe pure {
    import std.conv: to;
    auto cstr = clang_getCString(cxString);
    auto str = () @trusted { return cstr.to!string; }();
    clang_disposeString(cxString);
    return str;
}

struct Cursor {

    mixin EnumD!("Kind", CXCursorKind, "CXCursor_");

    private CXCursor _cx;
    Kind kind;
    string spelling;
    Type type;
    Type returnType;

    this(CXCursor cx) @safe pure {
        _cx = cx;
        kind = cast(Kind) clang_getCursorKind(_cx);
        spelling = clang_getCursorSpelling(_cx).toString;
        type = Type(clang_getCursorType(_cx));

        if(kind == Kind.FunctionDecl)
            returnType = Type(clang_getCursorResultType(_cx));
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this(kind, spelling, Type());
    }

    this(in Kind kind, in string spelling, Type type) @safe @nogc pure nothrow {
        this(kind, spelling, type, Type());
    }

    this(in Kind kind, in string spelling, Type type, Type returnType) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
        this.type = type;
        this.returnType = returnType;
    }

    string toString() @safe pure const {
        import std.conv: text;
        return text("Cursor(", kind, `, "`, spelling, `", `, type, ", ", returnType, ")");
    }

    SourceRange sourceRange() @safe nothrow const {
        return typeof(return).init;
    }

    bool isPredefined() @safe @nogc pure nothrow const {
        // FIXME
        return false;
    }

    void visitChildren(CursorVisitor visitor) @trusted const {
        clang_visitChildren(_cx, &cvisitor, new ClientData(visitor));
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) @safe block) @safe const {
        return opApplyN(block);
    }

    int opApply(scope int delegate(Cursor cursor) @safe block) @safe const {
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
    string path;
    SourceLocation start;
    SourceLocation end;
}

struct SourceLocation {
    uint offset;
}

private struct ClientData {
    CursorVisitor dvisitor;
}

private extern(C) CXChildVisitResult cvisitor(CXCursor cursor, CXCursor parent, void* clientData_) {
    auto clientData = cast(ClientData*)clientData_;
    return cast(CXChildVisitResult)clientData.dvisitor(Cursor(cursor), Cursor(parent));
}


struct Type {

    mixin EnumD!("Kind", CXTypeKind, "CXType_");

    private CXType _cx;

    Kind kind;
    string spelling;

    this(CXType _cx) @safe pure {
        this.kind = cast(Kind) _cx.kind;
        spelling = clang_getTypeSpelling(_cx).toString;
    }

    this(in Kind kind) @safe @nogc pure nothrow {
        this(kind, "");
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
    }

    string toString() @safe pure const {
        import std.conv: text;
        return text("Type(", kind, `, "`, spelling, `")`);
    }
}
