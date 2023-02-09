# geOrchestra on Docker

## Quick Start

**1. Prerequisite**

* RAM

Grab a machine with a decent amount of RAM (16Gb is mandatory to run the full composition, more is better).

* Install Docker

An up-to-date [docker](https://docs.docker.com/engine/installation/) engine is required.

Note that docker-compose is not necessary anymore. 

**2. Download sources**

Clone this repo and its submodule using:
```
git clone --recurse-submodules https://github.com/georchestra/docker.git
```

Choose which branch to run, eg for latest stable:
```
git checkout 22.0 && git submodule update
```

**3. Run**

The default docker-compose file contains all geOrchestra modules.

It's recommended to double-check the `docker-compose.yml` and `docker-compose.override.yml` files if you need to comment useless modules (e.g extractor, mapstore,... ).

To run:

```
cd docker
docker compose up -d
```


To stop geOrchestra:
```
docker-compose down
```

**4. Play**

Open [https://georchestra-127-0-1-1.traefik.me/](https://georchestra-127-0-1-1.traefik.me/) in your browser.

To login, use these credentials:
 * `testuser` / `testuser`
 * `testadmin` / `testadmin`

To upload data into the GeoServer data volume (`geoserver_geodata`), use `rsync`:
```
rsync -arv -e 'ssh -p 2222' /path/to/geodata/ geoserver@georchestra-127-0-1-1.traefik.me:/mnt/geoserver_geodata/
```
(password is: `geoserver`)

Files uploaded into this volume will also be available to the geoserver instance in `/mnt/geoserver_geodata/`.

Emails sent by the SDI (eg when users request a new password) will not be relayed on the internet but trapped by a local SMTP service.  
These emails can be read on https://georchestra-127-0-1-1.traefik.me/webmail/ (with login `smtp` and password `smtp`).


## About the domain name

The current FQDN `georchestra-127-0-1-1.traefik.me` resolves to 127.0.1.1, thanks to [traefik.me](https://traefik.me/) which provides wildcard DNS for any IP address.

To change it:
 * Rename the traefik service in the `docker-compose.override.yml` file to match the new domain
 * Modify the three `traefik.http.routers.*.rule` in the `docker-compose.override.yml` file
 * Update the datadir in the config folder (hint: grep for `georchestra-127-0-1-1.traefik.me`)
 * Put a valid SSL certificate in the `resources/ssl` folder and declare it in the `resources/traefik-config.yml` file

## Notes

These docker-compose files describe:
 * which images / webapps will run,
 * how they are linked together,
 * where the configuration and data volumes are

The `docker-compose.override.yml` file adds services to interact with your geOrchestra instance (they are not part of geOrchestra "core"):
 * reverse proxy / load balancer
 * ssh / rsync services,
 * smtp, webmail.

**Feel free to comment out the apps you do not need**.

The base docker composition does not include any standalone geowebcache instance, nor the atlas module.
If you need them, you have to include the corresponding complementary docker-compose file at run-time:
```
docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.gwc.yml -f docker-compose.atlas.yml up
```

## Upgrading

Images and configuration are updated regularly.

To upgrade, we recommend you to:
 * update the configuration with `git submodule update`
 * update the software with `docker-compose pull`


## Customising

Adjust the configuration in the `config` folder according to your needs.
Reading the [quick configuration guide](https://github.com/georchestra/datadir/blob/docker-master/README.md) might help !

Most changes will require a service restart, except maybe updating viewer contexts & addons (`F5` will do).

## Building

Images used in the current composition are pulled from docker hub, which means they've been compiled by [github actions](https://github.com/georchestra/georchestra/actions).
In case you have to build these images by yourself, please refer to the [docker images build instructions](https://github.com/georchestra/georchestra/blob/master/docker/README.md).


## Geofence

If you want to run the Geofence enabled GeoServer, make sure the correct docker image is being used in `docker-compose.yml`:

```
image: georchestra/geoserver:22.0.x-geofence
```
(replace `22.0.x-geofence` by the appropriate version - use `latest-geofence` on master).

And change the `JAVA_OPTIONS` in the geoserver `environment` properties to indicate where the Geofence databaser configuration .properties file is:

```
    environment:
      - JAVA_OPTIONS=-Dgeofence-ovr=file:/etc/georchestra/geoserver/geofence/geofence-datasource-ovr.properties
```


Then, edit the file `config/geoserver/geofence/geofence-datasource-ovr.properties`, and change the line

```
#geofenceEntityManagerFactory.jpaPropertyMap[hibernate.hbm2ddl.auto]=validate
```
to 
```
geofenceEntityManagerFactory.jpaPropertyMap[hibernate.hbm2ddl.auto]=update
```

## Kibana

The optional `kibana` service is used for dashboarding purposes and is integrated to the GeoNetwork admin UI. See in the `Statistics & status / Content statistics` admin menu to access it.

A specific configuration is provided in the `kibana/` subdirectory.

Please note that it will require to load by hand the following file from the kibana admin ui:

https://raw.githubusercontent.com/georchestra/geonetwork/georchestra-gn4-4.0.6/es/es-dashboards/data/export.ndjson#



## Elasticsearch

In the current state of the docker composition, no volume is defined, so do not expect persistence of the indexes.

If you are running low on disk space, Elastic has a mechanism to pass the index in a read-only mode. You can deactivate this feature by following this guide:

https://techoverflow.net/2019/04/17/how-to-disable-elasticsearch-disk-quota-watermark/



# Developers corner

**1. build source on every changes**

Beside georchestra/docker directory, you need to clone [georchestra/georchestra repo](https://github.com/georchestra/georchestra) first.

Next, install maven to execute [main georchestra Makefile](https://github.com/georchestra/georchestra/blob/master/Makefile) on each modification (e.g console, security-proxy, whatever you change).

For example, if you change some security-proxy code, use :

`make docker-build-proxy`

... to execute easily this maven command :

https://github.com/georchestra/georchestra/blob/3b703b9f59a1d9091b7699c6656385f931e1f11e/Makefile#L41-L42

**2. Compose**

In /docker :

`docker compose up -d`

You can now test modifications locally with the current FQDN (by default `georchestra-127-0-1-1.traefik.me`).

**3. Debug**

- Force traefik port

You have to force traefik port.

Open `docker/docker-compose.override.yml` file and complete `proxy` section to add this line :

`"traefik.http.services.my-service.loadbalancer.server.port=8080"`

Proxy section begin now with something like : 

```
  proxy:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.proxy.tls=true"
      - "traefik.http.routers.proxy.priority=100"
      - "traefik.http.services.my-service.loadbalancer.server.port=8080"
      - >-
```

- Ports bindings

Open `docker/docker-compose.yml` and identify `proxy` section.

Change `proxy` section to insert some JAVA options and ports `5005` to get :

```
  proxy:
    image: georchestra/security-proxy:latest
    depends_on:
      - ldap
      - database
    volumes:
      - ./config:/etc/georchestra
    environment:
      - JAVA_OPTIONS=-Dorg.eclipse.jetty.annotations.AnnotationParser.LEVEL=OFF -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=0.0.0.0:5005
      - XMS=256M
      - XMX=1G
    restart: always
    ports:
      - "5005:5005"
```

Apply Docker changes :

`docker compose up -d`

You can now attach IDE to debug the code tep by step on port `5005`.




