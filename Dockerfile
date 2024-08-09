ARG TAG=20-bookworm
ARG DEBIAN_FRONTEND=noninteractive
FROM node:${TAG} as base

RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -y install cron sudo wget gnupg


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


ENV USER_ID 9001
ENV GROUP_ID 255361
RUN addgroup --gid $GROUP_ID userg
RUN useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m user
ENV HOME /home/user
RUN chown -R user:userg $HOME
RUN echo 'user:123' | chpasswd

ENV WINEPREFIX $HOME

RUN wineboot --init


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
#RUN chown 1000:1000 -R /opt
WORKDIR /opt

FROM base AS add
ADD  --chmod=777 files* /opt/
RUN chmod -R 777 /opt

ENV CronSchedule="*/1 * * * *"
ENV PUID="1000"
ENV PGID="1000"

CMD ["/opt/cron_start.sh"]
