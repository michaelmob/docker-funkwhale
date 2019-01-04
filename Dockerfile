FROM alpine:3.8

# s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz /tmp
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# install dependencies
RUN apk add            \
	git                \
	postgresql         \
	postgresql-contrib \
	postgresql-dev     \
	postgresql-client  \
	python3-dev        \
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
ADD https://dev.funkwhale.audio/funkwhale/funkwhale/-/jobs/artifacts/0.17/download?job=build_api /tmp/api.zip
ADD https://dev.funkwhale.audio/funkwhale/funkwhale/-/jobs/artifacts/0.17/download?job=build_front /tmp/front.zip

# extract files
RUN mkdir -p /srv/funkwhale && cd /srv/funkwhale && \
	unzip /tmp/api.zip && unzip /tmp/front.zip

# env file
RUN ln -s /defaults/env /srv/funkwhale/api/.env && \
	ln -s /defaults/funkwhale_nginx /etc/nginx/conf.d/funkwhale.conf && \
	ln -s /defaults/funkwhale_proxy.conf /etc/nginx/

# pip requirements
RUN pip3 install --upgrade pip && \
	pip3 install setuptools wheel && \
	pip3 install -r /srv/funkwhale/api/requirements.txt

# postgresql setup
RUN mkdir -p /run/postgresql /var/lib/postgresql

# create users
RUN adduser -S funkwhale

# ports
EXPOSE 80
EXPOSE 8000

# copy files to container and set entry script
COPY ./root /
ENTRYPOINT ["/init"]
