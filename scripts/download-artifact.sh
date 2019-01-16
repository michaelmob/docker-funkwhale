#!/bin/bash -eu

dest_dir=$1
artifact_version=$2
artifact_name=$3
repo_url="${REPO_URL-https://dev.funkwhale.audio/funkwhale/funkwhale}"
default_artifact_url="$repo_url/-/jobs/artifacts/$artifact_version/download?job=$artifact_name"
artifact_url=${ARTIFACT_URL-$default_artifact_url}

mkdir -p $dest_dir
dest_file="$dest_dir/$artifact_version-$artifact_name.zip"
echo "Downloading $artifact_url to $dest_file…"
wget "$artifact_url" -O $dest_file
echo "Unzipping $dest_file to $dest_dir"
unzip -o $dest_file -d $dest_dir
echo "Done!"
