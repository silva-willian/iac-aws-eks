FROM ubuntu:20.10

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get -y install python3 && \
    apt install -y python3-pip && \
    pip3 install awscli --upgrade && \
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

WORKDIR /app

COPY . .

CMD chmod +x destroy-cluster.sh && \
    ./destroy-cluster.sh