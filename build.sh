#!/bin/bash

IRIS_PROJECT_FOLDER_NAME=irisdemoint-atelier-project
GIT_REPO_NAME=irisdemo-base-irisint-community
TAG=version-$(cat ./VERSION)
IMAGE_NAME=intersystemsdc/$GIT_REPO_NAME:$TAG

USER_IMAGE_NAME=intersystemsdc/$GIT_REPO_NAME:${TAG}U

docker build --build-arg IRIS_PROJECT_FOLDER_NAME=$IRIS_PROJECT_FOLDER_NAME --force-rm -t $IMAGE_NAME -f ./APPINT.Dockerfile .

docker build --build-arg IRIS_PROJECT_FOLDER_NAME=$IRIS_PROJECT_FOLDER_NAME --force-rm -t $USER_IMAGE_NAME -f ./USER.Dockerfile .