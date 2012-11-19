.PHONY: dev prod clean lint
dev: www/segmenter-dev.html \
     www/index-dev.html \
     www/TestRunner.html \
     lint
prod: www/segmenter-prod.html \
     www/index-prod.html \
     www/js/main2.coffee www/js/main.js www/js/app/*.coffee \
     lint
	node tools/r.js -o tools/rjs-build-config.js
clean:
	rm -f www/segmenter-dev.html www/segmenter-prod.html
	rm -f www/index-dev.html   www/index-prod.html
	rm -f www/TestRunner.html
	rm -rf www-built
	rm -f backend/public/js/main-compiled.js
	rm -f backend/public/js/main-compiled-for-coverage.js
lint:
	find www/js -name "*.coffee" | xargs node_modules/coffeelint/bin/coffeelint

www/segmenter-dev.html: www/segmenter.haml www/_loading.haml www/_js.haml
	haml www/segmenter.haml > www/segmenter-dev.html
www/segmenter-prod.html: www/segmenter.haml www/_loading.haml www/_js.haml
	ENV=production haml www/segmenter.haml > www/segmenter-prod.html

www/index-dev.html: www/index.haml www/_loading.haml www/_js.haml
	haml www/index.haml > www/index-dev.html
www/index-prod.html: www/index.haml www/_loading.haml www/_js.haml
	ENV=production haml www/index.haml > www/index-prod.html

www/TestRunner.html: www/TestRunner.haml
	haml www/TestRunner.haml > www/TestRunner.html
www/TestRunner-prod.html: www/TestRunner.haml
	ENV=production haml www/TestRunner.haml > www/TestRunner-prod.html

backend/public/js/main-compiled.js: www/js/main2.coffee \
                                    www/js/main.js www/js/app/*.coffee
	node tools/r.js -o tools/rjs-build-config.js
	cp backend/public-building/js/main.js backend/public/js/main-compiled.js
	rm -rf backend/public-building
backend/public/js/main-compiled-for-coverage.js:
	node tools/r.js -o tools/rjs-build-config.js optimize=none
	java -jar ../JSCover/target/dist/JSCover-all.jar -fs backend/public-building backend/public-coverage
	cat backend/public/js/almond.js backend/public-coverage/js/main_with_tests.js > backend/public/js/main-compiled-for-coverage.js
	rm -rf backend/public-building backend/public-coverage
