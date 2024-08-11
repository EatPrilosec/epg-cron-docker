#!/bin/bash 
echo $(pwd)
sleep 3

if [ -d /opt/epgtool ]; then
  rm -rf /opt/epgtool
fi

git clone --depth 1 -b master https://github.com/iptv-org/epg.git /opt/epgtool

if [ ! -f /opt/out/epgtool-channels.xml ]; then
  WINEPREFIX=/opt
  wineboot --init
  ln -s /opt/epgtool/sites /opt/sites
  cp /opt/out/m3u4u-MergedPlaylist.m3u /opt/m3u4u-MergedPlaylist.m3u || exit 2
  
  chmod +x /opt/m3u2xml.exe
  /opt/m3u2xml.exe --m3u "m3u4u-MergedPlaylist.m3u" --SitesDir "sites" --OutName "epgtool-channels" --SiteIgnoreFile "IgnoreSites.txt" 
  rm /opt/sites

  [ -f /opt/epgtool-channels.xml ] || exit 2
  
fi

GUIDE_XML_full=/opt/out/epgtool-Guide.xml 
cp /opt/epgtool-channels.xml /opt/epgtool/epgtool-channels.xml
cd /opt/epgtool

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
