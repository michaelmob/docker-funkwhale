FROM alpine:3.8


# env
# https://dev.funkwhale.audio/funkwhale/funkwhale/blob/develop/deploy/env.prod.sample
ENV FUNKWHALE_VERSION=0.17
ENV FUNKWHALE_PATH=/srv/funkwhale
ENV FUNKWHALE_FRONTEND_PATH=$FUNKWHALE_PATH/front/dist

ENV FUNKWHALE_HOSTNAME=yourdomain.funkwhale
ENV FUNKWHALE_PROTOCOL=http

ENV DJANGO_SETTINGS_MODULE=config.settings.production
ENV DJANGO_SECRET_KEY=funkwhale
ENV DJANGO_ALLOWED_HOSTS='127.0.0.1,localhost'

ENV DATABASE_URL=postgresql://funkwhale@:5432/funkwhale
ENV CACHE_URL=redis://127.0.0.1:6379/0

ENV STATIC_ROOT=$FUNKWHALE_PATH/data/static
ENV MEDIA_ROOT=$FUNKWHALE_PATH/data/media

ENV MUSIC_PATH=/music
ENV MUSIC_DIRECTORY_PATH=$MUSIC_PATH
ENV MUSIC_DIRECTORY_SERVE_PATH=$MUSIC_PATH

ENV RAVEN_ENABLED=false
ENV RAVEN_DSN=https://44332e9fdd3d42879c7d35bf8562c6a4:0062dc16a22b41679cd5765e5342f716@sentry.eliotberriot.com/5

ENV REVERSE_PROXY_TYPE=nginx
ENV NGINX_MAX_BODY_SIZE=30M

ENV DATABASE_PATH=/database


# download s6-overlay file
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz

# download chromaprint file
ADD https://github.com/acoustid/chromaprint/releases/download/v1.4.2/chromaprint-fpcalc-1.4.2-linux-x86_64.tar.gz /tmp/fpcalc.tar.gz

# download funkwhale files
ARG FUNKWHALE_REPO_URL=https://dev.funkwhale.audio/funkwhale/funkwhale
ARG FUNKWHALE_DOWNLOAD_URL=$FUNKWHALE_REPO_URL/-/jobs/artifacts/$FUNKWHALE_VERSION/download
ADD $FUNKWHALE_DOWNLOAD_URL?job=build_api /tmp/api.zip
ADD $FUNKWHALE_DOWNLOAD_URL?job=build_front /tmp/front.zip


# run installation
RUN \
	echo 'extracting s6-overlay archive' && \
	tar xzf /tmp/s6-overlay.tar.gz -C / && \
	\
	\
	echo 'installing dependencies' && \
	apk add                \
		youtube-dl         \
		git                \
		postgresql         \
		postgresql-contrib \
		postgresql-dev     \
		postgresql-client  \
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
	echo 'extracting funkwhale archives' && \
	mkdir -p $FUNKWHALE_PATH && \
	cd $FUNKWHALE_PATH && \
	unzip /tmp/api.zip && \
	unzip /tmp/front.zip && \
	\
	\
	echo 'setting up nginx' && \
	mkdir -p /run/nginx && \
	rm /etc/nginx/conf.d/default.conf && \
	ln -s /defaults/funkwhale_nginx.conf /etc/nginx/conf.d/funkwhale.conf && \
	ln -s /defaults/funkwhale_proxy.conf /etc/nginx/funkwhale_proxy.conf && \
	\
	\
	echo 'installing pip requirements' && \
	pip3 install --upgrade pip && \
	pip3 install setuptools wheel && \
	pip3 install -r $FUNKWHALE_PATH/api/requirements.txt && \
	\
	\
	echo 'extracting fpcalc archive' && \
	tar --strip 1 -C /usr/local/bin -xzf /tmp/fpcalc.tar.gz && \
	\
	\
	echo 'creating users' && \
	addgroup funkwhale && adduser -S funkwhale -G funkwhale && \
	\
	\
	echo 'creating directories' && \
	mkdir -p /run/postgresql $DATABASE_PATH $MUSIC_PATH && echo 1



# copy files to container and set entry script
COPY ./root /
ENTRYPOINT ["/init"]
