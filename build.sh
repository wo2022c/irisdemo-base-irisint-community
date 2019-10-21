#!/bin/bash

IRIS_PROJECT_FOLDER_NAME=irisdemoint-atelier-project
GIT_REPO_NAME=irisdemo-base-irisint-community
TAG=2019.3-1.0
IMAGE_NAME=intersystemsdc/$GIT_REPO_NAME:$TAG

docker build --build-arg IRIS_PROJECT_FOLDER_NAME=$IRIS_PROJECT_FOLDER_NAME --force-rm -t $IMAGE_NAME .