#!/bin/bash 
#docker run -it --rm --name epgtool-node -v "$PWD":/usr/src/app --user 1000:1000 -w /usr/src/app node:20-bookworm 
wget 'http://m3u4u.com/xml/3wk1y2756mhzgxmrngz7' -qO/Storage/www/iptv/m3u4u-EPG-Guide-Intl.xml
wget 'http://m3u4u.com/xml/dqr6yw1zmqfm8qpjyx1w' -qO/Storage/www/iptv/m3u4u-EPG-Guide-US.xml
wget 'http://m3u4u.com/m3u/m/qjz2prrzm1c4rz4pkv7w' -qO/Storage/www/iptv/m3u4u-MergedPlaylist.m3u




exit 0

./epgtool.sh 



