# About

migration to Geonetwork 4 will require several extra services, as the indexes are no longer managed by GeoNetwork itself. This is why you can find back 2 new services in the composition:

* elasticsearch
* kibana

# Kibana

the `kibana` service is used for dashboarding purposes and is integrated to the Geonetwork admin UI. See in the `Statistics & status / Content statistics` admin menu to access it.

A specific configuration is provided in the `kibana/` subdirectory.

Please note that it will require to load by hand the following file from the kibana admin ui:

https://raw.githubusercontent.com/georchestra/geonetwork/georchestra-gn4-4.x-dev/es/es-dashboards/data/export.ndjson#



# Elasticsearch

In the current state of the docker composition, no volume is defined, so do not expect persistence of the indexes.

## Disabling disk quota / watermark

If you are running low on disk space, Elastic has a mechanism to pass the index in a read-only mode. You can deactivate this feature by following this guide:

https://techoverflow.net/2019/04/17/how-to-disable-elasticsearch-disk-quota-watermark/

