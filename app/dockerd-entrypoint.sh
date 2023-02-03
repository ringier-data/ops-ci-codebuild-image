#!/bin/sh

echo "Running DIND inside image 354470900895.dkr.ecr.eu-central-1.amazonaws.com/svc-rcplus-devops-codebuild:0.2.3"

set -e

/usr/bin/dockerd \
	--log-level=error \
	--host=unix:///var/run/docker.sock \
	--host=tcp://127.0.0.1:2375 \
	--storage-driver=overlay2 >/dev/null 2>&1 &

tries=0
d_timeout=60
until docker info >/dev/null 2>&1
do
	if [ "$tries" -gt "$d_timeout" ]; then
		echo "Timed out trying to connect to internal docker host." >&2
		exit 1
	fi
        tries=$(( $tries + 1 ))
	sleep 1
done

eval "$@"
