#!/bin/bash
#
# This script should not no longer be necessary now that IRIS for Health Community 2019.3 is 
# publicly available on the Docker Store. But the problem is that we are facing problems when 
# running automated builds configured on Docker Hub with images based on the ones published 
# on store/intersystems/iris or store/intersystems/irishealth. 
#
# If we just copy the base image from InterSystems to our own repo, the automated build works.
#

#
# Parameter
#
#TAG=2019.4.0.379.0
#TAG=2020.1.0.197.0
#TAG=2020.2.0.196.0
# TAG=2020.2.0.211.0
# TAG=2020.3.0.200.0
# TAG=2021.1.0.215.3
# TAG=2021.2.0.619.0
# TAG=2021.2.0.649.0
# TAG=2021.2.0.651.0
TAG=2022.1.0.209.0

#
# Constants
#

# Taking from InterSystems repository on Docker Hub:
ISC_IMAGENAME=arti.iscinternal.com/intersystems/iris-community:$TAG
# ISC_IMAGENAME=store/intersystems/iris-community:$TAG

# Pushing to our repository on Docker Hub:
DH_IMAGENAME=intersystemsdc/irisdemo-base-irisint-community:iris-community.$TAG


printf "\n\nLoggin into docker.iscinternal.com (VPN Required!) to download newer images...\n"
docker login containers.intersystems.com

printf "\n\nPulling images...\n"
docker pull $ISC_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\nPull of $ISC_IMAGENAME succesful. \n"
else
    printf "\nPull of $ISC_IMAGENAME failed. \n"
    exit 0
fi

printf "\nTagging images...\n"
docker tag $ISC_IMAGENAME $DH_IMAGENAME

if [ $? -eq 0 ]; then
    printf "\nTagging of $ISC_IMAGENAME as $DH_IMAGENAME successful\n"
else
    printf "\nTagging of $ISC_IMAGENAME as $DH_IMAGENAME failed\n"
    exit 0
fi

printf "\n\nEnter with your credentials on docker hub so we can upload the images:\n"
docker login

printf "\n\nUploading images...\n"
docker push $DH_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\nPushing of $DH_IMAGENAME successful.\n"
else
    printf "\nPushing of $DH_IMAGENAME successful.\n"
    exit 0
fi