import test.infra;
import clang;

@("visitChildren C++ file with one simple struct")
@safe unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        string[] commandLineArgs;
        auto translUnit = parse(
            fileName,
            commandLineArgs,
            TranslationUnitFlags.None,
        );

        translUnit.visitChildren(
            (cursor, parent) {

                static int cursorIndex;

                switch(cursorIndex) {

                default:
                    assert(false);

                case 0:
                    cursor.kind.shouldEqual(Cursor.Kind.StructDecl);
                    parent.kind.shouldEqual(Cursor.Kind.TranslationUnit);
                    break;

                case 1:
                    cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                    parent.kind.shouldEqual(Cursor.Kind.StructDecl);
                    break;

                case 2:
                    cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                    parent.kind.shouldEqual(Cursor.Kind.StructDecl);
                    break;
                }

                ++cursorIndex;


                return ChildVisitResult.Recurse;
            }
        );
    }
}


@("visitChildren C++ file with one simple struct and throwing visitor")
@safe unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        string[] commandLineArgs;
        auto translUnit = parse(
            fileName,
            commandLineArgs,
            TranslationUnitFlags.None,
        );

        translUnit.visitChildren(
            (cursor, parent) {
                int i;
                if(i % 2 == 0)
                    throw new Exception("oops");
                return ChildVisitResult.Recurse;
            }
        ).shouldThrowWithMessage("oops");
    }

}

@("foreach(cursor, parent) C++ file with one simple struct")
@safe unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        string[] commandLineArgs;
        auto translUnit = parse(
            fileName,
            commandLineArgs,
            TranslationUnitFlags.None,
        );

        foreach(cursor, parent; translUnit) {

            static int cursorIndex;

            switch(cursorIndex) {

            default:
                assert(false);

            case 0:
                cursor.kind.shouldEqual(Cursor.Kind.StructDecl);
                parent.kind.shouldEqual(Cursor.Kind.TranslationUnit);
                break;

            case 1:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                parent.kind.shouldEqual(Cursor.Kind.StructDecl);
                break;

            case 2:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                parent.kind.shouldEqual(Cursor.Kind.StructDecl);
                break;
            }

            ++cursorIndex;
        }
    }
}

@("foreach(cursor) C++ file with one simple struct")
@safe unittest {
    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        string[] commandLineArgs;
        auto translUnit = parse(
            fileName,
            commandLineArgs,
            TranslationUnitFlags.None,
        );

        foreach(cursor; translUnit) {

            static int cursorIndex;

            switch(cursorIndex) {

            default:
                assert(false);

            case 0:
                cursor.kind.shouldEqual(Cursor.Kind.StructDecl);
                break;

            case 1:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                break;

            case 2:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                break;
            }

            ++cursorIndex;
        }
    }
}

@("cursor.children C++ file with one simple struct")
@safe unittest {
    import std.algorithm: map;

    with(newTranslationUnit("foo.cpp",
                            q{ struct { int int_; double double_; }; }))
    {
        string[] commandLineArgs;
        auto translUnit = parse(
            fileName,
            commandLineArgs,
            TranslationUnitFlags.None,
        );

        const cursor = translUnit.cursor;
        with(Cursor.Kind) {
            cursor.children.map!(a => a.kind).shouldEqual([StructDecl]);
            cursor.children[0].children.map!(a => a.kind).shouldEqual(
                [FieldDecl, FieldDecl]
            );
        }

        foreach(cursor; translUnit) {

            static int cursorIndex;

            switch(cursorIndex) {

            default:
                assert(false);

            case 0:
                cursor.kind.shouldEqual(Cursor.Kind.StructDecl);
                break;

            case 1:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                break;

            case 2:
                cursor.kind.shouldEqual(Cursor.Kind.FieldDecl);
                break;
            }

            ++cursorIndex;
        }
    }
}
