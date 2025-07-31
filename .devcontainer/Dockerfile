FROM ecal_base

RUN apt-get update && apt-get install -y python3 python3-pip

COPY .devcontainer/requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

RUN apt-get install -y htop nano

ARG DOCKER_CLI_VERSION=25.0.3
RUN curl -L https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLI_VERSION}.tgz -o docker.tgz && \
    tar -xzf docker.tgz --strip-components=1 docker/docker && \
    mv docker /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker && \
    rm docker.tgz
