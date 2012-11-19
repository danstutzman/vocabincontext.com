.PHONY: all clean lint
all: backend/public/js/main-compiled.js \
     backend/public/js/main-compiled-for-coverage.js
clean:
	rm -f backend/public/js/main-compiled.js
	rm -f backend/public/js/main-compiled-for-coverage.js
lint:
	find app spec -name "*.coffee" | xargs node_modules/coffeelint/bin/coffeelint

backend/public/js/main-compiled.js: backend/public/js/main.js \
                                    app/*.coffee
	node tools/r.js -o tools/rjs-build-config.js
	cp backend/public-building/js/main.js backend/public/js/main-compiled.js
	rm -rf backend/public-building

backend/public/js/main-compiled-for-coverage.js: backend/public/js/main.js \
                                                 app/*.coffee spec/*.coffee
	node tools/r.js -o tools/rjs-build-config.js optimize=none
	java -jar ../JSCover/target/dist/JSCover-all.jar -fs backend/public-building backend/public-coverage
	cat backend/public/js/almond.js backend/public-coverage/js/main_with_tests.js > backend/public/js/main-compiled-for-coverage.js
	rm -rf backend/public-building backend/public-coverage
