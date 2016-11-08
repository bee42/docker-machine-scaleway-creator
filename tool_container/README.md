docker-machine-scaleway
=======================

This image helps to provision scaleway servers as a docker tool container

# Requirements

- docker :whale:


# How To start


Man muss den docker storage ins container image abbilden 
dadurch braucht man keinen jump host mehr da
im docker container die pfade gleich sind wie auf dem momemtanen host .

so könnte man auch ohne docker-machine env abbilden

2ter dockerdind container der die volumes nimmt und die envs via script bekommt

simples shell script

STORAGE_PATH=


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
 scaleway \
 'create -d scaleway cloud-scaleway'
```

Provision with Docker-Compose 

```bash
docker-compose run --rm \
 -e SCALEWAY_TOKEN=44cff4f3-7af6-44ad-852c-66c48fae64fd \
 -e SCALEWAY_ORGANIZATION=73541080-3c45-4592-acfb-cfb9dca9c7ed \
 -e SCALEWAY_NAME="cloudway-server-1" \
 -e SCALEWAY_COMMERCIAL_TYPE="VC1S" \
 -e SCALEWAY_REGION="ams1" \
 scaleway \
 'create -d scaleway cloudway-server-1'
```
 


test image 
  ```bash
 docker-compose run --rm \
 scaleway \
 'ssh cloudway-server-1'
 ```

   ```bash
 docker-compose run --rm \
 scaleway \
 'ls'
 ```