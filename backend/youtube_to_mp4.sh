#!/bin/bash -x
cd `dirname $0`/..
ROOT_DIR=`pwd`

if [ "$1" == "" ]; then
  echo "You must specify the Youtube ID as the first parameter (for example, $0 ALf5wpTokKA)" 1>&2
  exit 1
fi
VIDEO_ID="$1"

if [ -e "$ROOT_DIR/backend/youtube_downloads/$VIDEO_ID.mp4" ]; then
  echo "$VIDEO_ID.mp4 already exists"
  exit 0
fi

cd "$ROOT_DIR/backend/youtube_downloads"
if [ ! -e "$VIDEO_ID.flv" ]; then
  python "$ROOT_DIR/tools/youtube-dl.py" --continue "http://www.youtube.com/watch?v=$VIDEO_ID"
  if [ "$?" != "0" ]; then exit 1; fi
fi

# -vn ignores the video, just looks at audio
# -acodec copy keeps the same audio codec
# -acodec mp3 keeps mp3s as is, recodes mp4s to mp3
# -y overwrites without asking
ffmpeg -y -i "$VIDEO_ID.flv" -vn -acodec copy "$VIDEO_ID.mp4"

if [ "$?" != "0" ]; then exit 1; fi

rm "$VIDEO_ID.flv"
