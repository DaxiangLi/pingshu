TARGETS	= downloader \
	  get_mp3_url \
	  create_mp3_urls_md \
	  layoutadm \
	  yamladm

all: ${TARGETS}

%: %.sh
	cp $< $@ && chmod +x $@

%: %.py
	cp $< $@ && chmod +x $@

clean:
clobber: clean
	rm -f ${TARGETS}
cl: clobber
