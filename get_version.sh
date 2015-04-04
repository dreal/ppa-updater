#!/usr/bin/env bash
#
# Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
# Released under Apache 2.0 license as described in the file LICENSE.
#
# Author: Soonho Kong
#

usage() {
cat <<EOF
Usage: '$0' <repo_name> <datetime> <ubuntu_distro>

It returns a corresponding version string. For example,

    $0 dreal 20141115015200 precise

returns

    dreal-0.2.0.20141115015200.git0d982cceedc2479ffc3cc68d2a1291c711770028~12.04

EOF
}

REPO=$1
DATE=$2
DIST=$3

if [[ ! $# == 3 ]] ; then
    usage;
    exit 1;
fi

if [[ ! -d ${REPO}/.git ]] ; then
    usage;
    echo "${REPO}/.git is not a directory."
    exit 1;
fi

if   [[ ${DIST} == precise ]] ; then
    DIST_VER=12.04
elif [[ ${DIST} == quantal ]] ; then
    DIST_VER=12.10
elif [[ ${DIST} == raring ]] ; then
    DIST_VER=13.04
elif [[ ${DIST} == saucy ]] ; then
    DIST_VER=13.10
elif [[ ${DIST} == trusty ]] ; then
    DIST_VER=14.04
elif [[ ${DIST} == utopic ]] ; then
    DIST_VER=14.10
else
    usage;
    cat << EOF
Wrong distro name ${DIST}: we support

	precise: 	12.04
	quantal: 	12.10
	raring:		13.04
	saucy:		13.10
	trusty:		14.04
	utopic:		14.10
EOF
    exit 1
fi

VERSION_MAJOR=`grep -o -i "VERSION_MAJOR \([0-9]\+\)" ${REPO}/src/CMakeLists.txt | cut -d ' ' -f 2`
VERSION_MINOR=`grep -o -i "VERSION_MINOR \([0-9]\+\)" ${REPO}/src/CMakeLists.txt | cut -d ' ' -f 2`
VERSION_PATCH=`grep -o -i "VERSION_PATCH \([0-9]\+\)" ${REPO}/src/CMakeLists.txt | cut -d ' ' -f 2`

cd ${REPO}
GIT_HASH=`git log --pretty=format:%H -n 1`

echo ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${DATE}.git${GIT_HASH}~${DIST_VER}