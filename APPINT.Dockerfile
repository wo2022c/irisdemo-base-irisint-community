# FROM docker.iscinternal.com/intersystems/iris-community:2020.1.0-latest
FROM intersystemsdc/irisdemo-base-irisint-community:iris-community.2021.2.0.619.0

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

# Get Java OpenJDK 1.8 for JDBC and/or Java Gateway, which must run as root user
USER root
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER irisowner

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Name of the project folder ex.: irisdemoint-atelier-project
ARG IRIS_PROJECT_FOLDER_NAME=irisdemoint-atelier-project

# Used to specify a folder on the container with the source code (csp pages, classes, etc.)
# to load into the CSP application.
ENV IRIS_APP_SOURCEDIR=/tmp/iris_project/

# Name of the application. This will be used to define the namespace, database and 
# name of the CSP application of this application.
ENV IRIS_APP_NAME="APPINT"

# IRIS Global buffers and Routine Buffers
ENV IRIS_GLOBAL_BUFFERS=128
ENV IRIS_ROUTINE_BUFFERS=64

# Adding source code that will be loaded by the installer
# The ADD command ignores the current USER and always add as root. 
# That is why were are doing the chown
ADD --chown=irisowner:irisuser ./${IRIS_PROJECT_FOLDER_NAME}/ $IRIS_APP_SOURCEDIR

# Adding scripts to load base image source and child image source
ADD --chown=irisowner:irisuser ./imageBuildingUtils.sh /demo/imageBuildingUtils.sh
ADD --chown=irisowner:irisuser ./irisdemobaseinstaller.sh /demo/irisdemobaseinstaller.sh
ADD --chown=irisowner:irisuser ./irisdemoinstaller.sh /demo/irisdemoinstaller.sh

# Running irisdemobaseinstaller will trigger irisdemoinstaller too. In this case, we do have
# some basic source code from the base image that we want to load, so that is fine. Child images
# will be able to just run irisdemoinstaller.sh to load and compile their own source code.
RUN /demo/irisdemobaseinstaller.sh

HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1