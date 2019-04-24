module clang;

import clang.c.index;
import clang.c.util: EnumD;

mixin EnumD!("TranslationUnitFlags", CXTranslationUnit_Flags, "CXTranslationUnit_");
mixin EnumD!("Language", CXLanguageKind, "CXLanguage_");

TranslationUnit parse(in string fileName,
                      in TranslationUnitFlags translUnitflags = TranslationUnitFlags.None)
    @safe
{
    return parse(fileName, [], translUnitflags);
}


mixin EnumD!("ErrorCode", CXErrorCode, "");
mixin EnumD!("DiagnosticSeverity", CXDiagnosticSeverity, "CXDiagnostic_");
mixin EnumD!("TemplateArgumentKind", CXTemplateArgumentKind, "CXTemplateArgumentKind_");


TranslationUnit parse(in string fileName,
                      in string[] commandLineArgs,
                      in TranslationUnitFlags translUnitflags = TranslationUnitFlags.None)
    @safe
{

    import std.string: toStringz;
    import std.algorithm: map;
    import std.array: array, join;
    import std.conv: text;

    // faux booleans
    const excludeDeclarationsFromPCH = 0;
    const displayDiagnostics = 0;
    auto index = clang_createIndex(excludeDeclarationsFromPCH, displayDiagnostics);
    CXUnsavedFile[] unsavedFiles;
    const commandLineArgz = commandLineArgs
        .map!(a => a.toStringz)
        .array;

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

    string[] errorMessages;
    // throw if there are error diagnostics
    foreach(i; 0 .. clang_getNumDiagnostics(cx)) {
        auto diagnostic = clang_getDiagnostic(cx, i);
        scope(exit) clang_disposeDiagnostic(diagnostic);
        const severity = cast(DiagnosticSeverity) clang_getDiagnosticSeverity(diagnostic);
        enum diagnosticOptions = CXDiagnostic_DisplaySourceLocation | CXDiagnostic_DisplayColumn;
        if(severity == DiagnosticSeverity.Error || severity == DiagnosticSeverity.Fatal)
            errorMessages ~= clang_formatDiagnostic(diagnostic, diagnosticOptions).toString;
    }

    if(errorMessages.length > 0)
        throw new Exception(text("Error parsing '", fileName, "':\n",
                                 errorMessages.join("\n")));


    return TranslationUnit(cx);
}

