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

    Cursor cursor() @trusted {
        return Cursor(clang_getTranslationUnitCursor(_cx));
    }

    void visitChildren(CursorVisitor visitor) @safe {
        cursor.visitChildren(visitor);
    }

    int opApply(scope int delegate(Cursor cursor, Cursor parent) block) @safe {
        return opApplyN(block);
    }

    int opApply(scope int delegate(Cursor cursor) block) @safe {
        return opApplyN(block);
    }

    private int opApplyN(T...)(int delegate(T args) block) {
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
                : ChildVisitResult.Recurse;
        });

        return stop;
    }
}


struct Cursor {

    mixin EnumD!("Kind", CXCursorKind, "CXCursor_");

    CXCursor _cx;

    Kind kind() @trusted @nogc nothrow const {
        return cast(Kind)clang_getCursorKind(_cx);
    }

    void visitChildren(CursorVisitor visitor) @trusted {
        clang_visitChildren(_cx, &cvisitor, new ClientData(visitor));
    }
}

private struct ClientData {
    CursorVisitor dvisitor;
}

private extern(C) CXChildVisitResult cvisitor(CXCursor cursor, CXCursor parent, void* clientData_) {
    auto clientData = cast(ClientData*)clientData_;
    return cast(CXChildVisitResult)clientData.dvisitor(Cursor(cursor), Cursor(parent));
}
