FROM alpine

ARG build-sfdc-username
ARG build-sfdc-password
ARG build-sfdc-token
ARG build-sfdc-serverurl

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

ENV SFDC_USERNAME ${build-sfdc-username:test-user-name@test.sfdc.org} 
ENV SFDC_PASSWORD ${build-sfdc-password:testpass}
ENV SFDC_TOKEN ${build-sfdc-token:testtoken}
ENV SFDC_SERVERURL ${build-sfdc-serverurl:https://test.salesforce.com}

RUN echo $SFDC_USERNAME
RUN echo $SFDC_TOKEN
RUN echo $SFDC_SERVERURL

RUN mkdir /usr/local/sfdc-build
RUN mkdir /usr/local/sfdc-build/prod-metadata-backup

RUN mkdir /usr/local/sfdc-build/src
RUN mkdir /usr/local/sfdc-build/src/pages
RUN echo '<apex:page id="xNoDeploy"></apex:page>' >> /usr/local/sfdc-build/src/pages/xNoDeploy.page;
RUN echo '<?xml version="1.0" encoding="UTF-8"?><ApexPage xmlns="http://soap.sforce.com/2006/04/metadata"><apiVersion>39.0</apiVersion><availableInTouch>false</availableInTouch><confirmationTokenRequired>false</confirmationTokenRequired><label>xNoDeploy</label></ApexPage>' >> /usr/local/sfdc-build/src/pages/xNoDeploy.page-meta.xml;

RUN wget https://github.com/dancinllama/ant-salesforce/raw/master/ant-salesforce_${SALESFORCE_API_VERSION}.jar -P /usr/local/sfdc-build/
RUN wget https://github.com/dancinllama/DockerApexDoc/raw/master/apexdoc.jar -P /usr/local/sfdc-build/

RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/build.xml -P /usr/local/sfdc-build/
RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/build.properties -P /usr/local/sfdc-build/
RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/package.xml -P /usr/local/sfdc-build/src/

RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/package.xml -P /usr/local/sfdc-build/prod-metadata-backup

# RUN ant -buildfile /usr/local/sfdc-build/build.xml banner -Dsfdc.username=SFDC_USERNAME -Dsfdc.password=SFDC_PASSWORDSFDC_TOKEN -Dsfdc.serverurl=SFDC_SERVERURL -Dsfdc.apiversion=SALESFORCE_API_VERSION

RUN ant -buildfile /usr/local/sfdc-build/build.xml retrieveUnpackaged -Dsfdc.username=SFDC_USERNAME -Dsfdc.password=SFDC_PASSWORDSFDC_TOKEN -Dsfdc.serverurl=SFDC_SERVERURL -Dsfdc.apiversion=SALESFORCE_API_VERSION

RUN cd /usr/local/sfdc-build/src

RUN ls -l

