#!/bin/bash -x
cd `dirname $0`/..

if [ "$1" == "" ]; then
  echo 1>&2 "Arg 1: youtube video id"
  exit 1
fi
VIDEO_ID="$1"

if [ "$2" == "" ]; then
  echo 1>&2 "Arg 2: beginning of clip in seconds, minus fade-in time"
  exit 1
fi
OFFSET_SECONDS="$2"

if [ "$3" == "" ]; then
  echo 1>&2 "Arg 3: duration of clip in seconds, including both fade times"
  exit 1
fi
DURATION_SECONDS="$3"

if [ "$4" == "" ]; then
  echo 1>&2 "Arg 4: output filename, including .mp3 extension"
  exit 1
fi
OUTPUT_FILENAME="$4"

if [ ! -e "backend/youtube_downloads/$VIDEO_ID.wav" ]; then
  # -ac 1 changes stereo to mono
  ffmpeg -i "backend/youtube_downloads/$VIDEO_ID.mp4" -ac 1 \
    "backend/youtube_downloads/$VIDEO_ID.wav"
fi

sox "backend/youtube_downloads/$VIDEO_ID.wav" \
  "backend/youtube_downloads/$OUTPUT_FILENAME.wav" \
  trim "$OFFSET_SECONDS" "$DURATION_SECONDS"

# 1 second fade in
# 1 second fade out
# 64 kbps MP3 compression
sox "backend/youtube_downloads/$OUTPUT_FILENAME.wav" \
  "backend/youtube_downloads/$OUTPUT_FILENAME.fade.wav" \
  fade h 0:1 0 0:1

rm "backend/youtube_downloads/$OUTPUT_FILENAME.wav"

lame -b 64 "backend/youtube_downloads/$OUTPUT_FILENAME.fade.wav" \
  "backend/youtube_downloads/$OUTPUT_FILENAME"

rm "backend/youtube_downloads/$OUTPUT_FILENAME.fade.wav"
