FROM debian:sid-slim
LABEL maintainer="Thorsten Schubert <tschubert@bafh.org>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG SYNC_ARCH="x64"
ARG SYNC_VER="stable"
ARG UNAME="rslsync"
ARG TZ="Europe/Berlin"
ARG UID="1002"
ARG GID="1002"
ARG CHANGE_SYNC_DIR_OWNERSHIP="false"

ENV UNAME=${UNAME} \
	SYNC_ARCH=${SYNC_ARCH} \
	SYNC_VER=${SYNC_VER} \
	TZ=${TZ} \
	UID=${UID} \
	GID=${GID} \
	CHANGE_SYNC_DIR_OWNERSHIP=${CHANGE_SYNC_DIR_OWNERSHIP}

ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"

RUN \
	set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		tzdata \
		curl \
		openssl \
		ca-certificates \
		ssl-cert \
		busybox \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /usr/share/man/* /tmp/* /var/tmp/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./su-exec-0.2/su-exec /usr/local/bin/
COPY ./root/sync.conf /config/sync.conf

RUN \
	set -x \
	&& echo ${TZ} > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata 2>&1 \
	&& mkdir -p /config /sync /app \
	&& groupadd -r -g ${GID} ${UNAME} \
	&& useradd -M -d /app -r -u ${UID} -g ${GID} -s /bin/false ${UNAME} \
	&& chown -vR ${UID}:${GID} /config /sync /app \
	&& chmod a+x /entrypoint.sh /usr/local/bin/su-exec

USER ${UNAME}
VOLUME [ "/config", "/sync", "/app" ]
USER root

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/app/rslsync", "--nodaemon", "--config", "/config/sync.conf" ]

# ports and volumes
EXPOSE 3838/udp 50890/tcp 50890/udp 8890/tcp
