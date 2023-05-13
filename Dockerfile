FROM spritsail/alpine:3.17

ARG PROWLARR_VER=1.5.0.3300
ARG PROWLARR_BRANCH=develop

ENV SUID=908 SGID=908

LABEL org.opencontainers.image.authors="Spritsail <prowlarr@spritsail.io>" \
      org.opencontainers.image.title="Prowlarr" \
      org.opencontainers.image.url="https://wiki.servarr.com/prowlarr/" \
      org.opencontainers.image.description="A indexer management & proxy tool" \
      org.opencontainers.image.version=${PROWLARR_VER} \
      io.spritsail.version.prowlarr=${PROWLARR_VER}

WORKDIR /prowlarr

COPY --chmod=755 *.sh /usr/local/bin/

RUN apk add --no-cache \
        icu-libs \
        libintl \
        libmediainfo \
        sqlite-libs \
        xmlstarlet \
 && test "$(uname -m)" = aarch64 && ARCH=arm64 || ARCH=x64 \
 && wget -O- https://github.com/Prowlarr/Prowlarr/releases/download/v${PROWLARR_VER}/Prowlarr.${PROWLARR_BRANCH}.${PROWLARR_VER}.linux-musl-core-${ARCH}.tar.gz \
        | tar xz --strip-components=1 \
 && rm -rf Prowlarr.Update

VOLUME /config
ENV XDG_CONFIG_HOME=/config

EXPOSE 9696

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:9696/api/v1/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/prowlarr/Prowlarr", "--no-browser", "--data=/config"]
