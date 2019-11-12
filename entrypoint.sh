#!/usr/bin/env bash

set -ex

log()
{
    echo \[$(date +'%Y%m%d %H:%M:%S.%3N')\] $HOSTNAME $*
}

rsinst()
{
	log "downloading resilio-sync ${SYNC_VER} for ${SYNC_ARCH}."
	setpriv --reuid $UID --regid $GID --clear-groups --reset-env \
	curl -s -o /app/version.txt -L "https://download-cdn.getsync.com/stable/linux-x64/version.txt" \
		&& curl -s -o /app/sync.tar.gz -L "https://download-cdn.getsync.com/${SYNC_VER}/linux-${SYNC_ARCH}/resilio-sync_${SYNC_ARCH}.tar.gz" \
		&& setpriv --reuid $UID --regid $GID --clear-groups --reset-env tar xf /app/sync.tar.gz -C /app \
		&& setpriv --reuid $UID --regid $GID --clear-groups --reset-env rm -f /app/sync.tar.gz
}

rsrepl()
{
	setpriv --reuid $UID --regid $GID --clear-groups --reset-env \
	curl -s -o /app/version_new.txt -L "https://download-cdn.getsync.com/${SYNC_VER}/linux-${SYNC_ARCH}/version.txt"
	if [[ -f /app/version.txt && -f /app/version_new.txt ]]; then
		mapfile -t < /app/version.txt
		local OLDV=${MAPFILE[0]}
		mapfile -t < /app/version_new.txt
		local NEWV=${MAPFILE[0]}
		log "old version: ${OLDV}"
		log "new version: ${NEWV}"
		if [[ "${OLDV}" == "${NEWV}" ]]; then
			rm -f /app/version_new.txt;
			log "version is current, skipping download."
		else
			log "removing ${OLDV} and installing ${NEWV}."
			rm -f /app/*
			rsinst
		fi
	fi
}

fixperms()
{
	if [[ "${CHANGE_SYNC_DIR_OWNERSHIP,,}" = "true" ]]; then
		log "forcing permission to ${UID}:${GID} on /sync folder"
		chown -R $UID:$GID /sync
	fi
	log "fixing UID/GID and permissions of /config and /app"
	usermod -u $UID $UNAME &> /dev/null \
		&& groupmod -g $GID $UNAME &> /dev/null \
		&& chown -R $UID:$GID /config /app
}

settime()
{
	log "setting timezone to ${TZ}"
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
	dpkg-reconfigure -f noninteractive tzdata 2>&1
}

settime
fixperms

if [[ ! -e /app/rslsync ]]; then
	rsinst
else
	rsrepl
fi

exec setpriv --reuid $UID --regid $GID --clear-groups --reset-env "$@"
