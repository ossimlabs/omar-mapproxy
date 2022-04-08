FROM rockylinux:8.5

USER root
RUN useradd -u 1001 -r -g 0 --create-home -d $HOME -s /sbin/nologin -c 'Default Application User' omar
ENV HOME /home/omar
RUN yum -y install epel-release && \
    yum clean all && \
    yum install -y libffi proj freetype python3 python3-devel python3-pip python3-paste python3-paste-script zlib-devel libjpeg-devel gcc && \
    yum -y update && \
    yum clean all && \
    pip3 install MapProxy
RUN cd $HOME && paster-3 create -t mapproxy_conf mymapproxy && \
    chown 1001:0 -R /home/omar
USER 1001
WORKDIR /home/omar/mymapproxy/etc
CMD mapproxy-util serve-develop mapproxy.yaml
