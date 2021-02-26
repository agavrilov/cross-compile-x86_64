# Build macOS SDK
FROM ubuntu AS builder

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
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
        libz-dev \
        make \
        patch \
        pkg-config \
        python \
        texinfo \
        wget \
        xz-utils \
    && apt-get clean

# Clone OSXCross and download SDK into 'tarballs' directory
RUN cd /tmp && \
        git clone https://github.com/tpoechtrager/osxcross && \
        cd osxcross && \
        wget https://github.com/joseluisq/macosx-sdks/releases/download/10.15/MacOSX10.15.sdk.tar.xz --directory-prefix=tarballs

# Build SDK
RUN cd /tmp/osxcross && \
        UNATTENDED=yes OSX_VERSION_MIN=10.7 PORTABLE=yes ./build.sh

# Copy macOS SDK built in the previous stage and install additional build tools
FROM ubuntu
COPY --from=builder /tmp/osxcross/target /usr/osxcross/

# Install C++ compilers for Linux and Windows, musl-tools, OpenSSL and pkg-config
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
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
