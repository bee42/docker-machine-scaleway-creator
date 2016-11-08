FROM alpine:3.4

MAINTAINER Niclas Mietz <niclas.mietz@bee42.com> @solidnerd

ARG MACHINE_VERSION=0.8.2
ARG SCALEWAY_VERSION=1.3

ENV MACHINE_VERSION=${MACHINE_VERSION:-0.8.2}
ENV SCALEWAY_VERSION=${SCALEWAY_VERSION:-1.3}
ENV SCALEWAY_BINARY=${SCALEWAY_BINARY:-linux_amd64}
ENV SCALEWAY_DOWNLOAD_URL=${SCALEWAY_DOWNLOAD_URL:-https://github.com/scaleway/docker-machine-driver-scaleway/releases/download/v${SCALEWAY_VERSION}/docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}.tar.gz}


RUN  apk add -U --no-cache curl ca-certificates openssh-client bash \
      && curl -L https://github.com/docker/machine/releases/download/v${MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine \
      && chmod +x /usr/local/bin/docker-machine

RUN  curl -L ${SCALEWAY_DOWNLOAD_URL} -O \
      && tar xvf docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}.tar.gz \
      && chmod +x docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}/docker-machine-driver-scaleway \
      && cp docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}/docker-machine-driver-scaleway /usr/local/bin/ \
      && rm -rf docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}.tar.gz docker-machine-driver-scaleway_${SCALEWAY_VERSION}_${SCALEWAY_BINARY}/

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
