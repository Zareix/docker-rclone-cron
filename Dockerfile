FROM alpine:3.22

ARG RCLONE_VERSION=1.70.2

# install rclone
RUN apk add --no-cache wget ca-certificates && \
    ARCH=$(uname -m) && \
    echo "Detected architecture: ${ARCH}" && \
    case ${ARCH} in \
    x86_64) ARCH="amd64" ;; \
    aarch64) ARCH="arm64" ;; \
    armv7l) ARCH="arm" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    echo "Using rclone architecture: ${ARCH}" && \
    wget -q https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip && \
    unzip rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip && \
    mv rclone-v${RCLONE_VERSION}-linux-${ARCH}/rclone /usr/bin && \
    rm rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip && \
    rm -rf rclone-v${RCLONE_VERSION}-linux-${ARCH} && \
    apk del wget

# install entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# defaults env vars
ENV CRON_SCHEDULE="0 0 * * *"
ENV COMMAND="rclone version"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crond", "-f"]
