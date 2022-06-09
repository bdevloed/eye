FROM swipl:latest as builder

LABEL maintainer="https://github.com/bdevloed"

RUN apt-get -qq update
RUN apt-get -qqy install build-essential git flex

# Compile Carl: Another Rule Language
# cf https://github.com/melgi/carl/
RUN git clone https://github.com/melgi/carl.git && \
	cd carl && \
	make maintainer-clean && make CXXFLAGS='-O2 -Wall'

# Compile CTurtle:
#    a tool for parsing RDF 1.1 Turtle files
#    and outputting the resulting triples in "N3P" format.
# cf https://github.com/melgi/cturtle/
RUN git clone https://github.com/melgi/cturtle.git && \
	cd cturtle && \
	make maintainer-clean && make CXXFLAGS='-O2 -Wall' 
	
	
# Compile EYE
RUN git clone https://github.com/josd/eye.git && \
	cd eye && \
	./install.sh --prefix=/usr/local

FROM swipl:latest
LABEL maintainer="https://github.com/bdevloed"

# Install EYE:
# Copy artifacts from builder

COPY --from=builder /carl/carl /cturtle/cturtle /usr/local/bin/eye /usr/local/bin/
COPY --from=builder /usr/local/lib/eye.pvm /usr/local/lib/

ENTRYPOINT ["eye"]
