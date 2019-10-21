#!/bin/bash
#
# This script loads and compiles the Installer Manifest on class IRISConfig.Installer.
# The class will be run on %SYS namespace as it should be.

# From now on, any error should interrupt the script
set -e

# This entire block must be run on child images only. If we are building the base image,
# this script is being called by irisdemobaseinstaller.sh which will have started iris for
# us already. And we don't care about global buffers when building the base image.
if [ "$(iris qall | awk '/IRIS/{ print $1 }')" != "up" ]
then
    printf "\n Configuring global buffers..."
    sed -i "s/globals=.*/globals=0,0,$IRIS_GLOBAL_BUFFERS,0,0,0/" /usr/irissys/iris.cpf

    printf "\n Configuring routine buffers..."
    sed -i "s/routines=.*/routines=$IRIS_ROUTINE_BUFFERS/" /usr/irissys/iris.cpf

    # The sed commands above change the permissions on the iris.cpf from irisowner:irisuser 664
    # to irisowner:irisowner 664. When that is the case, IRIS cannot start up because it runs
    # as irisuser which no longer has write permissions on the iris.cpf file
    chmod 666 /usr/irissys/iris.cpf
    
    # The touch command is necessary so we will bring the IRIS.DAT database files to our
    # R/W layer and all the IRIS processes will get the same file descriptor to
    # this file. That was necessary because some times, when compiling large groups
    # of classes, IRIS will spawn parallel processes to speed up the compilation. Some
    # of these processes would crash or dead-lock situations would occur because they would
    # have the wrong file descriptor to the IRIS.DAT file (the one that is read-only). 
    if [ -d $ISC_PACKAGE_INSTALLDIR/mgr/$IRIS_APP_NAME ]
    then
        touch $ISC_PACKAGE_INSTALLDIR/mgr/$IRIS_APP_NAME/IRIS.DAT
    fi
    touch $ISC_PACKAGE_INSTALLDIR/mgr/irislib/IRIS.DAT

    iris start iris

    VerifySC='If $System.Status.IsError(tSC) { Do $System.Status.DisplayError(tSC) Do $zu(4,$j,1) } Else { Do $zu(4,$j,0) }'
fi

printf "\n\nLoading Installer..."

# This depends on the existence of the previous class, it may fail if it hasn't been loaded correctly.
printf "zn \"%s\"\nSet tSC=\$system.OBJ.Load(\"%s\",\"ck\")\n$VerifySC\n" "%SYS" "/tmp/iris_project/IRISConfig/Installer.cls" | irissession IRIS

# Removing Eclipse/Atelier files so that when we try to load our project we don't get the error:
# ERROR #5840: Unable to import file '/tmp/iris_project/.buildpath' as this is not a supported type.ERROR: Service 'twittersrv' failed to build: The command '/bin/sh -c /usr/irissys/demo/irisdemoinstaller.sh' returned a non-zero code: 1
rm -f /tmp/iris_project/.buildpath
rm -f /tmp/iris_project/.project
rm -rf /tmp/iris_project/.settings

printf "\n\nRunning Installer..."
printf "%s\n%s\n" "zn \"%SYS\"" "Do ##class(IRISConfig.Installer).Install()" | irissession IRIS

# CLEANING UP ---------------------------------------------------------------------------------
#
# We possibly should be using /usr/irissys/dev/Container/imageBuildSteps.sh to do the clean up.
# But 1 - imageBuildSteps.sh must be run as root and here we are running as irisowner,
# and 2 - imageBuildSteps.sh does not clean up as much as we would like to here

printf "\n\nCleaning up..."
printf "%s\n%s\n%s\n%s\n" "zn \"%SYS\"" "do INT^JRNSTOP" "kill ^%SYS(\"JOURNAL\") kill ^SYS(\"NODE\") Halt" | irissession IRIS

iris stop iris quietly
"$ISC_PACKAGE_INSTALLDIR"/dev/Cloud/ICM/waitISC.sh "$ISC_PACKAGE_INSTANCENAME" 60 "down"

rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal.log
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/iris.ids
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal/*
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/messages.log

# CLEANING UP COMPLETE ------------------------------------------------------------------------

# Removing the folder on the container with the source code (csp pages, classes, etc.)  
rm -rf /tmp/iris_project