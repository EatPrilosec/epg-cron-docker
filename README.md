# epg-cron

docker run -d \
  --hostname epg-cron-docker --name epg-cron-docker \
  -v /Storage:/Storage \
  -e PUID=1000 \
  -e PUID=1000 \
  -e CronSchedule="0 22 * * *" \
  -e EPG_ARGS="grab -- --site=example.com" \
  ghcr.io/eatprilosec/epg-cron