string[] systemPaths() @safe {
    import std.process: execute;
    import std.string: splitLines, stripLeft;
    import std.algorithm: map, countUntil;
    import std.array: array;

    version(Windows)
    {
        enum devnull = "NUL";
    } else {
        enum devnull = "/dev/null";
    }

    const res = () {
        try
        {
            return execute(["clang", "-v", "-xc++", devnull, "-fsyntax-only"], ["LANG": "C"]);
        }
        catch (Exception e)
        {
            import std.typecons : Tuple;
            return Tuple!(int, "status", string, "output")(-1, e.msg);
        }
    }();
    if(res.status != 0) throw new Exception("Failed to call clang:\n" ~ res.output);

    auto lines = res.output.splitLines;

    const startIndex = lines.countUntil("#include <...> search starts here:") + 1;
    assert(startIndex > 0);
    const endIndex = lines.countUntil("End of search list.");
    assert(endIndex > 0);

    return lines[startIndex .. endIndex].map!stripLeft.array;
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

string[] toStrings(CXStringSet* strings) @trusted pure nothrow {
    scope(exit) clang_disposeStringSet(strings);
    string[] ret;
    foreach(cxstr; strings.Strings[0 .. strings.Count])
        ret ~= cxstr.toString;
    return ret;
}

mixin EnumD!("AccessSpecifier", CX_CXXAccessSpecifier, "CX_CXX");


struct Cursor {

    import std.traits: ReturnType;

    mixin EnumD!("Kind", CXCursorKind, "CXCursor_");
    mixin EnumD!("StorageClass", CX_StorageClass, "CX_SC_");

    alias Hash = ReturnType!(clang_hashCursor);

    CXCursor cx;
    private Cursor[] _children;
    Kind kind;
    string spelling;
    Type type;
    Type underlyingType;
    SourceRange sourceRange;

    this(CXCursor cx) @safe pure nothrow {
        this.cx = cx;
        kind = cast(Kind) clang_getCursorKind(cx);
        spelling = clang_getCursorSpelling(cx).toString;
        type = Type(clang_getCursorType(cx));

        if(kind == Cursor.Kind.TypedefDecl || kind == Cursor.Kind.TypeAliasDecl)
            underlyingType = Type(clang_getTypedefDeclUnderlyingType(cx));

        sourceRange = SourceRange(clang_getCursorExtent(cx));
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

    /// Lazily return the cursor's children
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

    Type returnType() @safe pure nothrow const {
        return Type(clang_getCursorResultType(cx));
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

    string mangling() @safe pure nothrow const {
        return clang_Cursor_getMangling(cx).toString;
    }

    bool isAnonymous() @safe @nogc pure nothrow const {
        return cast(bool) clang_Cursor_isAnonymous(cx);
    }

    bool isBitField() @safe @nogc pure nothrow const {
        return cast(bool) clang_Cursor_isBitField(cx);
    }

    int bitWidth() @safe @nogc pure nothrow const {
        return clang_getFieldDeclBitWidth(cx);
    }

    auto accessSpecifier() @safe @nogc pure nothrow const {
        return cast(AccessSpecifier) clang_getCXXAccessSpecifier(cx);
    }

    StorageClass storageClass() @safe @nogc pure nothrow const {
        return cast(StorageClass) clang_Cursor_getStorageClass(cx);
    }

    bool isConstCppMethod() @safe @nogc pure nothrow const {
        return cast(bool) clang_CXXMethod_isConst(cx);
    }

    bool isMoveConstructor() @safe @nogc pure nothrow const {
        return cast(bool) clang_CXXConstructor_isMoveConstructor(cx);
    }

    bool isCopyConstructor() @safe @nogc pure nothrow const {
        return cast(bool) clang_CXXConstructor_isCopyConstructor(cx);
    }

    bool isMacroFunction() @safe @nogc pure nothrow const {
        return cast(bool) clang_Cursor_isMacroFunctionLike(cx);
    }

    bool isMacroBuiltin() @safe @nogc pure nothrow const {
        return cast(bool) clang_Cursor_isMacroBuiltin(cx);
    }

    Cursor specializedCursorTemplate() @safe pure nothrow const {
        return Cursor(clang_getSpecializedCursorTemplate(cx));
    }

    TranslationUnit translationUnit() @safe nothrow const {
        return TranslationUnit(clang_Cursor_getTranslationUnit(cx));
    }

    Token[] tokens() @safe nothrow const {
        import std.algorithm: map;
        import std.array: array;

        CXToken* tokens;
        uint numTokens;

        () @trusted { clang_tokenize(translationUnit.cx, sourceRange.cx, &tokens, &numTokens); }();
        // I hope this only deallocates the array
        scope(exit) clang_disposeTokens(translationUnit.cx, tokens, numTokens);

        auto tokenSlice = () @trusted { return tokens[0 .. numTokens]; }();

        return tokenSlice.map!(a => Token(a, translationUnit)).array;
    }

    alias templateParams = templateParameters;

    const(Cursor)[] templateParameters() @safe nothrow const {
        import std.algorithm: filter;
        import std.array: array;

        const amTemplate =
            kind == Cursor.Kind.ClassTemplate
            || kind == Cursor.Kind.TypeAliasTemplateDecl
            || kind == Cursor.Kind.FunctionTemplate
            ;
        const templateCursor = amTemplate ? this : specializedCursorTemplate;

        auto range = templateCursor
            .children
            .filter!(a => a.kind == Cursor.Kind.TemplateTypeParameter ||
                          a.kind == Cursor.Kind.NonTypeTemplateParameter);

        // Why is this @system? Who knows.
        return () @trusted { return range.array; }();
    }

    /**
       If declared at file scope.
     */
    bool isFileScope() @safe nothrow const {
        return lexicalParent.kind == Cursor.Kind.TranslationUnit;
    }

    int numTemplateArguments() @safe @nogc pure nothrow const {
        return clang_Cursor_getNumTemplateArguments(cx);
    }

    TemplateArgumentKind templateArgumentKind(int i) @safe @nogc pure nothrow const {
        return cast(TemplateArgumentKind) clang_Cursor_getTemplateArgumentKind(cx, i);
    }

    Type templateArgumentType(int i) @safe pure nothrow const {
        return Type(clang_Cursor_getTemplateArgumentType(cx, i));
    }

    long templateArgumentValue(int i) @safe @nogc pure nothrow const {
        return clang_Cursor_getTemplateArgumentValue(cx, i);
    }

    bool opEquals(ref const(Cursor) other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalCursors(cx, other.cx);
    }

    bool opEquals(in Cursor other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalCursors(cx, other.cx);
    }

    void visitChildren(scope CursorVisitor visitor) @safe nothrow const {
        scope clientData = ClientData(visitor);
        // why isn't this @safe with dip10000???
        () @trusted { clang_visitChildren(cx, &cvisitor, &clientData); }();
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) @safe block) @safe nothrow const {
        return opApplyN(block);
    }

    int opApply(scope int delegate(Cursor cursor) @safe block) @safe nothrow const {
        return opApplyN(block);
    }

    private int opApplyN(T)(scope T block) const {
        import std.traits: Parameters;

        int stop = 0;

        enum numParams = Parameters!T.length;

        visitChildren((cursor, parent) {

            static if(numParams == 2)
                stop = block(cursor, parent);
            else static if(numParams == 1)
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

    this(CXType cx) @safe pure nothrow {
        this.cx = cx;
        this.kind = cast(Kind) cx.kind;
        spelling = clang_getTypeSpelling(cx).toString;
    }

    this(in Type other) @trusted pure nothrow {
        import std.algorithm: map;
        import std.array: array;

        this.cx.kind = other.cx.kind;
        this.cx.data[] = other.cx.data[].map!(a => cast(void*) a).array;

        this(this.cx);
    }

    this(in Kind kind) @safe @nogc pure nothrow {
        this(kind, "");
    }

    this(in Kind kind, in string spelling) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
    }

    Type pointee() @safe pure nothrow const {
        return Type(clang_getPointeeType(cx));
    }

    Type unelaborate() @safe nothrow const {
        return Type(clang_Type_getNamedType(cx));
    }

    Type canonical() @safe pure nothrow const {
        return Type(clang_getCanonicalType(cx));
    }

    Type returnType() @safe pure const {
        return Type(clang_getResultType(cx));
    }

    // Returns a range of Type
    auto paramTypes()() @safe pure const nothrow {

        static struct Range {
            const CXType cx;
            const int numArgs;
            int index = 0;

            bool empty() {
                return index < 0 || index >= numArgs;
            }

            void popFront() {
                ++index;
            }

            Type front() {
                return Type(clang_getArgType(cx, index));
            }
        }

        return Range(cx, clang_getNumArgTypes(cx));
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

    long arraySize() @safe @nogc pure nothrow const {
        return clang_getArraySize(cx);
    }

    bool isConstQualified() @safe @nogc pure nothrow const {
        return cast(bool) clang_isConstQualifiedType(cx);
    }

    bool isVolatileQualified() @safe @nogc pure nothrow const {
        return cast(bool) clang_isVolatileQualifiedType(cx);
    }

    Cursor declaration() @safe pure nothrow const {
        return Cursor(clang_getTypeDeclaration(cx));
    }

    Type namedType() @safe pure nothrow const {
        return Type(clang_Type_getNamedType(cx));
    }

    bool opEquals(ref const(Type) other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalTypes(cx, other.cx);
    }

    bool opEquals(in Type other) @safe @nogc pure nothrow const {
        return cast(bool) clang_equalTypes(cx, other.cx);
    }

    bool isInvalid() @safe @nogc pure nothrow const {
        return kind == Kind.Invalid;
    }

    long getSizeof() @safe @nogc pure nothrow const {
        return clang_Type_getSizeOf(cx);
    }

    int numTemplateArguments() @safe @nogc pure nothrow const {
        return clang_Type_getNumTemplateArguments(cx);
    }

    Type typeTemplateArgument(int i) @safe pure nothrow const {
        return Type(clang_Type_getTemplateArgumentAsType(cx, i));
    }

    string toString() @safe pure nothrow const {
        import std.conv: text;

        try {
            return text("Type(", kind, `, "`, spelling, `")`);
        } catch(Exception e)
            assert(false, "Fatal error in Type.toString: " ~ e.msg);
    }
}


struct Token {

    mixin EnumD!("Kind", CXTokenKind, "CXToken_");

    Kind kind;
    string spelling;
    CXToken cx;
    TranslationUnit translationUnit;

    this(CXToken cx, TranslationUnit unit) @safe pure nothrow {
        this.cx = cx;
        this.translationUnit = unit;
        this.kind = cast(Kind) clang_getTokenKind(cx);
        this.spelling = .toString(clang_getTokenSpelling(translationUnit.cx, cx));
    }

    this(Kind kind, string spelling) @safe @nogc pure nothrow {
        this.kind = kind;
        this.spelling = spelling;
    }

    string toString() @safe pure const {
        import std.conv: text;

        return text("Token(", kind, `, "`, spelling, `")`);
    }

    bool opEquals(in Token other) @safe pure nothrow const {
        return kind == other.kind && spelling == other.spelling;
    }
}
