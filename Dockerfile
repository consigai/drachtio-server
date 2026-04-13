FROM debian:bookworm-slim

ARG BUILD_CPUS=4

RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade \
  && apt-get install -y --no-install-recommends ca-certificates gcc g++ make build-essential \
  cmake git autoconf automake  curl libtool libtool-bin libssl-dev libcurl4-openssl-dev zlib1g-dev \
  libgoogle-perftools-dev jq libboost-all-dev

COPY . /usr/local/src/drachtio-server

RUN cd /usr/local/src/drachtio-server \
  && ./bootstrap.sh \
  && mkdir -p build \
  && cd build \
  && ../configure --enable-tcmalloc=yes CPPFLAGS='-DNDEBUG' CXXFLAGS='-O2' \
  && make -j${BUILD_CPUS} \
  && make install \
  && apt-get purge -y --quiet --auto-remove gcc g++ make cmake build-essential git libtool libtool-bin \
  && rm -rf /var/lib/apt/* \
  && rm -rf /var/lib/dpkg/* \
  && rm -rf /var/lib/cache/* \
  && rm -Rf /var/log/* \
  && rm -Rf /var/lib/apt/lists/* \
  && cd /usr/local/src \
  && cp drachtio-server/docker.drachtio.conf.xml /etc/drachtio.conf.xml \
  && cp drachtio-server/entrypoint.sh / \
  && rm -Rf drachtio-server \
  && cd /usr/local/bin \
  && rm -f timer ssltest parser uri_test test_https test_asio_curl

COPY ./entrypoint.sh /

VOLUME ["/config"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["drachtio"]