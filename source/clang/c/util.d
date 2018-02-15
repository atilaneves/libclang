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
    import std.traits: EnumMembers;
    import std.conv: text;

    static foreach(member; EnumMembers!T) {
        mixin(text(`enum `, member, ` = `, T.stringof, `.`, member, `;`));
    }
}
