docker-machine-scaleway
=======================

This image helps to provision scaleway servers as a docker tool container

# Requirements

- docker :whale:


# How To start

```
$ docker-compose build
```

Provision without docker-compose
```
docker run -it --rm \
 -e SCALEWAY_TOKEN=xxxx \
 -e SCALEWAY_ORGANIZATION=xxxxx \
 -e SCALEWAY_NAME="cloudway-server-1" \
 -e SCALEWAY_COMMERCIAL_TYPE="VC1S" \
 -e SCALEWAY_REGION="ams1" \
 -v $HOME/.ssh/:/root/.ssh \
 -v $(pwd)/docker-machine:/root/.docker \
 bee42/docker-machine-scaleway \
 'create -d scaleway cloud-scaleway'
```

Provision with Docker-Compose

```bash
docker-compose run --rm \
 -e SCALEWAY_TOKEN=xxxx \
 -e SCALEWAY_ORGANIZATION=xxxx \
 -e SCALEWAY_NAME="cloudway-server-1" \
 -e SCALEWAY_COMMERCIAL_TYPE="VC1S" \
 -e SCALEWAY_REGION="ams1" \
 scaleway \
 'create -d scaleway cloudway-server-1'
```

SSH to a provsioned server

  ```bash
 docker-compose run --rm \
 scaleway \
 'ssh cloudway-server-1'
 ```

List all machines

```bash
 docker-compose run --rm \
 scaleway \
 'ls'
 ```
