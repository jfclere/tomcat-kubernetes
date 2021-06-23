FROM jfclere/tomcat-stuffed:1.0
LABEL Description="Tomcat image builder to use with the JWS operator"
VOLUME /tmp

USER root

ADD server.xml.stuffed /deployments/conf/server.xml
ADD start.sh /opt
ADD usekube.sh /opt
ADD usedns.sh /opt
RUN chmod 777 /opt/*.sh

RUN mkdir -p /usr/libexec/s2i
ADD assemble /usr/libexec/s2i

RUN chmod 777 /tmp
RUN apt-get update
RUN apt-get install -y git maven openjdk-11-jdk-headless

USER 1001
ENTRYPOINT [ "/opt/start.sh" ]
