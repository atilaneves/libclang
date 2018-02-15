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

    string enumMixinStr(U)(U member) {
        import std.conv: text;
        return text(`enum `, member, ` = `, T.stringof, `.`, member, `;`);
    }

    static foreach(member; __traits(allMembers, T)) {
        mixin(enumMixinStr(member));
    }
}
