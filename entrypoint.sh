#!/bin/bash

set -e

USERNAME=$1
PASSWORD=$2
REPOSITORY=$3
REGISTRY=$4
TAG=$5
TAGLEGACY=$6

if [ -z $USERNAME ]; then
  echo 'Required username parameter'
  exit 1
fi

if [ -z $PASSWORD ]; then
  echo 'Required password parameter'
  exit 1
fi

if [ -z $REPOSITORY ]; then
  echo 'Required repository parameter'
  exit 1
fi

if [[ -z $TAG ]]; then
  echo 'Tag to snapshot'
  TAG=$(date '+%Y%m%d%H%M%S')
fi


IMAGE=$REPOSITORY:$TAG
if [ -n "$REGISTRY" ]; then
  IMAGE=$REGISTRY/$IMAGE
fi

docker login --username "$USERNAME" --password "$PASSWORD" $REGISTRY
if [[ -z $TAGLEGACY ]]; then
  LEGACYIMAGE=$REPOSITORY:$TAGLEGACY
  docker image pull $IMAGE && docker image tag $IMAGE $LEGACYIMAGE && docker push $LEGACYIMAGE 1>/dev/null 2>/dev/null
fi
docker build -t $IMAGE .
docker push $IMAGE

echo ::set-output name=image::$IMAGE
