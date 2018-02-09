import reggae;
import std.typecons;

enum commonUtFlags = "-g -debug -cov";
alias ut = dubTestTarget!(CompilerFlags(commonUtFlags),
                          LinkerFlags(),
                          No.allTogether);
alias utl = dubConfigurationTarget!(Configuration("utl"),
                                    CompilerFlags(commonUtFlags ~ " -unittest"),
                                    LinkerFlags(),
                                    Yes.main,
                                    No.allTogether);
mixin build!(ut, utl);
