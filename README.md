# Funkwhale Self-Contained Docker Container

[Funkwhale](https://funkwhale.audio/) is a modern, self-hosted, free and open-source music server.


## Usage
```sh
docker create \
	--name=funkwhale \
	-e FUNKWHALE_VERSION=0.17 \
	-e FUNKWHALE_HOSTNAME='yourdomain.funkwhale' \
	-e LIBRARY_ID=<generated_library_id> \
	-v </path/to/data>:/data \
	-v </path/to/path>:/music:ro \
	-p 3030:80 \
	thetarkus/funkwhale
```


## Parameters
+ `-e FUNKWHALE_VERSION` - Version of Funkwhale to use.
+ `-e FUNKWHALE_HOSTNAME` - Domain of your Funkwhale instance.
+ `-v /data` - Volume to save media files and database.
+ `-v /music` - Path to your music.
+ `-p 3030:80` - Access Funkwhale on port 3030.


## Instructions

### Log in to your Funkwhale instance
On the creation of your container, a default superuser account will be created named `admin` with the password `admin`. Change the username and password as soon as you log in. Find the admin user edit page link in the [Useful URLs](#useful-urls) section below.

### Manual Import
To manually import your music, open your Funkwhale instance in your browser and find the libraries page under "Add content" and create a library. Click the "details" button on your newly created library and get the library ID from the URL bar. It will look similar to the format of: `b8756c0d-839b-461f-b334-583983dc9ead`.  
In your terminal, enter the shell inside your container, by running something like `docker exec -it funkwhale sh` depending on the container name you chose.  
Inside of the container you can import your music by running the `import_files` command. For example: `import_files $LIBRARY_ID "/music/**/*.mp3" --in-place`. For more information see the [Funkwhale docs on importing music](https://docs.funkwhale.audio/importing-music.html).

### Automatic Import
To automatically import your music, take your library ID (see above) and set it as the value of the `LIBRARY_ID` environment variable in your container. You can also use just the first segment, for example: `LIBRARY_ID=b8756c0d`. Restart your container and the import process will start.

#### Useful URLs
Libraries URL: `http://yourdomain.funkwhale/content/libraries/`  
Admin Account Edit Page: `http://yourdomain.funkwhale/api/admin/users/user/1/change/`
