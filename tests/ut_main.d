module main;

import unit_threaded;

int main(string[] args) {
    return args.runTests!(
        "parse.raw",
        "parse.cooked",
        "wrap",
        "ut.enum_",
    );
}
