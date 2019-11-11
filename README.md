# cross-compile-x86_64

Base [Docker image](https://hub.docker.com/r/agavrilov01/cross-compile-x86_64) for cross-compilation programs for Linux, Windows and macOS.

Following packages are installed:
* ca-certificates
* clang
* curl
* g++
* g++-mingw-w64-x86-64
* libssl-dev
* libxml2-dev
* llvm-dev
* musl-tools
* pkg-config
* uuid-dev

Additionally, [OS X Cross toolchain](https://github.com/tpoechtrager/osxcross) is compiled with Mac OSX SDK 10.11 and installed into **/usr/osxcross** directory
