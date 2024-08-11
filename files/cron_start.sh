#!/bin/bash


CronCommand="/opt/epg-start.sh"




################################# do not edit if confused ########################################



usermod -u $PUID user
groupmod -g $PGID userg
usermod -a -G sudo user
chown -R user:userg /opt
env >/opt/env
sudo -E --group=userg --user=user $CronCommand >/opt/cron.log 2>/opt/cron.log &
echo "$CronSchedule sudo -E --group=userg --user=user $CronCommand >/opt/cron.log 2>/opt/cron.log" >/opt/cron
crontab /opt/cron
touch /opt/cron.log
cron && tail -F /opt/cron.log
