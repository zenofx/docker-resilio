### This is a non-static container, featuring dynamic updates on launch.

#### Environment Variables (=default)

```
SYNC_ARCH="x64"                   # Architecture
SYNC_VER="stable"                 # Resilio branch
UNAME="rslsync"                   # Username inside the container
TZ="Europe/Berlin"                # Timezone
UID="1000"                        # User ID
GID="1000"                        # Group ID
CHANGE_SYNC_DIR_OWNERSHIP="false" # Change file ownership on container launch
```
#### Volumes
```
/config                           # configuration files (sync.conf)
/sync                             # data folder
/app                              # binary (rslsync)
```

#### Default Ports
`3838/udp 50890/tcp 50890/udp 8890/tcp`

#### Examples
```
docker run -d --name=resilio --volume="./myconfig:/config" --volume="/data/sync:/sync" zeno/resilio:latest

# override default settings: use custom ports, user mapping and named (persistent) volume for /app
docker run -d --name=resilio --hostname=resilio --env="UID=1005" --env="GID=1005" --volume="./myconfig:/config" --volume="/data/sync:/sync" --volume="resilio_app:/app:exec" -p 3838:3838/udp -p 21241:21241/tcp -p 21241:21241/udp -p 127.0.0.1:8890:8890 zeno/resilio:latest
```
