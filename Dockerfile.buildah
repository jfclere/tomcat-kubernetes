FROM registry.access.redhat.com/ubi8
LABEL Description="Builder for JWS operator"
VOLUME /tmp

USER root

RUN yum install buildah maven git -y
# for redhat_jws_download.py: python3-requests python3-lxml unzip gcc-c++ pip3 python3-dev -y 
# RUN pip3 install ujson

#RUN rm -rf /var/lib/containers

# For openshift (a bit hacky)
RUN echo "1000:100000:65536" > /etc/subuid
RUN echo "1000:100000:65536" > /etc/subgid
RUN chmod a+w /etc/subuid
RUN chmod a+w /etc/subgid

ADD build.sh /usr/bin/build.sh
ADD redhat_jws_download.py /usr/bin/redhat_jws_download.py
ADD Dockerfile.JWS /

# The env
# to run with --env var=val
#
ENV webAppWarFileName=ROOT.war
ENV webAppWarImage=quay.io/jfclere/test
ENV webAppSourceRepositoryURL=https://github.com/jfclere/demo-webapp.git
ENV webAppSourceRepositoryRef=main
ENV webAppSourceRepositoryContextDir=
ENV webAppSourceImage=registry.redhat.io/jboss-webserver-5/webserver55-openjdk8-tomcat9-openshift-rhel8

# The user
RUN useradd -u 1000 jbossbuilder
USER 1000:1000


ENTRYPOINT ["/usr/bin/build.sh"]
