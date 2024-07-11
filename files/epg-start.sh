#!/bin/bash

git clone --depth 1 -b master https://github.com/iptv-org/epg.git epg
cd epg
npm install

npm run $EPG_ARGS
