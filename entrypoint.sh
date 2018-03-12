#!/bin/bash
set -e

function rsinst() {
	echo "Downloading resilio-snc ${SYNC_VER} for ${SYNC_ARCH}."
	su-exec $UID:$GID \
	curl -s -o /app/version.txt -L "https://download-cdn.getsync.com/stable/linux-x64/version.txt" \
	&& curl -s -o /app/sync.tar.gz -L "https://download-cdn.getsync.com/${SYNC_VER}/linux-${SYNC_ARCH}/resilio-sync_${SYNC_ARCH}.tar.gz" \
		&& su-exec $UID:$GID tar xf /app/sync.tar.gz -C /app \
		&& su-exec $UID:$GID rm -f /app/sync.tar.gz
}

function rsrepl() {
	su-exec $UID:$GID \
	curl -s -o /app/version_new.txt -L "https://download-cdn.getsync.com/${SYNC_VER}/linux-${SYNC_ARCH}/version.txt"
	if [[ -f /app/version.txt && -f /app/version_new.txt ]]; then
		mapfile -t < /app/version.txt
		OLDV=${MAPFILE[0]}
		mapfile -t < /app/version_new.txt
		NEWV=${MAPFILE[0]}
		echo "Old Version: ${OLDV}"
		echo "New Version: ${NEWV}"
		if [[ "${OLDV}" == "${NEWV}" ]]; then
			rm -f /app/version_new.txt;
			echo "Version is current, skipping download."
		else
			echo "Removing ${OLDV} and installing ${NEWV}."
			rm -f /app/*
			rsinst
		fi
	fi

}

if [[ ! -e /app/rslsync ]]; then
	rsinst
else
	rsrepl
fi

su-exec $UID:$GID "$@"
