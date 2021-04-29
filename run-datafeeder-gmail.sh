#!/bin/bash

account="noreply.georchestra.dev@gmail.com"

if [ ! -f ".env" ]; then
	echo "There's no .env file, create it and set the SMTP_PASSWORD variable to the $account account password"
	exit 1
fi

source .env

if [ -z "$SMTP_PASSWORD" ]; then
	echo "Declare the SMTP_PASSWORD variable in .env with the $account account password"
	exit 1
fi

files="-f docker-compose.yml -f docker-compose.override.yml -f docker-compose.datafeeder.gmail.yml"

echo "SMTP_PASSWORD found in .env, running"
echo "docker-compose $files up -d"

docker-compose $files up -d
