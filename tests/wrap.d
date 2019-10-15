module wrap;


import test.infra;
import clang: Cursor, Type;


@("wrapped.enums")
@safe unittest {
    with(const NewTranslationUnit(
             "c.c",
             q{
                 struct Foo { int dummy; };
                 struct Foo createFoo(int d);
             })
        )
    {
        import clang: Cursor;

        {
            const foo = translUnitCursor.children[0];
            foo.kind.should == Cursor.Kind.StructDecl;
            foo.spelling.should == "Foo";
        }

        {
            const createFoo = translUnitCursor.children[1];
            createFoo.kind.should == Cursor.Kind.FunctionDecl;
            const returnType = createFoo.returnType;
            returnType.kind.should == Type.Kind.Elaborated;
            returnType.spelling.should == "struct Foo";
            const namedReturnType = returnType.namedType;
            namedReturnType.kind.should == Type.Kind.Record;
            namedReturnType.spelling.should == "struct Foo";
        }
    }
}
