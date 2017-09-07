#!/bin/bash

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
   pushd $MAP_PROXY_HOME >/dev/null
   if [ ! -f app.py ] ; then
      echo "app.py not found, generating a new app.py in $MAP_PROXY_HOME"
      mapproxy-util create -t wsgi-app -f mapproxy.yaml app.py
   fi
   echo "spawning app.application --thread=$NUMBER_THREADS --processes=$NUMBER_PROCESSES --port=8080"
   spawning app.application --thread=$NUMBER_THREADS --processes=$NUMBER_PROCESSES --port=8080
   popd > /dev/null
fi


