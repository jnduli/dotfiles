#!/usr/bin/env bash
#
# Take in docker_image name and ssh_host to upload image to
# Ensure you're part of docker group
# sudo groupadd docker && sudo usermod -aG docker $USER

image_name=$1
docker_host=$2

if [[ -z "$image_name" || -z "$docker_host" ]]; then
    echo "Usage: script_name image_name ssh://user@remote"
    exit 1
fi

echo "Uploading $image_name to $docker_host"
docker image save "$image_name" | gzip | pv | DOCKER_HOST="$docker_host" docker image load
