#!/bin/bash 
DLNow=0
ThisDLChk=$(date --utc +'%s')

if [[ -f LastDL ]; then
  LastDlCheck=$(cat LastDL)
fi

if [[ -z "$LastDlCheck" ]]
then
  DLNow=1
fi

ChkResult=$(($ThisDLChk - $LastDlCheck))

if [ $ChkResult -ge 3600 ]]
then
  DLNow=1
fi

if [[ $DLNow -eq 1 ]]
then
  rm -f LastDL
  wget 'http://m3u4u.com/xml/3wk1y2756mhzgxmrngz7' -qO /opt/out/m3u4u-EPG-Guide-Intl.xml
  wget 'http://m3u4u.com/xml/dqr6yw1zmqfm8qpjyx1w' -qO /opt/out/m3u4u-EPG-Guide-US.xml
  wget 'http://m3u4u.com/m3u/m/qjz2prrzm1c4rz4pkv7w' -qO /opt/out/m3u4u-MergedPlaylist.m3u
fi

if [[ ! -f LastDL ]]; then
    echo $(date --utc +'%s') > LastDL
fi

exit 0

