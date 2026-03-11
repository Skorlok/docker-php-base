FROM alpine:latest AS base

RUN apk add --no-cache build-base autoconf linux-headers openssl-dev

WORKDIR /app/openssl1.0

RUN wget -qO- https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz | tar -xz --strip-components=1 &&\
    ./config shared no-man no-tests --prefix=/opt/openssl1.0/ --openssldir=/opt/openssl1.0/ enable-ec_nistp_64_gcc_128 &&\
    make depend &&\
    make -j$(nproc) &&\
    make install

WORKDIR /app/openssl1.1

RUN wget -qO- https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz | tar -xz --strip-components=1 &&\
    ./config shared no-tests --prefix=/opt/openssl1.1/ --openssldir=/opt/openssl1.1/ enable-ec_nistp_64_gcc_128 &&\
    make depend &&\
    make -j$(nproc) &&\
    make install_sw install_ssldirs

WORKDIR /app/curl7

RUN wget -qO- https://curl.se/download/curl-7.88.1.tar.gz | tar xz --strip-components=1 &&\
    ./configure --prefix=/opt/curl7\
        --with-openssl=/opt/openssl1.0\
        --with-ca-bundle=/etc/ssl/cert.pem\
        --without-libpsl \
        --without-libidn2 \
        LDFLAGS="-Wl,-rpath,/opt/openssl1.0/lib" &&\
    make -j$(nproc) &&\
    make install

WORKDIR /app/curl8

RUN wget -qO- https://curl.se/download/curl-8.17.0.tar.gz | tar xz --strip-components=1 &&\
    ./configure --prefix=/opt/curl8\
        --with-openssl=/opt/openssl1.1\
        --with-ca-bundle=/etc/ssl/cert.pem\
        --without-libpsl \
        --without-libidn2 \
        LDFLAGS="-Wl,-rpath,/opt/openssl1.1/lib" &&\
    make -j$(nproc) &&\
    make install
	
WORKDIR /app/curlssl3

RUN wget -qO- https://curl.se/download/curl-8.19.0.tar.gz | tar xz --strip-components=1 &&\
    ./configure --prefix=/opt/curlssl3\
        --with-openssl\
        --with-ca-bundle=/etc/ssl/cert.pem\
        --without-libpsl \
        --without-libidn2 &&\
    make -j$(nproc) &&\
    make install

RUN strip /opt/openssl1.0/lib/libcrypto.so.1.0.0 /opt/openssl1.0/lib/libssl.so.1.0.0
RUN strip /opt/openssl1.1/lib/libcrypto.so.1.1 /opt/openssl1.1/lib/libssl.so.1.1
RUN strip /opt/curl7/lib/libcurl.so.4
RUN strip /opt/curl8/lib/libcurl.so.4
RUN strip /opt/curlssl3/lib/libcurl.so.4

FROM scratch

COPY --from=base /opt/ /opt/
