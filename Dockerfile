# Build macOS SDK
FROM ubuntu AS builder

# Install build tools
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        automake \
        bison \
        ca-certificates \
        clang \
        cmake \
        curl \
        file \
        flex \
        git \
        libssl-dev \
        libtool \
        libxml2-dev \
        make \
        pkg-config \
        python \
        texinfo \
        wget \
        xz-utils \
    && apt-get clean

RUN cd /tmp && \
        git clone https://github.com/tpoechtrager/osxcross && \
        cd osxcross && \
        wget https://s3.dockerproject.org/darwin/v2/MacOSX10.11.sdk.tar.xz --directory-prefix=tarballs && \
        UNATTENDED=yes OSX_VERSION_MIN=10.7 PORTABLE=yes ./build.sh

# Copy macOS SDK built in the previous stage and install additional build tools
FROM ubuntu
COPY --from=builder /tmp/osxcross/target /usr/osxcross/

# symlink c++ headers to the location expected by osxtools
RUN ln -s /usr/osxcross/SDK/MacOSX10.11.sdk/usr/include/c++/4.2.1 /usr/osxcross/SDK/MacOSX10.11.sdk/usr/include/c++/v1

# Install C++ compilers for Linux and Windows, musl-tools, OpenSSL and pkg-config
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        ca-certificates \
        clang \
        curl \
        g++ \
        g++-mingw-w64-x86-64 \
        libssl-dev \
        libxml2-dev \
        llvm-dev \
        musl-tools \
        pkg-config \
        uuid-dev \
    && apt-get clean

ENV PATH=$PATH:/usr/osxcross/bin
