#!/bin/bash -x

if [ "$1" == "" ]; then
  echo "You must specify the Youtube ID as the first parameter (for example, $0 ALf5wpTokKA)" 1>&2
  exit 1
fi
VIDEO_ID="$1"

python tools/youtube-dl.py "http://www.youtube.com/watch?v=$VIDEO_ID"

# -vn ignores the video, just looks at audio
# -acodec copy keeps the same audio codec
#ffmpeg -i "$VIDEO_ID.flv" -vn -acodec copy "$VIDEO_ID.mp4"
ffmpeg -i "$VIDEO_ID.flv" -vn -acodec mp3 "$VIDEO_ID.mp3"

if [ "$?" != "0" ]; then exit 1; fi

rm "$VIDEO_ID.flv"
