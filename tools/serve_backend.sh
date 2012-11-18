#!/bin/sh
cd `dirname $0`/..

# Mac
open "http://localhost:9393"

# Ubuntu
google-chrome "http://localhost:9393" >/dev/null 2>/dev/null &

cd backend
ENV="$ENV" bundle exec rerun -- rackup --port 9393 config.ru
