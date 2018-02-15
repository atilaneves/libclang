/**
   Utilities for translating the C definitions to D.
 */
module clang.c.util;


/**
   Mixes in non-namespaced versions of the member of the enum T
   to mimic C semantics of enumerations.
   If T is enum Enum { foo, bar}, then foo and bar will be synonums for
   Enum.foo and Enum.bar
 */
mixin template EnumC(T) if(is(T == enum)) {

    private string _enumMixinStr(string member) {
        import std.conv: text;
        return text(`enum `, member, ` = `, T.stringof, `.`, member, `;`);
    }

    static foreach(member; __traits(allMembers, T)) {
        mixin(_enumMixinStr(member));
    }
}


mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {

    private static string _memberMixinStr(string member) {
        import std.conv: text;
        import std.array: replace;
        return text(`    `, member.replace(prefix, ""), ` = `, T.stringof, `.`, member, `,`);
    }

    private static string _enumMixinStr() {
        import std.array: join;

        string[] ret;

        ret ~= "enum " ~ name ~ "{";

        static foreach(member; __traits(allMembers, T)) {
            ret ~= _memberMixinStr(member);
        }

        ret ~= "}";

        return ret.join("\n");
    }

    //pragma(msg, _enumMixinStr);
    mixin(_enumMixinStr());
}
