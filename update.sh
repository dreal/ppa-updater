#!/usr/bin/env bash
#
# Copyright (c) 2014 - 2015 Carnegie Mellon University. All rights reserved.
# Released under Apache 2.0 license as described in the file LICENSE.
#
# Author: Soonho Kong
#
#             12.04  14.04  15.04  15.10
set -e  # Abort if any command fails
UPDT_PATH="`dirname \"$0\"`"
UPDT_PATH="`( cd \"$UPDT_PATH\" && pwd )`"
cd $UPDT_PATH
DIST_LIST="precise trusty vivid wily"
ORG=dreal
REPO=dreal3
PPA_NAME=dreal
PKG_NAME=dreal
URGENCY=medium
AUTHOR_NAME="Soonho Kong"
AUTHOR_EMAIL="soonhok@cs.cmu.edu"
EXTERNAL_PROJECT_ROOT=https://github.com/dreal-deps
EXTERNAL_PROJECTS="filibxx nlopt capdDynSys-4.0 clp-1.16 ibex-lib Catch easyloggingpp ezoptionparser json gsl-1.16"

# Check out lean if it's not here and update PREVIOUS_HASH
if [ ! -d ./${REPO} ] ; then
    git clone ${GIT_REMOTE_REPO}
    DOIT=TRUE
    cd ${REPO}
    git rev-parse HEAD > PREVIOUS_HASH
    cd ..
fi

# Update CURRENT_HASH
cd ${REPO}
git fetch --all --quiet
git reset --hard origin/master --quiet
git rev-parse HEAD > CURRENT_HASH
cd ..

# Only run the script if there is an update
if ! cmp ${REPO}/PREVIOUS_HASH ${REPO}/CURRENT_HASH >/dev/null 2>&1
then
    DOIT=TRUE
fi

# '-f' option enforce update
if [[ $1 == "-f" ]] ; then
    DOIT=TRUE
fi

if [[ $DOIT == TRUE ]] ; then

    DATETIME=`date +"%Y%m%d%H%M%S"`
    DATE_STRING=`date -R`

    for DIST in ${DIST_LIST}
    do
        echo "=== 1. Create debian/changelog file"
        VERSION=`./get_version.sh ${REPO} ${DATETIME} ${DIST}`
        cp debian/changelog.template                               debian/changelog
        sed -i "s/##PKG_NAME##/${PKG_NAME}/g"                      debian/changelog
        sed -i "s/##VERSION##/${VERSION}/g"                        debian/changelog
        sed -i "s/##DIST##/${DIST}/g"                              debian/changelog
        sed -i "s/##URGENCY##/${URGENCY}/g"                        debian/changelog
        sed -i "s/##COMMIT_MESSAGE##/bump to version ${VERSION}/g" debian/changelog
        sed -i "s/##AUTHOR_NAME##/${AUTHOR_NAME}/g"                debian/changelog
        sed -i "s/##AUTHOR_EMAIL##/${AUTHOR_EMAIL}/g"              debian/changelog
        sed -i "s/##DATE_STRING##/${DATE_STRING}/g"                debian/changelog
        rm -rf ${REPO}/debian
        cp -r debian ${REPO}/debian

        echo "=== 2. Download external projects"
        mkdir -p ${REPO}/src/third_party
        for EXTERNAL in ${EXTERNAL_PROJECTS}
        do
            if [ -e ${REPO}/src/third_party/${EXTERNAL}.zip ] ; then
                rm -- ${REPO}/src/third_party/${EXTERNAL}.zip
            fi
            wget ${EXTERNAL_PROJECT_ROOT}/${EXTERNAL}/archive/master.zip -O ${REPO}/src/third_party/${EXTERNAL}.zip
            echo "=== ${EXTERNAL_PROJECT_ROOT}/${EXTERNAL}/archive/master.zip"
        done

        echo "=== 3. Build OCaml Tools"
        make -C ${REPO}/tools

        echo "=== 4. ${PKG_NAME}_${VERSION}.orig.tar.gz"
        tar -acf ${PKG_NAME}_${VERSION}.orig.tar.gz --exclude ${REPO}/.git ${REPO}
        cd ${REPO}
        debuild -S -sa
        cd ..

        echo "=== 5. Upload: ${PKG_NAME}_${VERSION}_source.changes"
        dput -f ppa:${ORG}/${PPA_NAME} ${PKG_NAME}_${VERSION}_source.changes
        rm -- ${PKG_NAME}_*
        rm -rf -- ${REPO}/debian debian/changelog
        rm ${REPO}/bin/bmc
    done
else
    echo "Nothing to do."
fi
mv ${REPO}/CURRENT_HASH ${REPO}/PREVIOUS_HASH
