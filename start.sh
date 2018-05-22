#!/bin/sh -e
# Copyright (C) 2018 Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

CONTAINER_IMAGE=softwarefactoryproject/2018-opendevconf-wadci
DATASETS_URL=https://fedorapeople.org/~tdecacqu/2018-opendevconf-wadci.tar.bz2

echo "Downloading ${DATASETS_URL} datasets and pulling ${CONTAINER_IMAGE} image"

DATASETS_FILE=$(basename $DATASETS_URL)

if ! test -f $DATASETS_FILE; then
  curl -o $DATASETS_FILE $DATASETS_URL
fi

if ! test -d datasets/03-jobs/_models; then
    tar xjf $DATASETS_FILE
fi

if type podman &> /dev/null; then
    echo "Yay, #nobigfatdaemon"
    CR=podman
elif type docker &> /dev/null; then
    CR=docker
    systemctl is-active -q docker || sudo systemctl start docker
else
    echo "Installing container runtime"
    if grep -q fedora /etc/os-release && sudo dnf install -y podman; then
        CR=podman
    else
        sudo yum install -y docker || sudo apt-get install -y docker || sudo emerge -v docker
        sudo systemctl start docker
        CR=docker
    fi
fi


sudo $CR pull $CONTAINER_IMAGE
set -x
sudo $CR run --volume $(pwd)/datasets:/datasets \
             --network host                     \
             --security-opt label=disable       \
             -it $CONTAINER_IMAGE
