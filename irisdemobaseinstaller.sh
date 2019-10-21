#!/bin/bash
#
# This script loads and compiles the Installer Manifest on class IRISConfig.InstallerBase.
# The class will be run on %SYS namespace as it should be.

# From now on, any error should interrupt the script
set -e

printf "\nLoading base installer...\n"

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

# This specific command may fail on images that are based on this because I don't expect to find IRISDemo.InstallerBase 
# on the developer's project (they should not override this class on their projects!)
# That is why we are not checking the status code.
printf "zn \"%s\"\nSet tSC=\$system.OBJ.Load(\"%s\",\"ck\")\n" "%SYS" "/tmp/iris_project/IRISConfig/InstallerBase.cls" | irissession IRIS

# Call the script to load child image source
source /usr/irissys/demo/irisdemoinstaller.sh