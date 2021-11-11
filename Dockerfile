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
RUN SDK_VERSION='12.0' && \
    SDK_CHECKSUM=ac07f28c09e6a3b09a1c01f1535ee71abe8017beaedd09181c8f08936a510ffd && \
    cd /tmp && \
    git clone https://github.com/tpoechtrager/osxcross && \
    cd osxcross && \
    wget https://github.com/joseluisq/macosx-sdks/releases/download/$SDK_VERSION/MacOSX$SDK_VERSION.sdk.tar.xz --directory-prefix=tarballs && \
    echo "$SDK_CHECKSUM  tarballs/MacOSX$SDK_VERSION.sdk.tar.xz" | sha256sum -c -

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
        make \
        musl-tools \
        pkg-config \
        uuid-dev \
    && apt-get clean

ENV PATH=$PATH:/usr/osxcross/bin
