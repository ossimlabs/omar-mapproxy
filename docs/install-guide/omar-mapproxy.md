# OMAR Mapproxy
https://github.com/ossimlabs/omar-mapproxy

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

Ref: <https://github.com/ossimlabs/omar-mapproxy>

Environment variables defined

|Variable|Value|
|------|------|
|NUMBER_THREADS|8|
|NUMBER_PROCESSES|4|
|MAP_PROXY_HOME|$HOME/mapproxy|

## Installation in Openshift

**Assumption:** The omar-mapproxy docker image is pushed into the OpenShift server's internal docker registry and available to the project.

1. Create a PersistentVolume to hold cached tiles and scratch data space required by the mapproxy service. The current recommendation is approximately *50gb*
2. Create a mapproxy.yml file on the root of the created PersistentVolume with the following contents:

```yaml
services:
  demo:
  tms:
    use_grid_names: true
    # origin for /tiles service
    origin: 'nw'
  kml:
      use_grid_names: true
  wmts:
  wms:
    md:
      title: o2 Map Proxy
      abstract: Provides a set of tiles for the o2 basemaps.


layers:
  - name: o2-basemap-basic
    title: o2 Basic Basemap
    sources: [o2_basic_tiles_cache]
  - name: o2-basemap-bright
    title: o2 Bright Basemap
    sources: [o2_bright_tiles_cache]


caches:
  o2_basic_tiles_cache:
    grids: [webmercator]
    sources: [o2_basic_tiles]
  o2_bright_tiles_cache:
    grids: [webmercator]
    sources: [o2_bright_tiles]


sources:
  o2_basic_tiles:
     type: tile
     url: http://omar-basemap:80/styles/klokantech-basic/%(z)s/%(x)s/%(y)s.png
     grid: webmercator
  o2_bright_tiles:
    type: tile
    url: http://omar-basemap:80/styles/osm-bright/%(z)s/%(x)s/%(y)s.png
    grid: webmercator


grids:
    webmercator:
        base: GLOBAL_WEBMERCATOR
    geodetic:
        base: GLOBAL_GEODETIC
```

* The important part of the mapproxy file is the sources > omar-basemap:80. This needs to be pointed at the omar-basemap pod you wish to proxy and cache on the mapproxy server.

3. Create a PersistenVolumeClaim for the mapproxy cache created in step 1.
4. Deploy the omar-mapproxy image into the appropriate project. The associated pod will deploy using *port 8080*
5. Attach the PersistenVolumeClaim created in step 3 to the deployment. Mount the claim to */mapproxy* in the mapproxy pod.

### Environment Variables
* No environment variables are required

### An Example DeploymentConfig

```yaml
apiVersion: v1
kind: DeploymentConfig
metadata:
  annotations:
    openshift.io/generated-by: OpenShiftWebConsole
  creationTimestamp: null
  generation: 1
  labels:
    app: omar-mapproxy
  name: omar-mapproxy
spec:
  replicas: 1
  selector:
    app: omar-mapproxy
    deploymentconfig: omar-mapproxy
  strategy:
    activeDeadlineSeconds: 21600
    resources: {}
    rollingParams:
      intervalSeconds: 1
      maxSurge: 25%
      maxUnavailable: 25%
      timeoutSeconds: 600
      updatePeriodSeconds: 1
    type: Rolling
  template:
    metadata:
      annotations:
        openshift.io/generated-by: OpenShiftWebConsole
      creationTimestamp: null
      labels:
        app: omar-mapproxy
        deploymentconfig: omar-mapproxy
    spec:
      containers:
      - image: 172.30.181.173:5000/o2/omar-mapproxy@sha256:e78ac2418e1e6d12641e721738664c2c30104c66243eaa03c07ab0c19f6d5832
        imagePullPolicy: Always
        livenessProbe:
          failureThreshold: 3
          initialDelaySeconds: 60
          periodSeconds: 10
          successThreshold: 1
          tcpSocket:
            port: 8080
          timeoutSeconds: 1
        name: omar-mapproxy
        ports:
        - containerPort: 8080
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          tcpSocket:
            port: 8080
          timeoutSeconds: 1
        resources: {}
        terminationMessagePath: /dev/termination-log
        volumeMounts:
        - mountPath: /mapproxy
          name: volume-0693w
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - name: volume-0693w
        persistentVolumeClaim:
          claimName: basemap-cache-dev-pvc
  test: false
  triggers:
  - type: ConfigChange
  - imageChangeParams:
      automatic: true
      containerNames:
      - omar-mapproxy
      from:
        kind: ImageStreamTag
        name: omar-mapproxy:latest
        namespace: o2
    type: ImageChange
status:
  availableReplicas: 0
  latestVersion: 0
  observedGeneration: 0
  replicas: 0
  unavailableReplicas: 0
  updatedReplicas: 0
```
