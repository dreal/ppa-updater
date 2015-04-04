#!/usr/bin/env bash
#
# Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
# Released under Apache 2.0 license as described in the file LICENSE.
#
# Author: Soonho Kong
#
#             12.04  14.04  14.10
set -e  # Abort if any command fails
UPDT_PATH="`dirname \"$0\"`"
UPDT_PATH="`( cd \"$UPDT_PATH\" && pwd )`"
cd $UPDT_PATH
DIST_LIST="precise trusty utopic"
ORG=dreal
REPO=dreal
URGENCY=medium
AUTHOR_NAME="Soonho Kong"
AUTHOR_EMAIL="soonhok@cs.cmu.edu"
EXTERNAL_PROJECT_ROOT=https://github.com/dreal-deps
EXTERNAL_PROJECTS="filibxx capdDynSys-4.0 gflags glog googletest json11"

if [ ! -d $REPO ] ; then
    git clone git@github.com:${ORG}/${REPO}
fi

DATETIME=`date +"%Y%m%d%H%M%S"`
DATE_STRING=`date -R`

for DIST in ${DIST_LIST}
do
    echo "=== 1. Create debian/changelog file"
    VERSION=`./get_version.sh ${REPO} ${DATETIME} ${DIST}`
    cp debian/changelog.template                               debian/changelog
    sed -i "s/##REPO##/${REPO}/g"                              debian/changelog
    sed -i "s/##VERSION##/${VERSION}/g"                        debian/changelog
    sed -i "s/##DIST##/${DIST}/g"                              debian/changelog
    sed -i "s/##URGENCY##/${URGENCY}/g"                        debian/changelog
    sed -i "s/##COMMIT_MESSAGE##/bump to version ${VERSION}/g" debian/changelog
    sed -i "s/##AUTHOR_NAME##/${AUTHOR_NAME}/g"                debian/changelog
    sed -i "s/##AUTHOR_EMAIL##/${AUTHOR_EMAIL}/g"              debian/changelog
    sed -i "s/##DATE_STRING##/${DATE_STRING}/g"                debian/changelog
    cp -r debian ${REPO}/debian

    echo "=== 2. Download external projects"
    for EXTERNAL in ${EXTERNAL_PROJECTS}
    do
        if [ -e ${REPO}/src/${EXTERNAL}.zip ] ; then
            rm -- ${REPO}/src/${EXTERNAL}.zip
        fi
        wget ${EXTERNAL_PROJECT_ROOT}/${EXTERNAL}/archive/master.zip -O ${REPO}/src/${EXTERNAL}.zip
        echo "=== ${EXTERNAL_PROJECT_ROOT}/${EXTERNAL}/archive/master.zip"
    done

    echo "=== 3. Replace ${REPO}/src/CMakeLists.txt with ${REPO}/src/CMakeLists.ppa.txt"
    cp ${REPO}/src/CMakeLists.ppa.txt ${REPO}/src/CMakeLists.txt

    echo "=== 4. Build OCaml Tools"
    make -C ${REPO}/tools
    mv ${REPO}/tools/_build/bmc/src/bmc_main.native ${REPO}/bin/bmc_main.native
    rm -rf ${REPO}/tools/_build

    echo "=== 5. ${REPO}_${VERSION}.orig.tar.gz"
    tar -acf ${REPO}_${VERSION}.orig.tar.gz --exclude ${REPO}/.git ${REPO}
    cd ${REPO}
    debuild -S -sa
    cd ..

    echo "=== 6. Upload: ${REPO}_${VERSION}_source.changes"
    dput -f ppa:${ORG}/${REPO} ${REPO}_${VERSION}_source.changes
    rm -- ${REPO}_*
    rm -rf -- ${REPO}/debian debian/changelog
    rm ${REPO}/bin/bmc
done
