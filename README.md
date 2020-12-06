# Funkwhale Docker Container

[Funkwhale](https://funkwhale.audio/) is a modern, self-hosted, free and open-source music server.


## Usage
```sh
docker run \
	--name=funkwhale \
	-e FUNKWHALE_HOSTNAME=<yourdomain.funkwhale> \
	-e NESTED_PROXY=0 \
	-v </path/to/data>:/data \
	-v </path/to/path>:/music:ro \
	-p 3030:80 \
	thetarkus/funkwhale
```


## Parameters
+ `-e PUID` - Optional user ID for volume ownership.
+ `-e PGID` - Optional group ID for volume ownership.
+ `-e FUNKWHALE_HOSTNAME` - Hostname of your Funkwhale instance.
+ `-e NESTED_PROXY` - Set to 1 when container is behind a reverse proxy.
+ `-v /data` - Volume to save media files and database.
+ `-v /music` - Path to your music.
+ `-p 3030:80` - Access Funkwhale on port 3030.


## Instructions
### Creation
Creation of the container will take a minute or two. The commands in the sections below will not work until the initialization is complete. For any subsequent runs (assuming you are re-using the `/data` volume), there will be no wait time.

### Create an initial superuser account
On the creation of your container, you will need to create an account. Running the following command will prompt you for a username, email, and password for your new account.
```sh
docker exec -it funkwhale manage createsuperuser
```

all this does is run `/usr/local/bin/manage createsuperuser` on the docker

if you are running on synology docker, in the funkwhale docker window go to Terminal, click the drop-down arrow by create and enter `/bin/sh`
in the terminal prompt, enter `/usr/local/bin/manage createsuperuser`


### Importing Music
To import your music, open your Funkwhale instance in your browser and find the libraries page under "Add content" and create a library. Click the "details" button on your newly created library and get the library ID from the URL bar. It will look similar to the format of: `b8756c0d-839b-461f-b334-583983dc9ead`.
Set the `LIBRARY_ID` environment variable (or replace it inside of the command) with your library ID, then run the command below.
```sh
# For file structures similar to ./Artist/Album/Track.mp3
docker exec -it funkwhale manage import_files $LIBRARY_ID "/music/**/**/*.mp3" --in-place --async
```
For more information see the [Funkwhale docs on importing music](https://docs.funkwhale.audio/importing-music.html).

### Running behind a proxy

In more involved deployments, you may have a reverse proxy in front of the container.

If it is the case, add the `-e NESTED_PROXY=1` flag to the docker run command, or ensure
`NESTED_PROXY=1` is available in the container environment.

### Build this image
This image is built and pushed automatically on `funkwhale/all-in-one`, for all Funkwhale releases and for the development version as well (using the `develop` tag).

If you want to build it manually, you can run the following:
```bash
image_name='mycustomimage'  # choose a name for the image
version='develop'  # replace 'develop' with any tag or branch name
arch='amd64'  # set your cpu architecture

# download Funkwhale front and api artifacts and nginx configuration
./scripts/download-artifact.sh src/ $version build_front
./scripts/download-artifact.sh src/ $version build_api
./scripts/download-nginx-template.sh src/ $version
docker build --build-arg $arch -t $image_name:$version .
```
