run-silent:
	docker-compose up -d

run:
	docker-compose up

# run without the docker-compose.override.yml
run-core:
	docker-compose -f docker-compose.yml up

# make local valid certs
# mkcert need to be init first !! (must done once only)
cert:
	cd resources/ssl
	mkcert georchestra.mydomain.org
	cp georchestra.mydomain.org.pem georchestra.mydomain.org.crt
	cp georchestra.mydomain.org-key.pem georchestra.mydomain.org.key

