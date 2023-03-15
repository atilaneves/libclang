int main(string[] args) {
    try {
        run(args);
        return 0;
    } catch(Exception e) {
        import std.stdio: stderr;
        stderr.writeln("ERROR: ", e.msg);
        return 1;
    }
}

void run(string[] args) @safe {
    import std.path : buildPath, baseName;
    import std.conv : text;
    import std.file : copy, mkdirRecurse, exists;

    if(args.length < 2)
        throw new Exception("First argument must be directory of libclang repository");

    const repoPath = args[1];
    const majorVersion = () @trusted {
        try
            return clangVersion;
        catch(Exception e) {
            import std.stdio : stderr;
            stderr.writeln("Could not get clang version, defaulting to 14:\n" ~ e.msg);
            return 14;
        }
    }();
    // treat every version before 15 as 14
    const versionString = majorVersion < 15 ? "14" : "15";
    const translationsPath = buildPath(repoPath, "pretranslated", versionString);
    const codePath = buildPath(repoPath, "source", "clang", "c");
    if(!codePath.exists)
        mkdirRecurse(codePath);

    foreach(string src; entries(translationsPath)) {
        const dst = buildPath(codePath, baseName(src));
        copy(src, dst);
    }
}

private string[] entries(in string path) @trusted {
    import std.file : dirEntries, SpanMode;
    import std.algorithm : map;
    import std.array : array;
    return dirEntries(path, SpanMode.breadth)
        .map!(a => a.name)
        .array;
}

private int clangVersion() @safe {
    import std.string: splitLines, split;
    import std.conv: to, text;
    import std.algorithm : countUntil;

    const clangOutput = exe(["clang", "--version"]);
    const clangLines = clangOutput.splitLines;

    if(clangLines.length < 1)
        throw new Exception("Could not get 1st line from clang output\n'" ~ clangOutput ~ "'\n");

    const firstLine = clangLines[0];
    const elements = firstLine.split(" ");
    const versionIndex = elements.countUntil("version");

    void fail(A...)(A args) {
        import std.conv : text;
        throw new Exception(
            text(args, "\n",
                 "Full `clang --version` output:\n\n",
                 clangOutput,
            )
        );
    }

    if(versionIndex < 0 || versionIndex >= elements.length - 1)
        fail("Could not get version from line '", firstLine, "'");

    const version_ = elements[versionIndex + 1];
    const versionParts = version_.split(".");

    if(versionParts.length < 2)
        fail("Could not get major version from '", version_, "'");

    return versionParts[0].to!int;
}

private string exe(string[] args) @safe {
    import std.process: execute;
    import std.conv: text;
    import std.string: join;
    const res = execute(args);

    if(res.status != 0)
        throw new Exception(text("Could not execute ", args.join(" ")));

    return res.output;
}
