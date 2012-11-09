#!/bin/bash -x
cd `dirname $0`/..

#rm -rf song_names
#rm -rf song_lyrics

mkdir -p song_names
rm -f song_names/1
echo "11 song11" >> song_names/1
echo "12 song12" >> song_names/1
echo "13 song13" >> song_names/1

mkdir -p song_lyrics
mkdir -p song_lyrics/1
echo "lyrics11" > song_lyrics/1/11
echo "lyrics12" > song_lyrics/1/12
echo "lyrics13" > song_lyrics/1/13
