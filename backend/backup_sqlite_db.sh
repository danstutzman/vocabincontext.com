#!/bin/bash
cd `dirname $0`
DATE=`date "+%Y-%m-%dT%H:%M:%S"`
OUT_FILENAME="$DATE.sql"
echo '.dump' | sqlite3 ./db.sqlite3 > $OUT_FILENAME
echo $OUT_FILENAME
