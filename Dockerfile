FROM debian:sid-slim
LABEL maintainer="Thorsten Schubert <tschubert@bafh.org>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG SYNC_ARCH="x64"
ARG SYNC_VER="stable"

ENV UNAME=rslsync \
	UID=1002 \
	GID=1002 \
	SYNC_ARCH=${SYNC_ARCH} \
	SYNC_VER=${SYNC_VER} \
	TZ=Europe/Berlin

RUN \
	apt-get update \
	&& apt-get install -y --no-install-recommends \
		tzdata \
		curl \
		openssl \
		ca-certificates \
		ssl-cert \
		iproute2 \
	&& rm -rf /var/lib/apt/lists/* /usr/share/man/* /tmp/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./su-exec-0.2/su-exec /usr/local/bin/
COPY ./root/sync.conf /config/sync.conf

RUN \
	mkdir -p /config /sync /app \
	&& useradd -M -d /app -r -U -u ${UID} -s /bin/false ${UNAME} \
	&& chown -vR ${UID}:${GID} /config /sync /app \
	&& chmod a+x /entrypoint.sh /usr/local/bin/su-exec

USER ${UNAME}
VOLUME [ "/config", "/sync", "/app" ]
USER root

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/app/rslsync", "--nodaemon", "--config", "/config/sync.conf" ]


# ports and volumes
EXPOSE 3838/udp 50890/tcp 50890/udp 8890/tcp
