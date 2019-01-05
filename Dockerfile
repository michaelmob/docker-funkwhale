FROM alpine:3.8

# env
ENV FUNKWHALE_VERSION 0.17
ENV FUNKWHALE_REPO_URL https://dev.funkwhale.audio/funkwhale/funkwhale
ENV FUNKWHALE_DOWNLOAD_URL $FUNKWHALE_REPO_URL/-/jobs/artifacts/$FUNKWHALE_VERSION/download
ENV FUNKWHALE_PATH=/srv/funkwhale

# s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz /tmp
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# install dependencies
RUN apk add            \
	openssl            \
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
	openldap-dev

# funkwhale files
ADD $FUNKWHALE_DOWNLOAD_URL?job=build_api /tmp/api.zip
ADD $FUNKWHALE_DOWNLOAD_URL?job=build_front /tmp/front.zip
ADD $FUNKWHALE_REPO_URL/raw/develop/deploy/env.prod.sample /defaults/env

RUN mkdir -p /srv/funkwhale/config && \
	cd /srv/funkwhale && \
	unzip /tmp/api.zip && \
	unzip /tmp/front.zip

RUN mkdir -p /run/nginx && \
	rm /etc/nginx/conf.d/default.conf && \
	ln -s /defaults/funkwhale_nginx.conf /etc/nginx/conf.d/funkwhale.conf && \
	ln -s /defaults/funkwhale_proxy.conf /etc/nginx/funkwhale_proxy.conf

# pip requirements
RUN pip3 install --upgrade pip && \
	pip3 install setuptools wheel && \
	pip3 install -r /srv/funkwhale/api/requirements.txt

# postgresql setup
RUN mkdir -p /run/postgresql /var/lib/postgresql

# create users
RUN adduser -S funkwhale

# copy files to container and set entry script
COPY ./root /
ENTRYPOINT ["/init"]
