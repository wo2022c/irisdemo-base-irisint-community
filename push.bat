@ECHO OFF
::
:: This script pushes a built image to Docker Hub
::

set GIT_REPO_NAME=irisdemo-base-irisint-community
set TAG=2019.3-1.0
set IMAGE_NAME=intersystemsdc/%GIT_REPO_NAME%:%TAG%

docker push %IMAGE_NAME%