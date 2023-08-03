#!/bin/bash

# Set the deployment, container, request memory, and limit memory variables
deployment_name="PLACEHOLDER"
container_name="PLACEHOLDER"
request_memory="PLACEHOLDER"
limit_memory="2GPLACEHOLDERi"

# Patch the deployment with the specified memory settings
kubectl patch deployment "$deployment_name" -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"$container_name\",\"resources\":{\"requests\":{\"memory\":\"$request_memory\"},\"limits\":{\"memory\":\"$limit_memory\"}}}]}}}}"