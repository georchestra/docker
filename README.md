# geOrchestra on Docker

## Quick Start

Grab a machine with a decent amount of RAM (at least 8Gb, better with 12 or 16Gb).

Install a recent [docker](https://docs.docker.com/engine/installation/) & [docker-compose](https://docs.docker.com/compose/install/) version (not from your distro, these packages are probably too old).

Clone this repo and its submodule using:
```
git clone https://github.com/georchestra/docker.git
cd docker && git submodule update --init --remote
```

Edit your `/etc/hosts` file with the following:
```
127.0.1.1	georchestra.mydomain.org
```

Run geOrchestra with
```
docker-compose up
```

Open [https://georchestra.mydomain.org/](https://georchestra.mydomain.org/) in your browser.

To login, use these credentials:
 * `testuser` / `testuser`
 * `testadmin` / `testadmin`

To upload data into the GeoServer data volume (`geoserver_geodata`), use rsync:
```
rsync -arv -e 'ssh -p 2222' /path/to/geodata/ geoserver@georchestra.mydomain.org:/mnt/geoserver_geodata/
```
(password is: `geoserver`)

Files uploaded into this volume will also be available to the geoserver instance in `/mnt/geoserver_geodata/`.

Emails sent by the SDI (eg when users request a new password) will not be relayed on the internet but trapped by a local SMTP service.  
These emails can be read on https://georchestra.mydomain.org/webmail/ (with login `smtp` and password `smtp`).

Stop geOrchestra with
```
docker-compose down
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
If you need them, you have to include a complementary docker-compose file at run-time:
```
docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.other-apps.yml up
```

## Upgrading

Images and configuration are updated regularly.

To upgrade, we recommend you to:
 * update the configuration with `git submodule update --remote`
 * update the software with `docker-compose pull`


## Customising

Adjust the configuration in the `config` folder according to your needs.
Reading the [quick configuration guide](https://github.com/georchestra/datadir/blob/docker-master/README.md) might help !

Most changes will require a service restart, except maybe updating viewer contexts & addons (`F5` will do).

## Building

Images used in the current composition are pulled from docker hub, which means they've been compiled by our CI.
In case you have to build these images by yourself (for instance, to rely on stable branches), please refer to the [docker images build instructions](https://github.com/georchestra/georchestra/blob/master/docker/README.md).
