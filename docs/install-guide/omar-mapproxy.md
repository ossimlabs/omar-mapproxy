# OMAR Map Proxy

## Dockerfile
```
FROM centos:latest
MAINTAINER RadiantBlue Technologies radiantblue.com
USER root
ENV HOME /home/omar
RUN yum -y install epel-release clean all && \\
yum install -y libffi proj freetype python python-pip python-paste python-paste-script&&
yum clean all && \\
pip install MapProxy spawning
RUN useradd -u 1001 -r -g 0 --create-home -d \$HOME -s /sbin/nologin -c 'Default Application User' omar
COPY startup/run.sh \$HOME
RUN chown 1001:0 -R /home/omar && chmod +x \$HOME/*.sh
USER 1001
EXPOSE 8080
WORKDIR /home/omar
CMD ./run.sh
```
Ref: [https://github.com/ossimlabs/omar-mapproxy](https://github.com/ossimlabs/omar-mapproxy)

If the docker file is created then:

`docker build -t omar-base:latest .`

Push that to your registry and this is used as a base image for all omar services that do not require the ossim core JNI interfaces.
