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
    static foreach(member; __traits(allMembers, T)) {
        mixin(`enum `, member, ` = `, T.stringof, `.`, member, `;`);
    }
}


mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {
    import std.conv: text;
    import std.algorithm : map;
    import std.format : format;

    mixin(
q{enum %s {
    %-(%s,
    %),
}}.format(name, [ __traits(allMembers, T) ].map!(
             (string v) => text(v[prefix.length .. $], " = ", T.stringof, ".", v))));
}
