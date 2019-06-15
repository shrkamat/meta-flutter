#!/bin/bash

set -x

# 
# 1. Compile cross toolcahin
#    a. compile llvm, clang
#    b. compile binutils
#    c. compile cross tools
#
# 2. Compile flutter engine
# 3. Compile flutter embedder for raspi
#

BROOT=$1    # build root

mkdir -p $BROOT/libcxxabi

cmake -B $BROOT/libcxxabi ../llvm-project/libcxxabi   \
    -DCMAKE_CROSSCOMPILING=True                       \
    -DCMAKE_SYSROOT=/sdk/sysroot                      \
    -DLIBCXX_ENABLE_SHARED=False                      \
    -DCMAKE_INSTALL_PREFIX=/sdk/toolchain             \
    -DCMAKE_BUILD_TYPE=Release                        \
    -DCMAKE_SYSTEM_NAME=Linux                         \
    -DCMAKE_SYSTEM_PROCESSOR=ARM                      \
    -DCMAKE_C_COMPILER=/sdk/toolchain/bin/clang       \
    -DCMAKE_CXX_COMPILER=/sdk/toolchain/bin/clang++   \
    -DLLVM_TARGETS_TO_BUILD=ARM                       \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=False

make -C $BROOT/libcxxabi -j4
make -C $BROOT/libcxxabi install

mkdir -p $BROOT/libcxx
cmake -B $BROOT/libcxx ../llvm-projects/libcxx                   \
    -DCMAKE_CROSSCOMPILING=True                                  \
    -DCMAKE_SYSROOT=/sdk/sysroot                                 \
    -DLIBCXX_ENABLE_SHARED=False                                 \
    -DCMAKE_INSTALL_PREFIX=/sdk/toolchain                        \
    -DCMAKE_BUILD_TYPE=Release                                   \
    -DCMAKE_SYSTEM_NAME=Linux                                    \
    -DCMAKE_SYSTEM_PROCESSOR=ARM                                 \
    -DCMAKE_C_COMPILER=/sdk/toolchain/bin/clang                  \
    -DCMAKE_CXX_COMPILER=/sdk/toolchain/bin/clang++              \
    -DLLVM_TARGETS_TO_BUILD=ARM                                  \
    -DLIBCXX_ENABLE_EXCEPTIONS=False                             \
    -DLIBCXX_ENABLE_RTTI=False                                   \
    -DLIBCXX_CXX_ABI=libcxxabi                                   \
    -DLIBCXX_CXX_ABI_INCLUDE_PATHS=/sdk/toolchain/include/c++/v1 \
    -DLIBCXX_CXX_ABI_LIBRARY_PATH=/sdk/toolchain/lib             \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=True

make -C $BROOT/libcxx -j4
make -C $BROOT/libcxx install