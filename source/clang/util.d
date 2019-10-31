module clang.util;


version (Windows) {
    extern(C) private int _mktemp_s(char* nameTemplate, size_t sizeInChars) nothrow @safe @nogc;
}


/**
   Makes a member variable lazy so that it's only computed if necessary.
   Very hacky, uses undefined behaviour by casting const away as if
   it were using C++'s `mutable`.
 */
mixin template Lazy(alias memberVariable) {

    import std.format: format;

    private enum id = __traits(identifier, memberVariable);
    static assert(id[0] == '_',
                  "`" ~ id ~ "` does not start with an underscore");

    private enum initVar = id ~ `Init`;
    mixin(`bool `, initVar, `;`);

    private enum str = q{
            ref %s()() @property const scope return {
                import std.traits: Unqual;
                if(!%s) {
                    () @trusted { cast(bool) %s = true; }();
                    () @trusted { cast(Unqual!(typeof(%s))) %s = %s; }();
                }
                return %s;
            }
        }.format(
            id[1..$],
            initVar,
            initVar,
            id, id, id ~ `Create`,
            id,
        )
    ;

    //pragma(msg, str);
    mixin(str);
}


/**
   Returns a suitable temporary file name
 */
string getTempFileName() @trusted {
    import std.file: tempDir;
    import std.path: buildPath;
    import std.string: fromStringz;
    import std.process: environment;

    const dir = environment.get("APPVEYOR", null) is null
        ? tempDir
        : ".";

    char[] tmpnamBuf = buildPath(dir, "libclangXXXXXX\0").dup;

    version (Posix) {
        import core.sys.posix.stdlib: mkstemp;
        mkstemp(&tmpnamBuf[0]);
    }
    else version (Windows)
        _mktemp_s(&tmpnamBuf[0], tmpnamBuf.length);

    return tmpnamBuf.idup;
}
