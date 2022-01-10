FROM ubuntu:20.04 as build-stage

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  build-essential=12.8ubuntu1.1 \
  git=1:2.25.1-1ubuntu3.2 \
  wget=1.20.3-1ubuntu2 \
  tar=1.30+dfsg-7ubuntu0.20.04.1 \
  ca-certificates=20210119~20.04.2 \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install go && build opera
RUN wget --quiet https://dl.google.com/go/go1.15.10.linux-amd64.tar.gz \
  && tar -xf go1.15.10.linux-amd64.tar.gz -C /usr/local \
  && rm go1.15.10.linux-amd64.tar.gz \
  && git clone https://github.com/Fantom-foundation/go-opera.git /go-opera

ENV GOROOT=/usr/local/go 
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/go/bin:$GOROOT/bin
ARG OPERA_VERSION
WORKDIR /go-opera
RUN git checkout release/${OPERA_VERSION} && make

WORKDIR /root  
RUN wget --quiet https://opera.fantom.network/mainnet.g

FROM ubuntu:20.04 as opera

# install opera
COPY --from=build-stage /go-opera/build/opera /usr/local/bin/opera
COPY --from=build-stage /mainnet.g /root/mainnet.g 
COPY --from=build-stage /usr/local/go /usr/local/go 

ENV GOROOT=/usr/local/go 
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/go/bin:$GOROOT/bin

WORKDIR /root
 
EXPOSE 5050 18545
 
VOLUME [ "/root/.opera" ]
