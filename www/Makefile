.PHONY: all clean
all: labeler-dev.html labeler-prod.html
clean:
	rm -f labeler-dev.html labeler-prod.html
labeler-dev.html: labeler.haml
	haml labeler.haml > labeler-dev.html
labeler-prod.html: labeler.haml
	ENV=production haml labeler.haml > labeler-prod.html
