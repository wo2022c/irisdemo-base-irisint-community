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
TAG=2019.4.0.379.0

#
# Constants
#

# Taking from InterSystems repository on Docker Hub:
ISC_IMAGENAME=store/intersystems/iris-community:$TAG

# Pushing to our repository on Docker Hub:
DH_IMAGENAME=intersystemsdc/irisdemo-base-irisint-community:iris-community.$TAG


printf "\n\nLoggin into docker.iscinternal.com (VPN Required!) to download newer images...\n"
docker login docker.iscinternal.com

printf "\n\nPulling images...\n"
docker pull $ISC_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\nPull of $ISC_IMAGENAME succesful. \n"
else
    printf "\nPull of $ISC_IMAGENAME failed. \n"
    exit 0
fi

printf "\n\Tagging images...\n"
docker tag $ISC_IMAGENAME $DH_IMAGENAME

if [ $? -eq 0 ]; then
    printf "\Tagging of $ISC_IMAGENAME as $DH_IMAGENAME successful\n"
else
    printf "\Tagging of $ISC_IMAGENAME as $DH_IMAGENAME failed\n"
    exit 0
fi

printf "\n\nEnter with your credentials on docker hub so we can upload the images:\n"
docker login

printf "\n\Uploading images...\n"
docker push $DH_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\Pushing of $DH_IMAGENAME successful.\n"
else
    printf "\Pushing of $DH_IMAGENAME successful.\n"
    exit 0
fi