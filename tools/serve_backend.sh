#!/bin/sh
cd `dirname $0`/..

if [ -e /usr/bin/google-chrome ]; then
  # Ubuntu
   /usr/bin/google-chrome "http://localhost:9393" >/dev/null 2>/dev/null &
else
  # Mac
  open "http://localhost:9393"
fi

cd backend
ENV="$ENV" bundle exec rerun -- rackup --port 9393 config.ru
