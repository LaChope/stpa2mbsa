#!/bin/bash
echo "HTTP/1.0 200 OK"
echo "Content-type: text/html"
echo
echo

RDF4J_SERVER=http://rdf4j:8080/rdf4j-server
DATA_REPOSITORY_NAME=csat-planning-data
UPDATE_REPOSITORY_NAME=csat-planning-update
CONTENT_TYPE='text/turtle'

echo "INFO: Creating repository $DATA_REPOSITORY_NAME ..."
curl $RDF4J_SERVER/repositories/$DATA_REPOSITORY_NAME -X PUT -d @../../rdf4j/data-repository-config.ttl -H "Content-Type: $CONTENT_TYPE" 2>&1
echo "INFO: Creating repository $UPDATE_REPOSITORY_NAME ..."
curl $RDF4J_SERVER/repositories/$UPDATE_REPOSITORY_NAME -X PUT -d @../../rdf4j/update-repository-config.ttl -H "Content-Type: $CONTENT_TYPE" 2>&1