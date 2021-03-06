#!/usr/bin/env bash

SCRIPT_DIR=$(realpath $(dirname $0))

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run --rm -it --name ssdf-devel --gpus all --shm-size 2g \
	-p 4567:4567 -p 9090:9090 \
	--env XAUTHORITY=$XAUTH --env DISPLAY --volume $XSOCK:$XSOCK --volume $XAUTH:$XAUTH \
	--env TERM=xterm-256color \
	--volume $SCRIPT_DIR/workspace:/home/ssdf/workspace \
	--workdir /home/ssdf/workspace \
	$1
