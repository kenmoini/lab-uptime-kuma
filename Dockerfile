############################################
# Build in Golang
# Run npm run build-healthcheck-armv7 in the host first, another it will be super slow where it is building the armv7 healthcheck
# Check file: builder-go.dockerfile
############################################
FROM docker.io/louislam/uptime-kuma:builder-go AS build_healthcheck

############################################
# Build in Node.js - RHEL UBI
############################################
FROM registry.access.redhat.com/ubi8/nodejs-16:1-98 AS build

# https://docs.renovatebot.com/modules/platform/github/

ARG CLOUDFLARED_VERSION=2023.2.1
ARG UPTIME_KUMA_VERSION=1.20.1

USER root
WORKDIR /app
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1

# Selectively enable repos in case you're building on an entitled host
RUN dnf update -y --disablerepo="*" --enablerepo=ubi-8-appstream-rpms --enablerepo=ubi-8-baseos-rpms && \
 dnf install -y --disablerepo="*" --enablerepo=ubi-8-appstream-rpms --enablerepo=ubi-8-baseos-rpms git wget && \
 dnf clean all && \
 rm -rf /var/cache/dnf && \
 rm -rf /var/cache/yum && \
 git clone https://github.com/louislam/uptime-kuma . && \
 npm run setup

COPY --from=build_healthcheck /app/extra/healthcheck /app/extra/healthcheck
COPY hack/entrypoint.sh /app/extra/entrypoint.sh
RUN chmod +x /app/extra/entrypoint.sh && chown -R 1001:1001 /app

# Download and install cloudflared
RUN ARCH= && dpkgArch="$(uname -i)" \
 && case "${dpkgArch##*-}" in \
   x86_64) ARCH='amd64';; \
   arm64) ARCH='arm64';; \
   armhf) ARCH='arm';; \
   *) echo "unsupported architecture"; exit 1 ;; \
 esac \
 && echo "ARCH: ${ARCH}" \
 && CFD_URL="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${ARCH}" \
 && echo "CFD_URL: ${CFD_URL}" \
 && wget -O /usr/local/bin/cloudflared ${CFD_URL} \
 && chmod +x /usr/local/bin/cloudflared

USER 1001
EXPOSE 8080
VOLUME ["/app/data"]
HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD node extra/healthcheck.js
ENTRYPOINT ["/app/extra/entrypoint.sh"]
CMD ["node", "/app/server/server.js", "--port=8080", "--host=0.0.0.0"]