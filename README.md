# funkwhale docker container

[Funkwhale](https://funkwhale.audio/) is a modern, self-hosted, free and open-source music server.

## Usage
```sh
docker create \
	--name=funkwhale \
	-e LIBRARY_ID=<generated_library_id> \
	-v </path/to/database>:/database \
	-v </path/to/music>:/music:ro \
	funkwhale
```

## Instructions
Being written...
