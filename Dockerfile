FROM ubuntu

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
        && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
        git clone https://github.com/tpoechtrager/osxcross && \
        cd osxcross && \
        wget https://s3.dockerproject.org/darwin/v2/MacOSX10.11.sdk.tar.xz --directory-prefix=tarballs && \
        UNATTENDED=yes OSX_VERSION_MIN=10.7 PORTABLE=yes ./build.sh
ENV PATH=$PATH:/tmp/osxcross/target/bin
