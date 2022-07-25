FILES=dax/init.d dax/preload.d dax/processor.d

.PHONY: daxi dsh kunix

daxi:
	gdc $(FILES) -o daxi

dsh:
	gdc dax/modules/dsh.d -o usr/bin/dsh -lreadline

kunix:
	gdc usr/src/kap.d -o usr/dsh/kap -lreadline

all: kunix dsh daxi