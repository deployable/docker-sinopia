# Sinopia NPM Registry in Docker

A local npm registry running in Docker

Sinopia is not actively developed any more but its solid - https://github.com/rlidwka/sinopia

## Run

    docker run -d -p 4873:4873 -v sinopia-storage:/sinopia/storage:rw --restart always deployable/sinopia

## Build

To build and restart an existing local container

    ./make.sh rebuild

## Links

Sinopia - https://github.com/rlidwka/sinopia

