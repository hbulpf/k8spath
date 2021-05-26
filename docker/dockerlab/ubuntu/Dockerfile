FROM ubuntu:18.04

ENV CUS_USER="lpf"

# COPY gosu-amd64 . 
    
RUN groupadd -r $CUS_USER \
    && useradd -r -g $CUS_USER $CUS_USER
    # && mv gosu-amd64 /usr/local/bin/gosu \
    # && chmod +x /usr/local/bin/gosu \
    # && gosu nobody true

WORKDIR /home/$CUS_USER

# 下载 gosu
# RUN apt-get update && apt-get install -y wget \
    # && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64" \
    # && chmod +x /usr/local/bin/gosu \
    # && gosu nobody true
USER $CUS_USER