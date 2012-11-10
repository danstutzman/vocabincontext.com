#!/bin/bash
cd `dirname $0`/..

make www/TestRunner-prod.html

cp www/js/main_with_tests.js www/js/main.js
node tools/r.js -o tools/rjs-build-config.js optimize=none
git checkout www/js/main.js

java -jar ../JSCover/target/dist/JSCover-all.jar -fs www-built www-coverage

PARAMS="soundManager=fakeSoundManager"
BROWSER_URL="http://localhost:8888/www-coverage/TestRunner-prod.html?$PARAMS"
BROWSER=/usr/bin/google-chrome # location for Linux
if [ -e "$BROWSER" ]; then
  $BROWSER "$BROWSER_URL"
else
  open "$BROWSER_URL" # for Mac
fi
