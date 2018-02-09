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

auto newCppFile(in string fileName, in string fileContents) @safe {
    import unit_threaded.integration: Sandbox;
    return immutable NewCppFile(fileName, fileContents);
}

auto newTranslationUnit(in string fileName, in string fileContents) @safe {
    return newCppFile(fileName, fileContents);
}
