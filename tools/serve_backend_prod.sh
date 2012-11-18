#!/bin/sh
cd `dirname $0`/..
make lint
make backend/public/js/main-compiled.js
ENV=production tools/serve_backend.sh
