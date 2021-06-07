libclang
=========

[![CI](https://github.com/atilaneves/libclang/actions/workflows/d.yml/badge.svg)](https://github.com/atilaneves/libclang/actions/workflows/d.yml)
[![Coverage](https://codecov.io/gh/atilaneves/libclang/branch/master/graph/badge.svg)](https://codecov.io/gh/atilaneves/libclang)


Bindings / wrapper API for libclang in the [D programming language](https://dlang.org).


Build Instructions
------------------

### Windows

1. Install http://releases.llvm.org/6.0.1/LLVM-6.0.1-win64.exe into `C:\Program Files\LLVM\`, making sure to tick the "Add LLVM to the system PATH for all users" option.
2. Compile with LDC
    1. Make sure you have [LDC](https://github.com/ldc-developers/ldc/releases) installed somewhere.
    2. Compile your project with `dub build --compiler=C:\path\to\bin\ldc2.exe`.
3. Copy `C:\Program Files\LLVM\bin\libclang.dll` next to your executable.
