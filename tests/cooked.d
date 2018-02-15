import test.infra;
import clang;

@ShouldFail
@("C++ file with one simple struct")
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
        auto cursor = translUnit.cursor;
        void* context = null;

        cursor.visitChildren(context,
                             (cursor, parent, context) {

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
                             });
    }
}


@("C++ file with one simple struct and throwing visitor")
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
        auto cursor = translUnit.cursor;
        void* context = null;

        cursor.visitChildren(context,
                             (cursor, parent, context) {
                                 int i;
                                 if(i % 2 == 0)
                                     throw new Exception("oops");
                                 return ChildVisitResult.Recurse;
                             })
            .shouldThrowWithMessage("oops");
    }

}
