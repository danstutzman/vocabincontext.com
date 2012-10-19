.PHONY: all clean
all: www/labeler-dev.html www/labeler-prod.html \
     www/index-dev.html   www/index-prod.html \
     www/segmenter.html
clean:
	rm -f www/labeler-dev.html www/labeler-prod.html
	rm -f www/index-dev.html   www/index-prod.html
	rm -f www/segmenter.html

www/labeler-dev.html: www/labeler.haml www/_loading.haml www/_js.haml
	haml www/labeler.haml > www/labeler-dev.html
www/labeler-prod.html: www/labeler.haml www/_loading.haml www/_js.haml
	ENV=production haml www/labeler.haml > www/labeler-prod.html
www/index-dev.html: www/index.haml www/_loading.haml www/_js.haml
	haml www/index.haml > www/index-dev.html
www/index-prod.html: www/index.haml www/_loading.haml www/_js.haml
	ENV=production haml www/index.haml > www/index-prod.html
www/segmenter.html: www/segmenter.haml www/_loading.haml www/_js.haml
	haml www/segmenter.haml > www/segmenter.html
