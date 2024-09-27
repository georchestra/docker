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
git checkout 23.0 && git submodule update
```

**3. Run**

The default docker-compose file contains all geOrchestra modules.

It's recommended to double-check the `docker-compose.yml` and `docker-compose.override.yml` files if you need to comment useless modules (e.g extractor, mapstore,... ).

You need to use the new Compose plugin V2, `docker-compose` (V1) is not supported by default: [https://docs.docker.com/compose/install/linux/](https://docs.docker.com/compose/install/linux/).   
If you still want to use the old `docker-compose` (V1), you need to remove all the parameters `depends_on` from the files `docker-compose.yml` and `docker-compose.override.yml`.

To run:

```
cd docker
docker compose up -d
```


To stop geOrchestra:
```
docker compose down
```

**4. Play**

Open [https://georchestra-127-0-1-1.traefik.me/](https://georchestra-127-0-1-1.traefik.me/) in your browser. Then:

* Accept the security warning.
* Or solve the security warning by [following this step](#locally-trust-the-tls-certificate-for-georchestra).

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


## Locally trust the TLS certificate for geOrchestra
### On Linux

1. Download Caddy binary: `wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O caddy`
2. Make it executable: `chmod +x caddy`
3. Trust the certificate using this command: `./caddy trust`.
4. Open [https://georchestra-127-0-1-1.traefik.me/](https://georchestra-127-0-1-1.traefik.me/) in your browser.  
   If that doesn't work, try to restart your browser.

### On Windows
1. Download Caddy binary: https://caddyserver.com/download  
   Click on Download button on the website.
2. Open the Downloads folder using your file explorer and rename the file downloaded to `caddy`.
3. Open the command prompt (cmd) and navigate to your Downloads folder.
   `cd "C:\Users\%USERNAME%\Downloads"`
3. Trust the certificate using this command: `caddy trust`.
4. Open [https://georchestra-127-0-1-1.traefik.me/](https://georchestra-127-0-1-1.traefik.me/) in your browser.  
   If that doesn't work, try to restart your browser.

## About the domain name

The current FQDN `georchestra-127-0-1-1.traefik.me` resolves to 127.0.1.1, thanks to [traefik.me](https://traefik.me/) which provides wildcard DNS for any IP address.

To change it:

1. Update the FQDN variable in [.envs-common](.envs-common) file (hint: grep for `georchestra-127-0-1-1.traefik.me`)
2. Two options for the TLS/SSL certificate:
    * If your web server is exposed to the internet (most likely it is), remove `tls internal` line in the file `resources/caddy/etc/Caddyfile`.
    * If it is not, put a valid TLS certificate and a private key in the `resources/ssl` folder and declare it in the file `resources/caddy/etc/Caddyfile`.
3. Reload the docker composition: `docker compose up -d`.  
   May need to restart Caddy later if you are just modifying the Caddyfile or some file resources: `docker compose restart caddy`.

## Notes

Find the Caddy web server documentation here: https://caddyserver.com/docs/caddyfile/directives.

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
docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.gwc.yml -f docker-compose.atlas.yml up
```

## Upgrading

Images and configuration are updated regularly.

To upgrade, we recommend you to:
 * update the configuration with `git submodule update`
 * update the software with `docker compose pull`


## Customising

This docker composition supports environment variables, if you need to customize something it might be in the different environment variables files.

Here is the list of these files:
- [.envs-common](.envs-common) 
- [.envs-database-datafeeder](.envs-database-datafeeder)
- [.envs-database-georchestra](.envs-database-georchestra)
- [.envs-hosts](.envs-hosts)
- [.envs-ldap](.envs-ldap)

If you add variables, be careful because it might be added into the wrong/unwanted container.

You can also add environment variables directly into the docker-compose.yaml if needed.

To check which container is including which envs file you can look at the docker-compose* files and search for the .envs-* filename wanted.

If you don't find the value in it, there is still a lot to
adjust the configuration in the `config` folder according to your needs.
Reading the [quick configuration guide](https://github.com/georchestra/datadir/blob/docker-master/README.md) might help !

Also in production environment don't forget to change the file into the [secret/](secrets/) folder as they are default password.

For [geoserver_privileged_user_passwd.txt](secrets/geoserver_privileged_user_passwd.txt) it needs to be the same that in the datadir : https://github.com/georchestra/datadir#3-steps-editing

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

Open `docker/docker-compose.yml` and identify `proxy` section.

Change `proxy` section to insert some JAVA options and ports `5005` to get :

```
  proxy:
    image: georchestra/security-proxy:latest
    depends_on:
      - ldap
      - database
    volumes:
      - georchestra_datadir:/etc/georchestra
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
