FROM alpine:3.8
MAINTAINER thetarkus

#
# Installation
#

RUN \
	echo 'installing dependencies' && \
	apk add                \
	shadow             \
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
	adduser -s /bin/false -D -H funkwhale funkwhale


#
# Arguments
#

ARG FUNKWHALE_VERSION=0.17
ARG FUNKWHALE_REPO_URL=https://dev.funkwhale.audio/funkwhale/funkwhale
ARG FUNKWHALE_DOWNLOAD_URL=$FUNKWHALE_REPO_URL/-/jobs/artifacts/$FUNKWHALE_VERSION/download

RUN \
	echo 'downloading archives' && \
	wget https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz -O /tmp/s6-overlay.tar.gz && \
	wget "$FUNKWHALE_DOWNLOAD_URL?job=build_api" -O /tmp/api.zip && \
	wget "$FUNKWHALE_DOWNLOAD_URL?job=build_front" -O /tmp/front.zip && \
	\
	\
	echo 'extracting archives' && \
	cd /app && \
	unzip /tmp/api.zip && \
	unzip /tmp/front.zip && \
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
	pip3 install -r /app/api/requirements.txt && \
	\
	\
	echo 'removing temp files' && \
	rm /tmp/*.zip /tmp/*.tar.gz


#
# Environment
# https://dev.funkwhale.audio/funkwhale/funkwhale/blob/develop/deploy/env.prod.sample
# (We put environment at the end to avoid busting build cache on each ENV change)

ENV FUNKWHALE_HOSTNAME=yourdomain.funkwhale \
	FUNKWHALE_PROTOCOL=http \
	DJANGO_SETTINGS_MODULE=config.settings.production \
	DJANGO_SECRET_KEY=funkwhale \
	DJANGO_ALLOWED_HOSTS='127.0.0.1,*' \
	DATABASE_URL=postgresql://funkwhale@:5432/funkwhale \
	MEDIA_ROOT=/data/media \
	MUSIC_DIRECTORY_PATH=/music \
	NGINX_MAX_BODY_SIZE=100M


#
# Entrypoint
#

COPY ./root /
ENTRYPOINT ["/init"]
