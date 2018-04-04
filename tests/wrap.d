module wrap;

import test.infra;
import clang: Cursor, Type;

@safe unittest {
    with(const NewTranslationUnit(
             "c.c",
             q{
                 struct Foo { int dummy; };
                 struct Foo createFoo(int d);
             })
        )
    {
        {
            const foo = translUnitCursor.children[0];
            foo.kind.shouldEqual(Cursor.Kind.StructDecl);
            foo.spelling.shouldEqual("Foo");
        }

        {
            const createFoo = translUnitCursor.children[1];
            createFoo.kind.shouldEqual(Cursor.Kind.FunctionDecl);
            const returnType = createFoo.returnType;
            returnType.kind.shouldEqual(Type.Kind.Elaborated);
            returnType.spelling.shouldEqual("struct Foo");
            const namedReturnType = returnType.namedType;
            namedReturnType.kind.shouldEqual(Type.Kind.Record);
            namedReturnType.spelling.shouldEqual("struct Foo");
        }
    }
}
