import reggae;
import std.typecons;

enum commonUtFlags = "-g -debug -cov";
alias ut = dubTestTarget!(CompilerFlags(commonUtFlags),
                          LinkerFlags(),
                          CompilationMode.package_);
mixin build!(ut);
