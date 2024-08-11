#!/bin/bash 
echo $(pwd)
sleep 3

if [ -d /app/epgtool ]; then
  rm -rf /app/epgtool
fi

git clone --depth 1 -b master https://github.com/iptv-org/epg.git /app/epgtool

if [ ! -f /out/epgtool-channels.xml ]; then
  wineboot --init
  ln -s /app/epgtool/sites /app/sites
  cp /out/m3u4u-MergedPlaylist.m3u /app/m3u4u-MergedPlaylist.m3u || exit 2
  
  chmod a+x /app/m3u2xml.exe
  /app/m3u2xml.exe --m3u "m3u4u-MergedPlaylist.m3u" --SitesDir "sites" --OutName "epgtool-channels" --SiteIgnoreFile "IgnoreSites.txt" 
  rm /app/sites

  [[ -f /app/epgtool-channels.xml ]] || exit 2
  cp /app/epgtool-channels.xml /app/epgtool/epgtool-channels.xml
  cp /app/epgtool-channels.m3u /out/epgtool-channels.m3u
  
fi

GUIDE_XML_full=/out/epgtool-Guide.xml 
cd /app/epgtool

npm install
npm run api:load
npm run grab -- --channels=epgtool-channels.xml --days 2 --output=epgtool-Guide.xml

mv epgtool-Guide.xml $GUIDE_XML_full

sed -i 's/\&apos;/XMLAPOSXMLAPOSXMLAPOSXMLAPOS/g'  $GUIDE_XML_full
sed -i 's/\&quot;/XMLQUOTXMLQUOTXMLQUOTXMLQUOT/g'  $GUIDE_XML_full
sed -i 's/\&amp;/XMLAMPXMLAMPXMLAMPXMLAMP/g'  $GUIDE_XML_full
sed -i 's/\&lt;/XMLLTXMLLTXMLLTXMLLTXMLLT/g'  $GUIDE_XML_full
sed -i 's/\&gt;/XMLGTXMLGTXMLGTXMLGTXMLGT/g'  $GUIDE_XML_full
sed -i 's/\&/\&amp;/g'  $GUIDE_XML_full
sed -i 's/XMLAPOSXMLAPOSXMLAPOSXMLAPOS/\&apos;/g'  $GUIDE_XML_full
sed -i 's/XMLQUOTXMLQUOTXMLQUOTXMLQUOT/\&quot;/g'  $GUIDE_XML_full
sed -i 's/XMLAMPXMLAMPXMLAMPXMLAMP/\&amp;/g'  $GUIDE_XML_full
sed -i 's/XMLLTXMLLTXMLLTXMLLTXMLLT/\&lt;/g'  $GUIDE_XML_full
sed -i 's/XMLGTXMLGTXMLGTXMLGTXMLGT/\&gt;/g'  $GUIDE_XML_full

[ -d ./epgtool ] && rm -r ./epgtool

exit 0
