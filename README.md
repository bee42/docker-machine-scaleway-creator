# Docker Creator of scaleway machines

Build a container to create [scaleway](https://www.scaleway.com/) docker machines.

![](images/scw-creator-overview.png)

* Based on [DinD](https://hub.docker.com/_/docker/)
* Access with ssh
* scaleway cli and scaleway docker machine driver

## Build the docker machine scw creator

```
$ docker build -t bee42/scw-docker-machine-creator .
```

## Usage of the creator
```
$ docker run -d -p 2222:22 \
  -v `pwd`/config:/config \
  --privileged \
  bee42/scw-docker-machine-creator
$ ssh -p 2222 creator@<docker scw-docker-machine-creator ip>
# pw: creator
```

![](images/scw-creator-design.png)

More services are available

| port | service                 |
|:-----|:------------------------|
| 22   | sshd                    |
| 2375 | uncrypted docker engine |
| 9001 | supervisord admin       |

## Usage with docker compose

```
$ export SCALEWAY_TOKEN=xxx
$ export SCALEWAY_ORGANIZATION=xxx
$ export SCALEWAY_REGION=ams1
$ docker-compose up -d
$ docker-compose exec scw-creator /bin/sh
```

## Usage of scaleway docker machine creator

```
# login with ssh
cat >scw_access <<EOF
export SCALEWAY_TOKEN=XXX_YYY_ZZZ
export SCALEWAY_ORGANIZATION=XXX_YYY_ZZZ
export SCALEWAY_REGION=ams1
EOF
$ source scw_access
# par1 | ams1
$ curl -H "X-Auth-Token: ${SCALEWAY_TOKEN}" \
 -H 'Content-Type: application/json' \
"https://cp-${SCALEWAY_REGION}.scaleway.com/servers"
$ curl -H "X-Auth-Token: ${SCALEWAY_TOKEN}" \
  -H 'Content-Type: application/json' \
"https://cp-${SCALEWAY_REGION}.scaleway.com/images" | jq ".images[]"
$ curl -H "X-Auth-Token: ${SCALEWAY_TOKEN}" \
  -H 'Content-Type: application/json' \
"https://cp-${SCALEWAY_REGION}.scaleway.com/images" \
  | jq '.images[] | { "name": .name , "id": .id, "arch": .arch }'
# create your first docker machine
$ docker-machine -D create -d scaleway \
 --scaleway-region=ams1 \
 --scaleway-name=scw-beehive42-001 \
 --scaleway-commercial-type "VC1S" \
 --scaleway-debug  \
 scw-beehive42
```

## Hints: Scaleway tools

* https://github.com/scaleway/scaleway-cli
* https://github.com/scaleway/docker-machine-driver-scaleway

## TODO

* Fix the bug:
  * Currently the scaleway host is created, but the docker provision is hanging. (2016-01-11)
* More examples to provision a docker swarming cluster
* describe the build args

## Links

* https://github.com/scaleway/scaleway-cli
* https://github.com/andyshinn/alpine-pkg-glibc
* https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile
* https://stedolan.github.io/jq/manual/#Basicfilters
* http://label-schema.org/rc1/
* http://blog.hypriot.com/post/test-build-and-package-docker-for-arm-the-official-way/
* http://blog.hypriot.com/post/setting-up-100-nodes-jenkins-cluster-with-docker-swarm-in-less-than-10-minutes/
* https://github.com/scaleway-community/scaleway-docker
* https://nathanleclaire.com/blog/2016/08/11/curl-with-http2-support---a-minimal-alpine-based-docker-image/
***

Regards
Peter

<peter.rossbach@bee42.com> @PRossbach
