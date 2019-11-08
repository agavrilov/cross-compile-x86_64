# Build macOS SDK
FROM ubuntu AS builder

# Install build tools
RUN apt-get update && \
    apt-get install --yes \
        automake \
        bison \
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

# Install C++ compiler for Linux and Windows, musl-tools, OpenSSL and pkg-config
RUN apt-get update && \
    apt-get install -y --no-install-recommends g++ g++-mingw-w64-x86-64 musl-tools libssl-dev pkg-config && \
    apt-get clean

ENV PATH=$PATH:/usr/osxcross/bin
