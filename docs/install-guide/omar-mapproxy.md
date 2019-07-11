# OMAR Mapproxy

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

|Variable|Value|
|------|------|
|NUMBER_THREADS|8|
|NUMBER_PROCESSES|4|
|MAP_PROXY_HOME|$HOME/mapproxy|
