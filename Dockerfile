FROM alpine

RUN apk update
RUN apk add bash
RUN apk add openssh
RUN apk add git
RUN apk add openjdk8
RUN apk add apache-ant --update-cache \
	--repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
	--allow-untrusted
RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

RUN mkdir /root/.ssh && echo "StrictHostKeyChecking no " > /root/.ssh/config

RUN   apk update \                                                            
  &&   apk add ca-certificates wget \                                                              
  &&   update-ca-certificates  

ENV ANT_HOME /usr/share/java/apache-ant
ENV SALESFORCE_API_VERSION 38

RUN cd /usr/local
RUN mkdir /usr/local/sfdc-build
RUN wget https://github.com/dancinllama/ant-salesforce/raw/master/ant-salesforce_${SALESFORCE_API_VERSION}.jar -P /usr/local/sfdc-build/
RUN wget https://github.com/dancinllama/DockerApexDoc/raw/master/apexdoc.jar -P /usr/local/sfdc-build/
