FROM alpine:3.20 AS base

RUN apk add --no-cache build-base autoconf linux-headers

WORKDIR /app/openssl1.0

RUN wget -qO- https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz | tar -xz --strip-components=1 &&\
    ./config shared --prefix=/opt/openssl1.0/ --openssldir=/opt/openssl1.0/ enable-ec_nistp_64_gcc_128 &&\
    make depend &&\
    make &&\
    make install

WORKDIR /app/openssl1.1

RUN wget -qO- https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz | tar -xz --strip-components=1 &&\
    ./config shared --prefix=/opt/openssl1.1/ --openssldir=/opt/openssl1.1/ enable-ec_nistp_64_gcc_128 &&\
    make depend &&\
    make &&\
    make install

WORKDIR /app/xml

RUN wget -qO- https://download.gnome.org/sources/libxml2/2.7/libxml2-2.7.6.tar.xz | tar xJ --strip-components=1 &&\
    ./configure --prefix=/opt/libxml2/ --without-threads &&\
    make -j16 &&\
    make install

WORKDIR /app/curl7

RUN wget -qO- https://curl.se/download/curl-7.88.1.tar.gz | tar xz --strip-components=1 &&\
    ./configure --prefix=/opt/curl7\
        --with-openssl=/opt/openssl1.0\
        --with-ca-path=/etc/ssl/certs\
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --disable-dict \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smtp \
        --disable-gopher \
        --disable-mqtt \
        --without-libpsl \
        --without-libidn2 \
        --without-quiche \
        LDFLAGS="-Wl,-rpath,/opt/openssl1.0/lib" &&\
    make -j16 &&\
    make install

WORKDIR /app/curl8

RUN wget -qO- https://curl.se/download/curl-8.18.0.tar.gz | tar xz --strip-components=1 &&\
    ./configure --prefix=/opt/curl8\
        --with-openssl=/opt/openssl1.1\
        --with-ca-path=/etc/ssl/certs\
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --disable-dict \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smtp \
        --disable-gopher \
        --disable-mqtt \
        --without-libpsl \
        --without-libidn2 \
        --without-quiche \
        LDFLAGS="-Wl,-rpath,/opt/openssl1.1/lib" &&\
    make -j16 &&\
    make install

FROM alpine:3.20

COPY --from=base /opt/ /opt/

RUN wget -O /etc/ssl/certs/ca-certificates.crt https://curl.se/ca/cacert.pem

RUN apk add --no-cache build-base autoconf libpng-dev
