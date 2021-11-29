# Copied and adapted from https://github.com/apache/tomcat/blob/main/modules/stuffed/Dockerfile
FROM openjdk:8-jre
LABEL Description="Tomcat image to test tomcat-in-the-cloud. standalone tomcat version"
VOLUME /tmp

USER root

ADD target/dependency/tomcat.zip apache-tomcat.zip
RUN unzip apache-tomcat.zip
RUN rm apache-tomcat.zip
RUN mv apache-tomcat* apache-tomcat
ADD server.xml /apache-tomcat/conf
ADD openjson-1.0.10.jar /apache-tomcat/bin
ADD catalina.sh /apache-tomcat/bin

RUN chmod 777 /apache-tomcat/logs
RUN chmod 777 /apache-tomcat/webapps
RUN chmod 777 /apache-tomcat/work
RUN chmod 777 /apache-tomcat/temp

WORKDIR /apache-tomcat

ENV OPENSHIFT_KUBE_PING_NAMESPACE "default"

RUN sh -c 'chmod a+x bin/*.sh'
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "bin/startup.sh" ]
