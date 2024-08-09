#!/bin/bash 
echo $(pwd)
ls $(pwd)
#sleep 10
if [ -d ./epgtool ]; then
  rm -rf ./epgtool
fi

git clone --depth 1 -b master https://github.com/iptv-org/epg.git ./epgtool

CHANNELS_XML=../epgtool-channels.xml
GUIDE_XML_full=$(pwd)/epgtool-Guide.xml 
cp epgtool-channels.xml ./epgtool/epgtool-channels.xml
cd ./epgtool

npm install

#npm update
npm run api:load
npm run grab -- --channels=epgtool-channels.xml --days 2 --output=epgtool-Guide.xml

cp epgtool-Guide.xml $GUIDE_XML_full

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



if [ -d ./epgtool ]; then
  rm -r ./epgtool
fi

exit
