module parse.cooked;


import test.infra;
import clang;


@("visitChildren C++ file with one simple struct")
@safe unittest {
    with(NewTranslationUnit("foo.cpp",
                            q{ struct Struct { int int_; double double_; }; }))
    {
        translUnit.cursor.visitChildren(
            (cursor, parent) {

                import clang: Cursor;

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


@("foreach(cursor, parent) C++ file with one simple struct")
@safe unittest {
    with(NewTranslationUnit("foo.cpp",
                            q{ struct Struct { int int_; double double_; }; }))
    {
        foreach(cursor, parent; translUnit.cursor) {

            import clang: Cursor;

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
    with(NewTranslationUnit("foo.cpp",
                            q{ struct Struct { int int_; double double_; }; }))
    {
        foreach(cursor; translUnit.cursor) {

            import clang: Cursor;

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

    with(NewTranslationUnit("foo.cpp",
                            q{ struct Struct { int int_; double double_; }; }))
    {
        import clang: Cursor;

        const cursor = translUnit.cursor;
        with(Cursor.Kind) {
            cursor.children.map!(a => a.kind).shouldEqual([StructDecl]);
            cursor.children[0].children.map!(a => a.kind).shouldEqual(
                [FieldDecl, FieldDecl]
            );
        }
    }
}


@("Function return type should have valid cx")
@safe unittest {
    import clang.c.index: CXType_Pointer;
    with(NewTranslationUnit("foo.cpp",
                            q{
                                const char* newString();
                            }))
    {
        import clang: Cursor;

        const cursor = translUnit.cursor;
        cursor.children.length.shouldEqual(1);
        const function_ = cursor.children[0];
        function_.spelling.should == "newString";
        function_.kind.shouldEqual(Cursor.Kind.FunctionDecl);
        function_.returnType.kind.shouldEqual(Type.Kind.Pointer);
        function_.returnType.cx.kind.shouldEqual(CXType_Pointer);
    }
}
