# first stage: defining builder image here

FROM alpine:latest as builder
ARG VERSION=1449

RUN mkdir -p /tmp/data 
WORKDIR /tmp

# downloading and organising terraria server files
RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-${VERSION}.zip && \
    unzip *${VERSION}.zip* && \
    chmod +x ${VERSION}/Linux/TerrariaServer.bin.x86_64 && \
    cp -r ${VERSION}/Linux server && \
    rm server/System* && \ 
    rm -r ${VERSION} && \
    rm *${VERSION}.zip*

# copying start script to directory
COPY entrypoint.sh /tmp/server
RUN chmod +x /tmp/server/entrypoint.sh

# creating "attach" script
RUN printf "#!/bin/bash\n\
screen -r terraria\n" > /tmp/server/attach && \
    chmod +x /tmp/server/attach


# second stage: copying files over and starting server

FROM mono:latest

# setting environment variables for serverconfig.txt
ENV WORLD_FILE_NAME="world.wld" \
    WORLD_NAME="world" \
    AUTOCREATE="3" \
    DIFFICULTY="0" \
    MAX_PLAYERS="8" \
    MOTD="Please don't cut the purple trees!" \
    LANGUAGE="en-US" \
    PASSWORD="p@55w0rd*"

# creating terraria user and installing packages
RUN addgroup --gid 1000 terraria && \
    adduser --system --uid 1000 --gid 1000 terraria && \
    apt-get update && \
    apt-get install -y xxd && \ 
    apt-get install -y screen && \
    apt-get install -y less && \
    apt-get install -y net-tools && \
    apt-get install -y vim

# configuring screen and attach script
RUN printf "# Adding extra config to prevent Ctrl-C from killing screen and terraria server\n\
bindkey ^C detach\n\n" >> /etc/screenrc

COPY --chown=1000:1000 --from=builder /tmp/ /app/
RUN mv /app/server/attach /usr/bin

USER terraria

VOLUME ["/app/data"]

EXPOSE 7777

ENTRYPOINT ["/bin/bash", "-c", "/app/server/entrypoint.sh"]

HEALTHCHECK --start-period=5m CMD netstat -tuln | grep 0.0.0.0:7777 > /dev/null 2>&1
