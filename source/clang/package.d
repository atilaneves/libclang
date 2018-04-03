module clang;

import clang.c.index;
import clang.c.util: EnumD;

mixin EnumD!("TranslationUnitFlags", CXTranslationUnit_Flags, "CXTranslationUnit_");
mixin EnumD!("Language", CXLanguageKind, "CXLanguage_");

TranslationUnit parse(in string fileName, in TranslationUnitFlags translUnitflags)
    @safe
{
    return parse(fileName, [], translUnitflags);
}


mixin EnumD!("ErrorCode", CXErrorCode, "");
mixin EnumD!("DiagnosticSeverity", CXDiagnosticSeverity, "CXDiagnostic_");

TranslationUnit parse(in string fileName, in string[] commandLineArgs, in TranslationUnitFlags translUnitflags)
    @safe
{

    import std.string: toStringz;
    import std.algorithm: map;
    import std.array: array;
    import std.conv: text;

    // faux booleans
    const excludeDeclarationsFromPCH = 0;
    const displayDiagnostics = 0;
    auto index = clang_createIndex(excludeDeclarationsFromPCH, displayDiagnostics);
    CXUnsavedFile[] unsavedFiles;
    const commandLineArgz = commandLineArgs.map!(a => a.toStringz).array;

    CXTranslationUnit cx;
    const err = () @trusted {
        return cast(ErrorCode)clang_parseTranslationUnit2(
            index,
            fileName.toStringz,
            commandLineArgz.ptr, // .ptr since the length can be 0
            cast(int)commandLineArgz.length,
            unsavedFiles.ptr,  // .ptr since the length can be 0
            cast(uint)unsavedFiles.length,
            translUnitflags,
            &cx,
        );
    }();

    if(err != ErrorCode.success) {
        throw new Exception(text("Could not parse ", fileName, ": ", err));
    }

    // throw if there are error diagnostics
    foreach(i; 0 .. clang_getNumDiagnostics(cx)) {
        auto diagnostic = clang_getDiagnostic(cx, i);
        scope(exit) clang_disposeDiagnostic(diagnostic);
        const severity = cast(DiagnosticSeverity) clang_getDiagnosticSeverity(diagnostic);
        if(severity == DiagnosticSeverity.Error)
            throw new Exception(text("Error parsing '", fileName, "': ",
                                     clang_formatDiagnostic(diagnostic, 0).toString));
    }

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
    private Cursor[] _children;
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
    }

    private static extern(C) CXChildVisitResult ctorVisitor(CXCursor cursor,
                                                            CXCursor parent,
                                                            void* clientData_)
        @safe nothrow
    {
        auto children = () @trusted { return cast(Cursor[]*) clientData_; }();
        *children ~= Cursor(cursor);
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

    inout(Cursor)[] children() @safe @property nothrow inout {
        if(_children.length) return _children;

        inout(Cursor)[] ret;
        // calling Cursor.visitChildren here would cause infinite recursion
        // because cvisitor constructs a Cursor out of the parent
        () @trusted { clang_visitChildren(cx, &ctorVisitor, &ret); }();
        return ret;
    }

    void children(Cursor[] cursors) @safe @property pure nothrow {
        _children = cursors;
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

    /**
       For EnumConstantDecl cursors, return the numeric value
     */
    auto enumConstantValue() @safe @nogc pure nothrow const {
        assert(kind == Cursor.Kind.EnumConstantDecl);
        return clang_getEnumConstantDeclValue(cx);
    }

    Language language() @safe @nogc pure nothrow const {
        return cast(Language) clang_getCursorLanguage(cx);
    }

    Cursor canonical() @safe nothrow const {
        return Cursor(clang_getCanonicalCursor(cx));
    }

    /**
       If this is the canonical cursor. Given forward declarations, there may
       be several cursors for one entity. This returns true if this cursor
       is the canonical one.
     */
    bool isCanonical() @safe @nogc pure nothrow const {
        return cast(bool) clang_equalCursors(cx, clang_getCanonicalCursor(cx));
    }

    bool isDefinition() @safe @nogc pure nothrow const {
        return cast(bool) clang_isCursorDefinition(cx);
    }

    bool isNull() @safe @nogc pure nothrow const {
        return cast(bool) clang_Cursor_isNull(cx);
    }

    static Cursor nullCursor() @safe nothrow {
        return Cursor(clang_getNullCursor());
    }

    Cursor definition() @safe nothrow const {
        return Cursor(clang_getCursorDefinition(cx));
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

    Cursor semanticParent() @safe nothrow const {
        return Cursor(clang_getCursorSemanticParent(cx));
    }

    Cursor lexicalParent() @safe nothrow const {
        return Cursor(clang_getCursorLexicalParent(cx));
    }

    bool isInvalid() @safe @nogc pure nothrow const {
        return cast(bool) clang_isInvalid(cx.kind);
    }

    auto hash() @safe @nogc pure nothrow const {
        return clang_hashCursor(cx);
    }

    bool opEquals(ref const(Cursor) other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalCursors(cx, other.cx);
    }

    bool opEquals(in Cursor other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalCursors(cx, other.cx);
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

    string toString() @safe pure const {
        import std.conv: text;
        return text(`SourceRange("`, start.path, `", `, start.line, ":", start.column, ", ", end.line, ":", end.column, ")");
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

    int opCmp(ref const(SourceLocation) other) @safe @nogc pure nothrow const {
        if(path == other.path && line == other.line && column == other.column &&
           offset == other.offset)
            return 0;

        if(path < other.path) return -1;
        if(path > other.path) return 1;
        if(line < other.line) return -1;
        if(line > other.line) return 1;
        if(column < other.column) return -1;
        if(column > other.column) return 1;
        if(offset < other.offset) return -1;
        if(offset > other.offset) return 1;
        assert(false);
    }

    string toString() @safe pure nothrow const {
        import std.conv: text;
        return text(`"`, path, `" `, line, ":", column, ":", offset);
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
    Type* pointee; // only if pointer

    this(CXType cx) @safe pure nothrow {
        this.cx = cx;
        this.kind = cast(Kind) cx.kind;
        spelling = clang_getTypeSpelling(cx).toString;

        if(this.kind == Kind.Pointer) {
            pointee = new Type(clang_getPointeeType(cx));
        }
    }

    this(in Kind kind) @safe @nogc pure nothrow {
        this(kind, "");
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
    }

    static Type* pointer(in string spelling, Type* pointee) @safe pure nothrow {
        auto type = new Type(Kind.Pointer, spelling);
        type.pointee = pointee;
        return type;
    }

    Type unelaborate() @safe nothrow const {
        return Type(clang_Type_getNamedType(cx));
    }

    Type canonical() @safe pure nothrow const {
        return Type(clang_getCanonicalType(cx));
    }

    Type returnType() @safe pure const {
        if(kind != Kind.FunctionProto) throw new Exception("Type not a function");
        return Type(clang_getResultType(cx));
    }

    Type[] paramTypes() @safe pure const {
        const numArgs = clang_getNumArgTypes(cx);
        auto types = new Type[numArgs];

        foreach(i; 0 .. numArgs) {
            types[i] = Type(clang_getArgType(cx, i));
        }

        return types;
    }

    bool isVariadicFunction() @safe @nogc pure nothrow const {
        return cast(bool) clang_isFunctionTypeVariadic(cx);
    }

    Type elementType() @safe pure nothrow const {
        return Type(clang_getElementType(cx));
    }

    long numElements() @safe @nogc pure nothrow const {
        return clang_getNumElements(cx);
    }

    bool isConstQualified() @safe @nogc pure nothrow const {
        return cast(bool)clang_isConstQualifiedType(cx);
    }

    bool isVolatileQualified() @safe @nogc pure nothrow const {
        return cast(bool)clang_isVolatileQualifiedType(cx);
    }

    string toString() @safe pure nothrow const {
        import std.conv: text;
        try {
            const pointeeText = pointee is null ? "" : text(", ", *pointee);
            return text("Type(", kind, `, "`, spelling, pointeeText, `")`);
        } catch(Exception e)
            assert(false, "Fatal error in Type.toString: " ~ e.msg);
    }
}
