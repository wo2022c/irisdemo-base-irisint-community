#!/bin/bash
#
# This script pushes a built image to Docker Hub
#

GIT_REPO_NAME=irisdemo-base-irisint-community
TAG=2019.3-1.0
IMAGE_NAME=intersystemsdc/$GIT_REPO_NAME:$TAG

docker push $IMAGE_NAME