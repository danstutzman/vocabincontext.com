#!/bin/sh
cd `dirname $0`
echo "update tasks set started_at = null, completed_at = null, stdout = null, stderr = null, exit_status = null;" | sqlite3 db.sqlite3
