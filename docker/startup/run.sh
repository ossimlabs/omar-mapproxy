#!/bin/bash

if [ -d /mapproxy ] ; then
   if [ -z $MAP_PROXY_HOME ] ; then
      export MAP_PROXY_HOME="/mapproxy"
   fi
fi

if [ -z $MAP_PROXY_HOME ] ; then
   pushd $HOME > /dev/null
   mapproxy-util create -t base-config mapproxy
   export MAP_PROXY_HOME=$HOME/mapproxy
   popd > /dev/null  
fi                                                                                                                                                                                  

if [ ! -z $MAP_PROXY_HOME ] ; then
   pushd $MAP_PROXY_HOME >/dev/null
   if [ ! -f app.py ] ; then
      mapproxy-util create -t wsgi-app -f mapproxy.yaml app.py
   fi
   spawning app.application --thread=8 --processes=4 --port=8080
   popd > /dev/null
fi


