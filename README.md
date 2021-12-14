libclang
=========

[![CI](https://github.com/atilaneves/libclang/actions/workflows/d.yml/badge.svg)](https://github.com/atilaneves/libclang/actions/workflows/d.yml)
[![Coverage](https://codecov.io/gh/atilaneves/libclang/branch/master/graph/badge.svg)](https://codecov.io/gh/atilaneves/libclang)


Bindings / wrapper API for libclang in the [D programming language](https://dlang.org).


Build Instructions
------------------

Note: for a reproducible and cross-platform build environment, you can run [setup-cpp](https://github.com/aminya/setup-cpp) with `--llvm=11.0.0`. This will set up LLVM 11.0.0 and the proper environment variables.

### Windows

Install [LLVM](https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/LLVM-12.0.0-win64.exe) into `C:\Program Files\LLVM\`, making sure to tick the "Add LLVM to the system PATH for all users" option.

If `libclang.lib` was not found, put the `lib` folder of the llvm directory on the PATH.

### Linux

If `libclang.so` was not found, link it using the following command (adjust the installation path and the llvm version):
```
sudo ln -s path_to_llvm/lib/libclang-12.so.1 /lib/x86_64-linux-gnu/libclang.so
```

### MacOS

If using an external LLVM installation, add these to your `~/.bash_profile`

```bash
LLVM_PATH="/usr/local/opt/llvm/" # or any other path
LLVM_VERSION="11.0.0"
export PATH="$LLVM_PATH:$PATH"
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export LD_LIBRARY_PATH="$LLVM_PATH/lib/:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$LLVM_PATH/lib/:$DYLD_LIBRARY_PATH"
export CPATH="$LLVM_PATH/lib/clang/$LLVM_VERSION/include/"
export LDFLAGS="-L$LLVM_PATH/lib"
export CPPFLAGS="-I$LLVM_PATH/include"
export CC="$LLVM_PATH/bin/clang"
export CXX="$LLVM_PATH/bin/clang++"
```

(adjust the clang version and the external llvm installation path.)

Then run `source ~/.bash_profile`

If `libclang.dylib` was not found, link it using the following command (adjust the installation path):
```
ln -s path_to_llvm/lib/libclang.dylib /usr/local/opt/llvm/lib/libclang.dylib
```
