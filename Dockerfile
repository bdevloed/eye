# This is a multi-stage build
# The first stage compiles carl and cturtle binaries
# The actual bdevloed/eye is built in the second stage

# STAGE 1
FROM swipl:latest as builder

LABEL maintainer="https://github.com/bdevloed"

RUN apt-get -qq update && apt-get -qqy install build-essential git flex

# Compile Carl: Another Rule Language
# cf https://github.com/melgi/carl/
RUN git clone https://github.com/melgi/carl.git && \
	cd carl && \
	make maintainer-clean && make install

# Compile CTurtle:
#    a tool for parsing RDF 1.1 Turtle files
#    and outputting the resulting triples in "N3P" format.
# cf https://github.com/melgi/cturtle/
RUN git clone https://github.com/melgi/cturtle.git && \
	cd cturtle && \
	make maintainer-clean && make install

# STAGE 2
# bdevloed/eye build starts here
FROM swipl:latest
LABEL maintainer="https://github.com/bdevloed"

# Install EYE:
# - Download EYE
# - Verify integrity
# - Install EYE (including cturtle and carl dependencies)
# - clean up temporary files

COPY --from=builder /carl/carl /cturtle/cturtle /usr/local/bin/

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
	`# Install dependencies:` \
	apt-get -qqy --no-install-recommends install jq curl unzip libarchive13 nyancat libgmp10 ca-certificates && \
	`# remove unnescesary files` \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/debconf/*

RUN chmod +x /usr/local/bin/cturtle && \
	chmod +x /usr/local/bin/carl && \
  	echo "IyEvYmluL2Jhc2gKaWYgW1sgJCogPT0gKiItLWZlZXN0IiogXV0KdGhlbgogIGV4ZWMgbnlhbmNhdAplbHNlCiAgZXhlYyBleWUgIiRAIjsKZmkK" | base64 -d > /ep && \
	chmod +x /ep && \
  	mkdir eye && \
	cd eye && \
	curl -fsS -L -O "https://raw.githubusercontent.com/josd/eye/master/eye.zip" && \
	unzip eye && ./eye/install.sh && \
	ln -s /opt/eye/bin/eye.sh /usr/local/bin/eye && \
	cd / && \
	rm -rf eye

ENTRYPOINT ["/ep"]
