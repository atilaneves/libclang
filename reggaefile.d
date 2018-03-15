import reggae;
import std.typecons;

enum commonUtFlags = "-g -debug -cov";
alias ut = dubTestTarget!(CompilerFlags(commonUtFlags),
                          LinkerFlags(),
                          No.allTogether);
mixin build!(ut);
