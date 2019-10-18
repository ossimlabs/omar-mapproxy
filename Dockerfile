FROM centos:latest
MAINTAINER RadiantBlue Technologies radiantblue.com
USER root
ENV HOME /home/omar
RUN yum -y install epel-release && \
    yum clean all && \
    yum install -y libffi proj freetype python python-pip python-paste python-paste-script && \ 
    yum -y update && \
    yum clean all && \
    pip install MapProxy
RUN useradd -u 1001 -r -g 0 --create-home -d $HOME -s /sbin/nologin -c 'Default Application User' omar &&\
    cd $HOME && paster create -t mapproxy_conf mymapproxy && \
    chown 1001:0 -R /home/omar
USER 1001
WORKDIR /home/omar/mymapproxy/etc
CMD mapproxy-util serve-develop mapproxy.yaml
