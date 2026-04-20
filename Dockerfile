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
        python3 \
        texinfo \
        wget \
        xz-utils \
    && apt-get clean

# Copy and unpack MUSL ARM cross toolchain
COPY toolchains/aarch64-linux-musl-cross.tar.xz /tmp/
RUN mkdir -p /opt/cross \
    && tar -xJf /tmp/aarch64-linux-musl-cross.tar.xz -C /opt/cross

# Clone OSXCross and download SDK into 'tarballs' directory
RUN SDK_VERSION='26.1' && \
    SDK_CHECKSUM=beee7212d265a6d2867d0236cc069314b38d5fb3486a6515734e76fa210c784c && \
    cd /tmp && \
    git clone https://github.com/tpoechtrager/osxcross && \
    cd osxcross && \
    wget https://github.com/joseluisq/macosx-sdks/releases/download/$SDK_VERSION/MacOSX$SDK_VERSION.sdk.tar.xz --directory-prefix=tarballs && \
    echo "$SDK_CHECKSUM  tarballs/MacOSX$SDK_VERSION.sdk.tar.xz" | sha256sum -c -

# Build SDK
RUN cd /tmp/osxcross && \
        UNATTENDED=yes OSX_VERSION_MIN=10.7 PORTABLE=yes ./build.sh

# Copy macOS SDK built in the previous stage, copy MUSL toolchain and install additional build tools
FROM ubuntu
COPY --from=builder /tmp/osxcross/target /usr/osxcross/
COPY --from=builder /opt/cross /opt/cross/

# Install C++ compilers for Linux and Windows, musl-tools, OpenSSL and pkg-config
RUN ln -sf /opt/cross/aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc /usr/local/bin/aarch64-linux-musl-gcc \
    && ln -sf /opt/cross/aarch64-linux-musl-cross/bin/aarch64-linux-musl-ar /usr/local/bin/aarch64-linux-musl-ar \
    && ln -sf /opt/cross/aarch64-linux-musl-cross/bin/aarch64-linux-musl-ranlib /usr/local/bin/aarch64-linux-musl-ranlib \
    && apt-get update && \
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
        perl \
        pkg-config \
        uuid-dev \
    && apt-get clean

ENV PATH=$PATH:/usr/osxcross/bin
