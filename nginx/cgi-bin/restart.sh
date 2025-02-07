#!/bin/bash

if [ -z ${HUB_SECRET} ]; then
  echo "HTTP/1.0 200 OK"
  echo "Content-type: text/html"
  echo
  echo
  echo "WH Secret value is unset"
  exit 1
fi

PAYLOAD=$(cat)
HUB_SIGNATURE_256=$HTTP_X_HUB_SIGNATURE_256

# calculate sha1-hmac digest
DIGEST=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$HUB_SECRET" | cut -d= -f2 | tr -d ' \n')
SIGNATURE="sha256=$DIGEST"

[[ $HUB_SIGNATURE_256 == $SIGNATURE ]] || {
  echo "HTTP/1.0 200 OK"
  echo "Content-type: text/html"
  echo
  echo
  echo "Unauthorized"
  exit 1
}

echo "HTTP/1.0 200 OK"
echo "Content-type: text/html"
echo
echo

cd /deploy
sudo docker-compose -f ./docker-compose-dev.yaml restart dashboard 2>&1
