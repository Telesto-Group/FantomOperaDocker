FROM ubuntu:20.04 as build-stage

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  build-essential \
  git \
  wget \
  tar \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# install go
RUN wget https://dl.google.com/go/go1.15.10.linux-amd64.tar.gz \
  && tar -xf go1.15.10.linux-amd64.tar.gz -C /usr/local \
  && rm go1.15.10.linux-amd64.tar.gz

ENV GOROOT=/usr/local/go 
ENV GOPATH=/root/go
ENV PATH=$PATH:$GOPATH/go/bin:$GOROOT/bin

# build opera
WORKDIR go-opera
RUN git clone https://github.com/Fantom-foundation/go-opera.git go-opera \
    && git checkout release/1.0.2-rc.5 \
    && make
    
RUN wget https://opera.fantom.network/mainnet.g

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
