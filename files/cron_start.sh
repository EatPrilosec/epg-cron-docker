#!/bin/bash


CronCommand="/opt/epg-start.sh"




################################# do not edit if confused ########################################

LOCAL_GROUP_ID=$PGID
LOCAL_USER_ID=$PUID

USER_ID=${LOCAL_USER_ID:-9001}
GROUP_ID=${LOCAL_GROUP_ID:-250}

usermod -u $USER_ID user
groupmod -g $GROUP_ID userg
usermod -a -G sudo user
chmod -R user:user /opt
env >/opt/env
sudo -E --group=userg --user=user $CronCommand >/opt/cron.log 2>/opt/cron.log &
echo "$CronSchedule sudo -E --group=userg --user=user $CronCommand >/opt/cron.log 2>/opt/cron.log" >/opt/cron
crontab /opt/cron
touch /opt/cron.log
cron && tail -F /opt/cron.log
