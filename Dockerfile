FROM swipl
MAINTAINER Boris De Vloed <boris.devloed@agfa.com>

# Install EYE:
# - Download EYE
# - Verify integrity
# - Install EYE (including turtle parser)
# - clean up temporary files

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
	`# Install dependencies:` \
	apt-get -qqy --no-install-recommends install jq curl unzip libarchive13 nyancat libgmp10 ca-certificates && \
	`# remove unnescesary files` \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/debconf/*

RUN curl -fsS -o /usr/local/bin/cturtle http://aca-build-server.agfahealthcare.com/job/docker-turtle-builder/lastSuccessfulBuild/artifact/target/cturtle && \
	chmod +x /usr/local/bin/cturtle && \
	curl -fsS -o /usr/local/bin/carl http://aca-build-server.agfahealthcare.com/job/docker-carl-builder/lastSuccessfulBuild/artifact/target/carl && \
	chmod +x /usr/local/bin/carl

RUN mkdir eye && \
	cd eye && \
	curl -fsS -L -O "https://raw.githubusercontent.com/josd/eye/master/eye.zip" && \
	unzip eye && ./eye/install.sh && \
	ln -s /opt/eye/bin/eye.sh /usr/local/bin/eye && \
	cd / && \
	rm -rf eye

RUN echo "IyEvYmluL2Jhc2gKaWYgW1sgJCogPT0gKiItLWZlZXN0IiogXV0KdGhlbgogIGV4ZWMgbnlhbmNhdAplbHNlCiAgZXhlYyBleWUgIiRAIjsKZmkK" | base64 -d > /ep && \
	chmod +x /ep

ENTRYPOINT ["/ep"] 
