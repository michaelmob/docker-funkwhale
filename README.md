# Funkwhale Docker Container

[Funkwhale](https://funkwhale.audio/) is a modern, self-hosted, free and open-source music server.


## Usage
```sh
docker create \
	--name=funkwhale \
	-e FUNKWHALE_HOSTNAME=<yourdomain.funkwhale> \
	-v </path/to/data>:/data \
	-v </path/to/path>:/music:ro \
	-p 3030:80 \
	thetarkus/funkwhale
```


## Parameters
+ `-e PUID` - Optional user ID for volume ownership.
+ `-e PGID` - Optional group ID for volume ownership.
+ `-e FUNKWHALE_URL` - Domain of your Funkwhale instance.
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

### Importing Music
To import your music, open your Funkwhale instance in your browser and find the libraries page under "Add content" and create a library. Click the "details" button on your newly created library and get the library ID from the URL bar. It will look similar to the format of: `b8756c0d-839b-461f-b334-583983dc9ead`.  
Set the `LIBRARY_ID` environment variable (or replace it inside of the command) with your library ID, then run the command below.  
```sh
# For file structures similar to ./Artist/Album/Track.mp3
docker exec -it funkwhale manage import_files $LIBRARY_ID "/music/**/**/*.mp3" --in-place --async
```
For more information see the [Funkwhale docs on importing music](https://docs.funkwhale.audio/importing-music.html).
