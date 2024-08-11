ARG TAG=bookworm
FROM debian:${TAG} as base

ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -y install cron sudo wget gnupg curl xz-utils


##############
# Wine setup #
##############

## Enable 32 bit architecture for 64 bit systems
RUN dpkg --add-architecture i386

## Add wine repository
RUN mkdir -pm755 /etc/apt/keyrings
RUN wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN apt-get update


## Install wine and winetricks
RUN DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -y install --install-recommends winehq-devel cabextract
#RUN apt-get -y install --install-recommends wine1.7

## Setup GOSU to match user and group ids
##
## User: user
## Pass: 123
## 
## Note that this setup also relies on entrypoint.sh
## Set LOCAL_USER_ID as an ENV variable at launch or the default uid 9001 will be used
## Set LOCAL_GROUP_ID as an ENV variable at launch or the default uid 250 will be used
## (e.g. docker run -e LOCAL_USER_ID=151149 ....)
##
## Initial password for user will be 123
## ENV GOSU_VERSION 1.9
## RUN set -x \
##     && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
##     && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
##     && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
##     && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
##     && export GNUPGHOME="$(mktemp -d)" \
##     && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
##     && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
##     && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
##     && chmod +x /usr/local/bin/gosu \
##     && gosu nobody true


##############
# Node setup #
##############

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -y install nodejs
RUN npm install -g npm


ENV USER_ID 9001
ENV GROUP_ID 255361
RUN addgroup --gid $GROUP_ID userg
RUN useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m user
ENV HOME /home/user
RUN chown -R user:userg $HOME
RUN echo 'user:123' | chpasswd

RUN apt-get clean
RUN rm -rf                        \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log

RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

RUN mkdir -p /opt
RUN chown $USER_ID:$GROUP_ID -R /opt

FROM base AS add
ADD  --chmod=777 files* /opt/
RUN chmod -R 777 /opt

ENV CronSchedule="*/1 * * * *"
ENV PUID="1000"
ENV PGID="1000"

WORKDIR /opt

# Wine-Init
RUN mkdir -p /opt/wine/mono && \
wget "https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.tar.xz" -P /opt/wine/mono && \
tar -xf /opt/wine/mono/wine-mono-7.4.0-x86.tar.xz -C /opt/wine/mono && \
rm /opt/wine/mono/wine-mono-7.4.0-x86.tar.xz

ENV WINEPREFIX /opt/wineprefix
RUN sudo -u user -g userg WINEPREFIX=/opt/wineprefix wineboot --init


CMD ["/opt/cron_start.sh"]
