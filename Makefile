.PHONY: all clean
all: www/segmenter-dev.html www/segmenter-prod.html \
     www/index-dev.html   www/index-prod.html \
     www-built/js/main.js
clean:
	rm -f www/segmenter-dev.html www/segmenter-prod.html
	rm -f www/index-dev.html   www/index-prod.html
	rm -rf www-built

www/segmenter-dev.html: www/segmenter.haml www/_loading.haml www/_js.haml
	haml www/segmenter.haml > www/segmenter-dev.html
www/segmenter-prod.html: www/segmenter.haml www/_loading.haml www/_js.haml
	ENV=production haml www/segmenter.haml > www/segmenter-prod.html
www/index-dev.html: www/index.haml www/_loading.haml www/_js.haml
	haml www/index.haml > www/index-dev.html
www/index-prod.html: www/index.haml www/_loading.haml www/_js.haml
	ENV=production haml www/index.haml > www/index-prod.html
www-built/js/main.js: www/js/main2.coffee www/js/main.js www/js/app/*.coffee
	node_modules/grunt/bin/grunt release
