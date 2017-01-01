# first
#
#     docker build -t deployable/sinopia .

# repeat
# 
#     docker build --build-arg DOCKER_BUILD_PROXY=http://10.8.8.8:3142 -t deployable/sinopia . && docker stop sinopia && docker rm sinopia && docker run -v sinopia-storage:/sinopia/storage:rw -p 4873:4873 -d --name sinopia --restart always deployable/sinopia

FROM mhart/alpine-node:6.9

ARG DOCKER_BUILD_PROXY
ENV DOCKER_BUILD_PROXY=$DOCKER_BUILD_PROXY

RUN set -uex; \
    adduser -D -g "" sinopia; \
    adduser -D -g "" -G sinopia sinopiar; \
    mkdir -p /sinopia/storage; \
    chown sinopia sinopia/storage; \
    chmod 755 sinopia/storage;



# Use a newer sinopia than release
#RUN git clone https://github.com/rlidwka/sinopia#3f55fb4c0c6685e8b22796cce7b523bdbfb4019e 
# `./make.sh download`
#ADD sinopia-3f55fb4c0c6685e8b22796cce7b523bdbfb4019e /sinopia
COPY sinopia-3f55fb4c0c6685e8b22796cce7b523bdbfb4019e /sinopia
ADD /config.yaml /sinopia/config.yaml

RUN set -uex; \
    export http_proxy=${http_proxy:-${DOCKER_BUILD_PROXY}}; \
    apk update; \
    apk add g++ python-dev make; \
    export http_proxy=; \
    cd /sinopia; \
    npm install js-yaml; \
    ./node_modules/.bin/js-yaml package.yaml > package.json; \
    rm npm-shrinkwrap.json; \
    npm install -d --production; \
    npm cache clean; \
    chown -R sinopia:sinopia /sinopia; \
    chown -R sinopiar:sinopia /sinopia/storage; \
    chmod 755 /sinopia/bin/sinopia; \
    find /sinopia -type d -exec chmod 755 {} +; \
    find /sinopia -type f -exec chmod o+r {} +; \
    find /sinopia -type f -exec chmod g+r {} +; \
    apk del --purge python python-dev g++ musl-dev libc-dev gcc


ADD /entrypoint.sh /docker-entrypoint.sh
USER sinopiar
EXPOSE 4873
VOLUME ["/sinopia/storage"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]

