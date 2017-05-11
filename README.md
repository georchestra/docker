# geOrchestra on Docker

Clone this repo to run geOrchestra on Docker in a minute:
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
