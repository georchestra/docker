run-silent:
	docker-compose up -d

run:
	docker-compose up

# run without the docker-compose.override.yml
run-core:
	docker-compose -f docker-compose.yml up
