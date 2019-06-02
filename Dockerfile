FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
 echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
      git \
	    python-pip && \
 echo "**** install runtime packages ****" && \
  apt-get install -y \
      imagemagick \
      python-minimal && \
 echo "**** install calibre-web ****" && \
   if [ -z ${CALIBRE_RELEASE+x} ]; then \
	 CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/janeczku/calibre-web/releases/latest" \
	 | awk '/tag_name/{print $4;exit}' FS='[""]'); \
   fi && \
  curl -o \
    /tmp/calibre-web.tar.gz -L \
	https://github.com/janeczku/calibre-web/archive/${CALIBRE_RELEASE}.tar.gz && \
 mkdir -p \
	/app/calibre-web && \
 tar xf \
 /tmp/calibre-web.tar.gz -C \
	/app/calibre-web --strip-components=1 && \
 cd /app/calibre-web && \
 pip install --no-cache-dir -U -r \
	requirements.txt && \
 pip install --no-cache-dir -U -r \
	optional-requirements.txt && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*
    
# add local files
COPY root/ /

# ports and volumes
EXPOSE 8083
VOLUME /books /config
