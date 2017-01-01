#!/usr/bin/env bash

set -uex

rundir=${0%/*}
cd $rundir

NAME="sinopia"
PATH_APP="/${NAME}"
PORT=4873
RELEASE="sinopia-3f55fb4c0c6685e8b22796cce7b523bdbfb4019e"
TAG_PREFIX="deployable"
TAG_NAME="${NAME}"
TAG_TAG="latest"

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
    --volume sinopia-storage:${PATH_APP}/storage:rw \
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
  local tag=${1:-${TAG_TAG}}
  docker push ${TAG_PREFIX}/${TAG_NAME}:${TAG_TAG}
}

release(){
  local release_date=$(date +%Y%m%d)
  if git status --procelain
  build
  git tag ${release_date}
  publish $release_date
  git push --tags
}

"$@"

