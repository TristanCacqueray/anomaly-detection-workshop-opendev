#!/bin/bash -xe
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

[ -z "$SUDO_COMMAND" ] && exec sudo $0

if ! type buildah; then
    dnf install -y buildah
fi

ctr=$(buildah from fedora)
mnt=$(buildah mount $ctr)

## Install dependencies
buildah run $ctr -- dnf update -y
buildah run $ctr -- dnf install -y vim-enhanced python3-scikit-learn python3-aiohttp python3-systemd python3-pip python3-PyYAML
# Quickfix sklearn warning
patch -d $mnt/usr/lib64/python3.6/site-packages/sklearn/externals/ <<EOF
--- /usr/lib64/python3.6/site-packages/sklearn/externals/six.py 2017-08-04 15:18:56.000000000 +0000
+++ six.py 2018-04-20 01:16:09.463421380 +0000
@@ -4,7 +4,11 @@
 Handle loading six package from system or from the bundled copy
 """

-import imp
+import warnings
+
+with warnings.catch_warnings():
+    warnings.simplefilter("ignore")
+    import imp
 from distutils.version import StrictVersion


EOF

# Install logreduce
buildah run $ctr -- pip3 install logreduce

# Cleanup
buildah run $ctr -- dnf clean all
buildah run $ctr -- rm -Rf /root/.cache

# Setup user environment
buildah run $ctr -- useradd -m user
mkdir $mnt/datasets
buildah run $ctr -- chown -R user:user /datasets

## Include some buildtime annotations
buildah config --annotation "io.softwarefactory-project.build.host=$(uname -n)" $ctr
buildah config --author tdecacqu@redhat.com $ctr
buildah config --cmd "/bin/bash" $ctr
buildah config --workingdir /datasets $ctr
buildah config --user user $ctr

## Commit this container to an image name
buildah umount $ctr
buildah commit $ctr 2018-opendevconf-wadci

echo "Push running:"
echo "sudo buildah push --creds=tdecacqu 2018-opendevconf-wadci docker://docker.io/softwarefactoryproject/2018-opendevconf-wadci"
