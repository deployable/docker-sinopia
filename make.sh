#!/usr/bin/env bash

set -uex

rundir=${0%/*}
cd $rundir

NAME=sinopia
PORT=4873
RELEASE=sinopia-3f55fb4c0c6685e8b22796cce7b523bdbfb4019e
TAG_PREFIX=deployable
TAG_NAME=${NAME}
TAG_TAG=latest

ARG=${1:-}
if [ -z "$ARG" ]; then
  set -- build "$@"
fi


build(){
  [ -d "${RELEASE}" ] || download
  docker build --build-arg DOCKER_BUILD_PROXY=http://10.8.8.8:3142 -t ${TAG_PREFIX}/${TAG_NAME} .
}

download(){
  wget -O ${RELEASE}.tar.gz.tmp https://github.com/rlidwka/sinopia/archive/3f55fb4c0c6685e8b22796cce7b523bdbfb4019e.tar.gz
  mv ${RELEASE}.tar.gz.tmp $RELEASE.tar.gz
  rm -rf ${RELEASE}
  tar -xvf ${RELEASE}.tar.gz
}

rebuild(){
  build
  stop
  start
}

start(){
  docker run \
    --detach \
    --volume sinopia-storage:/opt/sinopia/storage:rw \
    --publish ${PORT}:${PORT} \
    --name ${NAME} \
    --restart always  \
    ${TAG_PREFIX}/${TAG_NAME}
}

stop(){
  docker stop ${NAME}
  docker rm ${NAME}
}

shell(){
  docker exec -ti ${NAME} bash
}

logs(){
  docker logs --tail 10 -f ${NAME}
}

publish(){
  docker push ${TAG_PREFIX}/${TAG_NAME}:${TAG_TAG}
}

"$@"


