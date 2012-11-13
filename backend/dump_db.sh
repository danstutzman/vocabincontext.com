#!/bin/sh
cd `dirname $0`
for TABLE in artists songs song_lines; do
  echo "Listing $TABLE table"
  echo "select * from $TABLE;" | sqlite3 -header db.sqlite3
done
