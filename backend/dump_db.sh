#!/bin/sh
ROWS=`echo 'select count(*) from songs;' | sqlite3 db.sqlite3`
echo "$ROWS song(s):"
echo 'select * from songs;' | sqlite3 -header db.sqlite3
