/**
   Static constructors
 */
module clang.static_;


immutable bool[string] gPredefinedCursors;


shared static this() nothrow {
    try {

        import clang: parse, TranslationUnitFlags;
        import clang.util: getTempFileName;

        const fileName = getTempFileName;
        {
            // create an empty file
            import std.stdio: File;
            auto f = File(fileName, "w");
            f.writeln;
            f.flush;
            f.detach;
        }

        auto tu = parse(fileName,
                        ["-xc"],
                        TranslationUnitFlags.DetailedPreprocessingRecord);
        foreach(cursor; tu.cursor.children) {
            gPredefinedCursors[cursor.spelling] = true;
        }

    } catch(Exception e) {
        import std.stdio: stderr;
        try
            stderr.writeln("Error initialising libclang: ", e);
        catch(Exception _) {}
    }
}
