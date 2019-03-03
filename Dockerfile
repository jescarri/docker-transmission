FROM alpine:3.9

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl \
	findutils \
	jq \
	openssl \
	p7zip \
	python \
	rsync \
	tar \
	transmission-cli \
	transmission-daemon \
	unrar \
	unzip && \
 echo "**** install third party themes ****" && \
 curl -o \
	/tmp/combustion.zip -L \
	"https://github.com/Secretmapper/combustion/archive/release.zip" && \
 unzip \
	/tmp/combustion.zip -d \
	/ && \
 mkdir -p /tmp/twctemp && \
 TWCVERSION=$(curl -sX GET "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
	/tmp/twc.tar.gz -L \
	"https://github.com/ronggang/transmission-web-control/archive/${TWCVERSION}.tar.gz" && \
 tar xf \
	/tmp/twc.tar.gz -C \
	/tmp/twctemp --strip-components=1 && \
 mv /tmp/twctemp/src /transmission-web-control && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*

RUN deluser --remove-home transmission || true && \
    delgroup transmission || true &&\
    addgroup -g 1001 transmision && \
    adduser -G transmision -h /home/transmission -D -u 1001 transmission


WORKDIR /home/transmission
USER transmission
EXPOSE 9091 51413
VOLUME /config /downloads /watch
ENTRYPOINT ["/usr/bin/transmission-daemon"]
CMD ["$@"]
