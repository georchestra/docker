This folder contains SSL material for the docker composition default FQDN.

It is empty (except this readme) when you clone it: the certificate's files are automatically downloaded and stored here by the traefik-me-certificate-downloader container (see docker-compose.override.yml).


For a public service, you should use Traefik's ability to [generate its own certificates](https://doc.traefik.io/traefik/https/acme/) using [Let's Encrypt](https://letsencrypt.org/).
