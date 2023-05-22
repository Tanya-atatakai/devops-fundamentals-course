#!/bin/bash

# Build the Docker image with tags
docker build -t atatakai/nextjs-rest-api:latest .
docker push atatakai/nextjs-rest-api:latest