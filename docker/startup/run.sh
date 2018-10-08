#!/bin/bash
if [ ! -z "${AWS_ACCESS_KEY}" ] ; then
  export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
fi

if [ ! -z "${AWS_SECRET_KEY}" ] ; then
  export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
fi
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
sed '/^omar/d' /etc/passwd > /tmp/passwd
echo omar:x:$USER_ID:$GROUP_ID:Default Application User:$HOME:/sbin/nologin >> /tmp/passwd

export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

if [ -z $NUMBER_THREADS ] ; then
  export NUMBER_THREADS=8
fi
if [ -z $NUMBER_PROCESSES ] ; then
  export NUMBER_PROCESSES=4
fi
if [ -d /mapproxy ] ; then
   if [ -z $MAP_PROXY_HOME ] ; then
      export MAP_PROXY_HOME="/mapproxy"
   fi
fi

if [ -z $MAP_PROXY_HOME ] ; then
   pushd $HOME > /dev/null
   echo "MAP_PROXY_HOME not defined.  Using ${HOME}/mapproxy"
   mapproxy-util create -t base-config mapproxy
   export MAP_PROXY_HOME=$HOME/mapproxy
   popd > /dev/null  
fi                                                                                                                                                                                  

if [ ! -z $MAP_PROXY_HOME ] ; then
   echo "Using MAP_PROXY_HOME=$MAP_PROXY_HOME"
   pushd $MAP_PROXY_HOME >/dev/null
   if [ ! -f app.py ] ; then
      echo "app.py not found, generating a new app.py in $MAP_PROXY_HOME"
      mapproxy-util create -t wsgi-app -f mapproxy.yaml app.py
   fi
   echo "spawning app.application --thread=$NUMBER_THREADS --processes=$NUMBER_PROCESSES --port=8080"
   spawning app.application --thread=$NUMBER_THREADS --processes=$NUMBER_PROCESSES --port=8080
   popd > /dev/null
fi


