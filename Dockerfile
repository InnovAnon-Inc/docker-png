FROM innovanon/doom-base as builder-02
USER root
COPY --from=innovanon/zlib  /tmp/zlib.txz  /tmp/
COPY --from=innovanon/bzip2 /tmp/bzip2.txz /tmp/
COPY --from=innovanon/xz    /tmp/xz.txz    /tmp/
RUN extract.sh

FROM builder-02 as png
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && command -v strip.sh                 \
 && git clone --depth=1 --recursive       \
      https://github.com/glennrp/libpng.git \
 && cd                         libpng     \
 && ./configure                           \
      --disable-shared --enable-static    \
      "${CONFIG_OPTS[@]}"                 \
 && make                                  \
 && make DESTDIR=/tmp/libpng install      \
 && cd           /tmp/libpng              \
 && strip.sh .                            \
 && tar acf        ../libpng.txz .        \
 && rm -rf        $LFS/sources/libpng

FROM scratch as final
COPY --from=png /tmp/libpng.txz /tmp/

