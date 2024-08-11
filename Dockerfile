ARG TAG=bookworm
FROM debian:${TAG} as base

SHELL ["/bin/bash", "-c"]

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

RUN mkdir -p /app /out
RUN chown $USER_ID:$GROUP_ID -R /app /out

FROM base AS add
ADD  --chmod=777 files* /app/
RUN chmod -R 777 /app

ENV CronSchedule="*/1 * * * *"
ENV PUID="1000"
ENV PGID="1000"

WORKDIR /opt

# Wine-Init
RUN mkdir -p /opt/wine/mono && \
wget "https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.tar.xz" -P /opt/wine/mono && \
tar -xf /opt/wine/mono/wine-mono-7.4.0-x86.tar.xz -C /opt/wine/mono && \
rm /opt/wine/mono/wine-mono-7.4.0-x86.tar.xz

ENV WINEPREFIX $HOME/wineprefix
RUN sudo -E -u user -g userg wineboot --init

ENV CronCommand /app/epg-start.sh


CMD << EndOfStartScript

echo test 
echo test2 
usermod -u $PUID user 
groupmod -g $PGID userg
usermod -a -G sudo user 
chown -R user:userg $HOME 
chown -R user:userg $WINEPREFIX
chown -R user:userg /app
env >/app/env
sudo -E --group=userg --user=user $CronCommand >/home/user/cron.log 2>/home/user/cron.log & 
echo "$CronSchedule sudo -E --group=userg --user=user $CronCommand >/home/user/cron.log 2>/home/user/cron.log" >/home/user/cronfile 
crontab /home/user/cronfile 
cron & 
tail -F /opt/cron.log

EndOfStartScript
