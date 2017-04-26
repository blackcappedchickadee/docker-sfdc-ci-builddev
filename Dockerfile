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

ENV SFDC_USERNAME test-user-name@test.sfdc.org
ENV SFDC_PASSWORD testpass
ENV SFDC_TOKEN testtoken
ENV SFDC_SERVERURL https://test.salesforce.com

RUN mkdir /usr/local/sfdc-build
RUN mkdir /usr/local/sfdc-build/src
RUN mkdir /usr/local/sfdc-build/src/pages
RUN echo '<apex:page id="x_npDeploy" showHeader="false"><html xmlns="http://soap.sforce.com/2006/04/metadata"></head></apex:page>' >> /usr/local/sfdc-build/src/pages/x_noDeploy.page;

RUN wget https://github.com/dancinllama/ant-salesforce/raw/master/ant-salesforce_${SALESFORCE_API_VERSION}.jar -P /usr/local/sfdc-build/
RUN wget https://github.com/dancinllama/DockerApexDoc/raw/master/apexdoc.jar -P /usr/local/sfdc-build/

RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/build.xml -P /usr/local/sfdc-build/
RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/build.properties -P /usr/local/sfdc-build/
RUN wget https://github.com/blackcappedchickadee/docker-sfdc-ci-builddev/raw/master/package.xml -P /usr/local/sfdc-build/src/

RUN ant -buildfile /usr/local/sfdc-build/build.xml banner -Dsfdc.username=SFDC_USERNAME -Dsfdc.password=SFDC_PASSWORDSFDC_TOKEN -Dsfdc.serverurl=SFDC_SERVERURL -Dsfdc.apiversion=SALESFORCE_API_VERSION

# RUN ant -buildfile /usr/local/sfdc-build/build.xml validateAndTestCodeOnlyNoDeploy -Dsfdc.username=SFDC_USERNAME -Dsfdc.password=SFDC_PASSWORDSFDC_TOKEN -Dsfdc.serverurl=SFDC_SERVERURL -Dsfdc.apiversion=SALESFORCE_API_VERSION
