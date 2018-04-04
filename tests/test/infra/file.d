module test.infra.file;


struct NewCppFile {
    import unit_threaded.integration: Sandbox;
    Sandbox sandbox;
    alias sandbox this;

    this(in string fileName, in string fileContents) @safe inout {
        this._fileName = fileName;
        this.sandbox = inout Sandbox();
        sandbox.writeFile(fileName, fileContents);
    }

    string fileName() @safe pure const nothrow {
        return sandbox.inSandboxPath(_fileName);
    }

    private string _fileName;
}

struct NewTranslationUnit {
    import clang: TranslationUnit, Cursor;

    alias newCppFile this;

    NewCppFile newCppFile;
    TranslationUnit translUnit;
    Cursor translUnitCursor;

    this(in string fileName, in string fileContents) @safe {
        import clang: parse, TranslationUnitFlags;

        newCppFile = NewCppFile(fileName, fileContents);

        string[] commandLineArgs;
        translUnit = parse(newCppFile.fileName, commandLineArgs, TranslationUnitFlags.None);
        translUnitCursor = translUnit.cursor;
    }
}
