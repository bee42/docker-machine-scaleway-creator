FROM docker:1.12.3-dind
MAINTAINER Peter Rossbach <peter.rossbach@bee42.com> @PRossbach

ARG COMPOSE_VERSION
ARG MACHINE_VERSION
ARG GLIBC_VERSION
ARG SCALEWAY_VERSION
ARG SCALEWAY_MACHINE_VERSION

ENV COMPOSE_VERSION=${COMPOSE_VERSION:-1.8.1} \
  MACHINE_VERSION=${MACHINE_VERSION:-0.8.2} \
  PORT=2375 \
  GLIBC_VERSION=${GLIC_VERSION:-2.23-r3} \
  SCALEWAY_MACHINE_VERSION=${SCALEWAY_MACHINE_VERSION:-1.3} \
  SCALEWAY_VERSION=${SCALEWAY_VERSION:-1.11}

RUN apk add --update ca-certificates openssl curl && \
    curl -o glibc.apk -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted glibc.apk && \
    curl -o glibc-bin.apk -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted glibc-bin.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -f glibc.apk glibc-bin.apk && \
    rm -rf /var/cache/apk/*

# install supervisor
RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
  && apk add --update \
	supervisor sudo openssh pwgen jq zip unzip bash bash-completion\
	&& rm -rf /var/cache/apk/* \
  && mkdir -p /var/log/supervisor \
  && mkdir /var/run/sshd \
  && echo 'root:screencast' |chpasswd \
  && sed -i 's/#PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config

ADD completion.txt /tmp/completion.txt
ADD mobydock.txt /tmp/mobydock.txt

# add docker tools
RUN  mkdir -p /etc/bash_completion.d \
  && curl -Ls https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose ; chmod +x /usr/local/bin/docker-compose \
  && curl -Ls https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose ; chmod +x /etc/bash_completion.d/docker-compose \
  && curl -Ls https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > /etc/bash_completion.d/docker ; chmod +x /etc/bash_completion.d/docker \
  && curl -L https://github.com/docker/machine/releases/download/v${MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine ; chmod +x /usr/local/bin/docker-machine \
  && curl -Ls https://raw.githubusercontent.com/docker/machine/v${MACHINE_VERSION}/contrib/completion/bash/docker-machine.bash > /etc/bash_completion.d/docker-machine ; \
  chmod +x /etc/bash_completion.d/docker-machine \
  && curl -Ls https://raw.githubusercontent.com/docker/machine/v${MACHINE_VERSION}/contrib/completion/bash/docker-machine-prompt.bash > /etc/bash_completion.d/docker-machine-prompt ; \
  chmod +x /etc/bash_completion.d/docker-machine-prompt \
  && curl -Ls https://raw.githubusercontent.com/docker/machine/v${MACHINE_VERSION}/contrib/completion/bash/docker-machine-wrapper.bash > /etc/bash_completion.d/docker-machine-wrapper ; \
  chmod +x /etc/bash_completion.d/docker-machine-wrapper \
  && curl -Ls https://raw.githubusercontent.com/scaleway/scaleway-cli/v${SCALEWAY_VERSION}/contrib/completion/bash/scw >/etc/bash_completion.d/scw ; \
  chmod +x /etc/bash_completion.d/scw \
  && cat >>/etc/profile </tmp/completion.txt

# add scaleway tools
RUN curl -Ls https://github.com/scaleway/scaleway-cli/releases/download/v${SCALEWAY_VERSION}/scw_${SCALEWAY_VERSION}_linux_amd64.tar.gz > /tmp/scw.tar.gz \
  && cd /tmp ; tar xzf /tmp/scw.tar.gz \
  && mv /tmp/scw_${SCALEWAY_VERSION}_linux_amd64/scw /usr/local/bin \
  && mv /tmp/scw_${SCALEWAY_VERSION}_linux_amd64/LICENSE.md  /etc/LICENSE-scaleway.md \
  && rm -rf /tmp/scw_${SCALEWAY_VERSION}_linux_amd64 /tmp/scw.tar.gz \
  && curl -sL https://github.com/scaleway/docker-machine-driver-scaleway/releases/download/v${SCALEWAY_MACHINE_VERSION}/docker-machine-driver-scaleway_${SCALEWAY_MACHINE_VERSION}_linux_amd64.tar.gz >/tmp/docker-machine-driver-scaleway.tar.gz \
  && tar -xf docker-machine-driver-scaleway.tar.gz \
  && chmod +x docker-machine-driver-scaleway_${SCALEWAY_MACHINE_VERSION}_linux_amd64/docker-machine-driver-scaleway \
  && mv docker-machine-driver-scaleway_${SCALEWAY_MACHINE_VERSION}_linux_amd64/docker-machine-driver-scaleway /usr/local/bin/ \
  && rm -rf /tmp/docker-machine-driver-scaleway_${SCALEWAY_MACHINE_VERSION}_linux_amd64 /tmp/docker-machine-driver-scaleway.tar.gz

# add developer user creator
RUN addgroup creator && addgroup docker \
  && adduser -D -G docker -s /bin/bash creator creator \
  && echo "%docker  ALL=(ALL)      ALL" >>/etc/sudoers \
  && echo 'creator:creator' | chpasswd \
  && echo "export DOCKER_HOST=tcp://0.0.0.0:$PORT" >>/home/creator/.bash_aliases \
  && echo "alias d=docker" >>/home/creator/.bash_aliases \
  && echo "alias dm=docker-machine" >>/home/creator/.bash_aliases \
  && echo "alias dco=docker-compose" >>/home/creator/.bash_aliases \
  && echo ":set term=ansi" >>/home/creator/.vimrc \
  && cp /tmp/mobydock.txt /home/creator/.mobydock.txt \
  && echo "cat /home/creator/.mobydock.txt" > /home/creator/.profile \
  && echo ". /home/creator/.bash_aliases" >> /home/creator/.profile \
  && echo "PS1='[\u@\h \W\$(__docker_machine_ps1)]\\\$ '" >> /home/creator/.profile \
  && chown -R creator:creator /home/creator

ADD ssh_config /home/creator/.ssh/config
RUN chown -R creator:creator /home/creator/.ssh

# Configuration supervisord
ADD supervisord-base.ini /etc/supervisor.d/supervisord-base.ini
# Configuration dind
ADD supervisord-docker.ini /etc/supervisor.d/supervisord-docker.ini
ADD supervisord-sshd.ini /etc/supervisor.d/supervisord-sshd.ini

EXPOSE 9001 2375 22
VOLUME [ "/data" ]

ADD start.sh /usr/local/bin/start.sh
ENTRYPOINT [ "/usr/local/bin/start.sh" ]
CMD []

LABEL org.label-schema.name="scw-creator"  \
 org.label-schema.vendor="bee42 solutions gmbh" \
 org.label-schema.schema-version="1.0" \
 org.label-schema.description="Scaleway cli docker machine creator DinD" \
 com.bee42.scw-creator.license.type="Apache 2.0" \
 com.bee42.scw-creator.license.path="/etc/LICENSE.scw-creator"

ADD LICENSE /etc/LICENSE.scw-creator
RUN COPYDATE=`date  +'%Y'` \
 && echo "infrabricks creator" >/etc/provisioned.scw-creator \
 && date >>/etc/provisioned.scw-creator \
 && echo >>/etc/provisioned.scw-creator \
 && echo " Copyright ${COPYDATE} by <peter.rossbach@bee42.com> bee42 solutions gmbh" >>/etc/provisioned.scw-creator
