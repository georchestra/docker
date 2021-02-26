# geOrchestra on Docker

## Quick Start

Grab a machine with a decent amount of RAM (at least 8Gb, better with 12 or 16Gb).

Install a recent [docker](https://docs.docker.com/engine/installation/) & [docker-compose](https://docs.docker.com/compose/install/) version (not from your distro, these packages are probably too old).

Clone this repo and its submodule using:
```
git clone --recurse-submodules https://github.com/georchestra/docker.git
```

Choose which branch to run, eg for latest stable:
```
git checkout 20.1 && git submodule update
```

Run geOrchestra with
```
docker-compose up
```

Open [https://georchestra-127-0-1-1.traefik.me/](https://georchestra-127-0-1-1.traefik.me/) in your browser.

To login, use these credentials:
 * `testuser` / `testuser`
 * `testadmin` / `testadmin`

To upload data into the GeoServer data volume (`geoserver_geodata`), use rsync:
```
rsync -arv -e 'ssh -p 2222' /path/to/geodata/ geoserver@georchestra-127-0-1-1.traefik.me:/mnt/geoserver_geodata/
```
(password is: `geoserver`)

Files uploaded into this volume will also be available to the geoserver instance in `/mnt/geoserver_geodata/`.

Emails sent by the SDI (eg when users request a new password) will not be relayed on the internet but trapped by a local SMTP service.  
These emails can be read on https://georchestra-127-0-1-1.traefik.me/webmail/ (with login `smtp` and password `smtp`).

Stop geOrchestra with
```
docker-compose down
```

## About the domain name

The current FQDN `georchestra-127-0-1-1.traefik.me` resolves to 127.0.1.1, thanks to [traefik.me](https://traefik.me/) which provides wildcard DNS for any IP address.

To change it:
 * Rename the traefik service in the `docker-compose.override.yml` file to match the new domain
 * Modify the three `traefik.frontend.rule` in the `docker-compose.override.yml` file
 * Change the domain in the `resources/traefik.toml` file
 * Update the datadir in the config folder (hint: grep for `georchestra-127-0-1-1.traefik.me`)
 * Put a valid SSL certificate in the `resources/ssl` folder and declare it in the `resources/traefik.toml` file

## Geofence

If you want to run the Geofence enabled GeoServer, make sure the correct docker image is being used in `docker-compose.yml`:

```
image: georchestra/geoserver:20.1.x-geofence
```
(replace `20.1.x-geofence` by the appropriate version - use `latest-geofence` on master).

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


## Notes

These docker-compose files describe:
 * which images / webapps will run,
 * how they are linked together,
 * where the configuration and data volumes are

The `docker-compose.override.yml` file adds services to interact with your geOrchestra instance (they are not part of geOrchestra "core"):
 * reverse proxy / load balancer
 * ssh / rsync services,
 * smtp, webmail.

Feel free to comment out the apps you do not need.

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
