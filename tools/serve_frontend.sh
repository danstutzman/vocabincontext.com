#!/bin/sh
cd `dirname $0`/..

make
if [ "$?" != "0" ]; then exit 1; fi

# Mac
open "http://localhost:8888/www/segmenter-dev.html?song=dutty-love"

# Ubuntu
google-chrome "http://localhost:8888/www/segmenter-dev.html?song=dutty-love" >/dev/null 2>/dev/null &

node tools/web-server.js
