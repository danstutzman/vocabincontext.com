#!/bin/bash

if [ "$1" == "" ]; then
  echo "You must specify the Youtube ID as the first parameter (for example, $0 ALf5wpTokKA > ALf5wpTokKA.mp3)" 1>&2
  exit 1
fi
VIDEO_ID="$1"

#VIDEO_ID='XV7DOBFj-KI' # Dutty Love
#VIDEO_ID='SMM1WhmlQzI' # Hasta Abajo
#VIDEO_ID='ALf5wpTokKA' # shortest video on youtube

OUT=`curl -s --data "url=http://www.youtube.com/watch?v=$VIDEO_ID" "http://www.makeitmp3.com/check.php"`
#OUT="WAIT|24|XV7DOBFj-KI|YouTube|qc|./view/YouTube/XV7DOBFj-KI/3d5c8dd544bda97a0f70e50933cc3934/|"
#echo $OUT

RELATIVE_URL=`echo $OUT | awk "-F|" '{print $6}'`
#RELATIVE_URL='./view/YouTube/XV7DOBFj-KI/3d5c8dd544bda97a0f70e50933cc3934/'
#echo $RELATIVE_URL

VIEW_URL=`echo $RELATIVE_URL | sed 's/\./http:\/\/www.makeitmp3.com/'`
#VIEW_URL="http://www.makeitmp3.com/view/YouTube/XV7DOBFj-KI/3d5c8dd544bda97a0f70e50933cc3934/"
#echo $VIEW_URL

LINK_HTML=`curl -s "$VIEW_URL" | grep '<a class="download" href=' | tail -1`
#LINK_HTML='<a class="download" href="http://www.makeitmp3.com/load/YouTube/XV7DOBFj-KI/3073280d39d4ad8ed7809ed2cbd98bab/">Don Omar Ft. Natti Natasha - Dutty Love [Official Version] ???NEW ?? 2011???</a>'
#echo $LINK_HTML

LOAD_URL=`echo "$LINK_HTML" | sed 's/.*href="\([^"]*\)".*/\1/'`
#LOAD_URL="http://www.makeitmp3.com/load/YouTube/XV7DOBFj-KI/3073280d39d4ad8ed7809ed2cbd98bab/"
#echo $LOAD_URL

#curl -D 302.txt $LOAD_URL
curl -s -L $LOAD_URL
