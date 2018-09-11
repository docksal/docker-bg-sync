FROM alpine:3.5

# Alpine doesn't ship with Bash.
RUN apk add --no-cache bash

# Install Unison from source with inotify support + remove compilation tools
ARG UNISON_VERSION=2.48.4
RUN apk add --no-cache --virtual .build-dependencies build-base curl && \
    apk add --no-cache inotify-tools && \
    apk add --no-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ ocaml && \
    curl -L https://github.com/bcpierce00/unison/archive/$UNISON_VERSION.tar.gz | tar zxv -C /tmp && \
    cd /tmp/unison-${UNISON_VERSION} && \
    sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c && \
    make UISTYLE=text NATIVE=true STATIC=true && \
    cp src/unison src/unison-fsmonitor /usr/local/bin && \
    apk del .build-dependencies ocaml && \
    rm -rf /tmp/unison-${UNISON_VERSION}
    # Create user
    echo "docker:x:$HOST_UID:$HOST_UID::/home/docker:" >> /etc/passwd && \
    ## thanks for http://stackoverflow.com/a/1094354/535203 to compute the creation date
    echo "docker:!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow && \
    echo "docker:x:$HOST_UID:" >> /etc/group && \
    mkdir /home/docker && chown docker: /home/docker

ENV HOME="/root" \
    UNISON_USER="root" \
    UNISON_GROUP="root" \
    UNISON_UID="0" \
    UNISON_GID="0"

# Copy the bg-sync script into the container.
COPY sync.sh /usr/local/bin/bg-sync
RUN chmod +x /usr/local/bin/bg-sync

CMD ["bg-sync"]
