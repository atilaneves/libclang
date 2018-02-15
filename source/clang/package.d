module clang;

import clang.c.index;
import clang.c.util: EnumD;

mixin EnumD!("TranslationUnitFlags", CXTranslationUnit_Flags, "CXTranslationUnit_");

TranslationUnit parse(in string fileName, in string[] commandLineArgs, in TranslationUnitFlags translUnitflags)
    @safe
{
    return TranslationUnit();
}

struct TranslationUnit {
    Cursor cursor() @safe {
        return Cursor();
    }
}


mixin EnumD!("ChildVisitResult", CXChildVisitResult, "CXChildVisit_");

alias CursorVisitor = ChildVisitResult delegate(Cursor cursor, Cursor parent, void* context);

struct Cursor {

    mixin EnumD!("Kind", CXCursorKind, "CXCursor_");

    Kind kind() @safe @nogc pure nothrow const {
        return Kind.init;
    }

    void visitChildren(void* context, CursorVisitor visitor) @safe {

    }
}
