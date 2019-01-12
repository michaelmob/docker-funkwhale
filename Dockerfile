FROM alpine:3.8


#
# Arguments
#

ARG FUNKWHALE_VERSION=0.17
ARG FUNKWHALE_REPO_URL=https://dev.funkwhale.audio/funkwhale/funkwhale
ARG FUNKWHALE_DOWNLOAD_URL=$FUNKWHALE_REPO_URL/-/jobs/artifacts/$FUNKWHALE_VERSION/download


#
# Environment
# https://dev.funkwhale.audio/funkwhale/funkwhale/blob/develop/deploy/env.prod.sample
#

# Funkwhale
ENV FUNKWHALE_PROTOCOL=http

# Django
ENV DJANGO_SETTINGS_MODULE=config.settings.production
ENV DJANGO_SECRET_KEY=funkwhale
ENV DJANGO_ALLOWED_HOSTS='127.0.0.1,*'

# Database
ENV DATABASE_URL=postgresql://funkwhale@:5432/funkwhale

# Media
ENV MEDIA_ROOT=/data/media
ENV MUSIC_DIRECTORY_PATH=/music

# Webserver
ENV NGINX_MAX_BODY_SIZE=100M


#
# Filesystem Setup
#

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz
ADD https://github.com/acoustid/chromaprint/releases/download/v1.4.2/chromaprint-fpcalc-1.4.2-linux-x86_64.tar.gz /tmp/fpcalc.tar.gz

ADD $FUNKWHALE_DOWNLOAD_URL?job=build_api /tmp/api.zip
ADD $FUNKWHALE_DOWNLOAD_URL?job=build_front /tmp/front.zip


#
# Installation
#

RUN \
	echo 'installing dependencies' && \
	apk add                \
		shadow             \
		youtube-dl         \
		gettext            \
		git                \
		postgresql         \
		postgresql-contrib \
		postgresql-dev     \
		python3-dev        \
		py3-psycopg2       \
		py3-pillow         \
		redis              \
		nginx              \
		musl-dev           \
		gcc                \
		unzip              \
		libldap            \
		libsasl            \
		ffmpeg             \
		libpq              \
		libmagic           \
		libffi-dev         \
		zlib-dev           \
		openldap-dev && \
	\
	\
	echo 'creating directories' && \
	mkdir -p /app /run/nginx /run/postgresql /var/log/funkwhale && \
	\
	\
	echo 'creating users' && \
	adduser -s /bin/false -D -H funkwhale funkwhale && \
	\
	\
	echo 'extracting archives' && \
	cd /app && \
	unzip /tmp/api.zip && \
	unzip /tmp/front.zip && \
	tar --strip 1 -C /usr/local/bin -xzf /tmp/fpcalc.tar.gz && \
	tar -C / -xzf /tmp/s6-overlay.tar.gz && \
	\
	\
	echo 'setting up nginx' && \
	rm /etc/nginx/conf.d/default.conf && \
	\
	\
	echo 'installing pip requirements' && \
	pip3 install --upgrade pip && \
	pip3 install setuptools wheel && \
	pip3 install -r /app/api/requirements.txt


#
# Entry
#

COPY ./root /
ENTRYPOINT ["/init"]
