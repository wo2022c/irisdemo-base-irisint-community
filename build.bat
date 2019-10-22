@ECHO OFF

set IRIS_PROJECT_FOLDER_NAME=irisdemoint-atelier-project

set GIT_REPO_NAME=irisdemo-base-irisint-community
set TAG=latest
set IMAGE_NAME=intersystemsdc/%GIT_REPO_NAME%:%TAG%

docker build --build-arg IRIS_PROJECT_FOLDER_NAME=%IRIS_PROJECT_FOLDER_NAME% --force-rm -t %IMAGE_NAME% .