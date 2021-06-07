module parse.sourcerange;


import test.infra;
import clang;


@("path")
@safe unittest {
    import clang.c.index: CXType_Pointer;
    with(NewTranslationUnit("foo.cpp",
                            q{
                                const char* newString();
                            }))
    {
        const cursor = translUnit.cursor;
        const function_ = cursor.children[0];
        function_.sourceRange.path.should == inSandboxPath("foo.cpp");
    }
}


@("start")
@safe unittest {
    import clang.c.index: CXType_Pointer;
    with(NewTranslationUnit("foo.cpp",
                            q{
                                const char* newString();
                            }))
    {
        const cursor = translUnit.cursor;
        const function_ = cursor.children[0];

        function_.sourceRange.start.path.should == inSandboxPath("foo.cpp");
        function_.sourceRange.start.line.should == 2;
        version(Windows) {}
        else {
            function_.sourceRange.start.column.should == 33;
            function_.sourceRange.start.offset.should == 33;
        }
    }
}


@("end")
@safe unittest {
    import clang.c.index: CXType_Pointer;
    with(NewTranslationUnit("foo.cpp",
                            q{
                                const char* newString();
                            }))
    {
        const cursor = translUnit.cursor;
        const function_ = cursor.children[0];

        function_.sourceRange.end.path.should == inSandboxPath("foo.cpp");
        function_.sourceRange.end.line.should == 2;
        version(Windows) {}
        else {
            function_.sourceRange.end.column.should == 56;
            function_.sourceRange.end.offset.should == 56;
        }
    }
}
