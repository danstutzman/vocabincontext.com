.PHONY: all clean
all: labeler-dev.html labeler-prod.html \
     index-dev.html   index-prod.html \
     segmenter.html
clean:
	rm -f labeler-dev.html labeler-prod.html
	rm -f index-dev.html   index-prod.html
	rm -f segmenter.html

labeler-dev.html: labeler.haml
	haml labeler.haml > labeler-dev.html
labeler-prod.html: labeler.haml
	ENV=production haml labeler.haml > labeler-prod.html
index-dev.html: index.haml
	haml index.haml > index-dev.html
index-prod.html: index.haml
	ENV=production haml index.haml > index-prod.html
segmenter.html: segmenter.haml
	haml segmenter.haml > segmenter.html
