# Story

In this example we are building a model for a Zuul jobs to investigate
job failure.

A model for tempest-full and a couple of logs are already prepared:
The first change (e9a003e) prevented neutron-server from starting.
The second change (a8edc4f) introduced a bug in cinder volume management.

# Usage

* To build the model, the user run:

Workshop command (1 hour):

  logreduce --debug job-train                  \
    --job tempest-full                         \
    --include-path controller/                 \
    --count 3                                  \
    --zuul-web http://zuul.openstack.org/api   \
    _models/tempest-full.clf

Expected output:

  ZuulBuilds - Getting http://zuul.openstack.org/api/builds?job_name=tempest-full&branch=master&pipeline=gate&result=SUCCESS
  RecursiveDownload - Listing http://logs.openstack.org/32/563732/3/gate/tempest-full/6b942a1/controller/
  [...]
  _models/tempest-full.clf: built with http://logs.openstack.org/32/563732/3/gate/tempest-full/6b942a1/controller/ http://logs.openstack.org/44/563444/3/gate/tempest-full/739677c/ http://logs.openstack.org/39/561039/3/gate/tempest-full/5913868/


Note: include-path indicate the location of services' logs.


* To use the model, the user run:

Workshop command (15 minutes):

  logreduce --debug job-run                    \
    --include-path controller/                 \
    --html report.html                         \
    _models/tempest-full.clf                   \
    http://logs.openstack.org/XX/YYYYXX/...

Expected output:

  RecursiveDownload - Listing http://logs.openstack.org/XX/YYYYXX/...
  [...]
  99.81% reduction (from 234520 lines to 447)


Note: the url can be a local copy of the job's logs.


# Usage with prepared model

Workshop command (1 minute):

  logreduce job-run                            \
     --include-path controller/                \
     --html report-e9a003e.html                \
     _models/tempest-full.clf                  \
     _targets/tempest-full/e9a003e/

Expected output:

  99.76% reduction (from 64858 lines to 153)


Workshop command (6 minutes)

  logreduce job-run                            \
     --include-path controller/                \
     --html report-a8edc4f.html                \
     _models/tempest-full.clf                  \
     _targets/tempest-full/a8edc4f/

Expected output:

  99.81% reduction (from 234520 lines to 449)


# Explanation e9a003e

In this first example, the review (https://review.openstack.org/#/c/564007/)
adds the standard-attr-segment module from Neutron. The job is failing with:
  "[ERROR] /opt/stack/devstack/functions-common:2199 Neutron did not start"

In the report.html, an exception is found in controller/logs/screen-q-svc.txt.gz:
neutron-server[6473]: ERROR neutron ImportError: cannot import name standard_attr_segment


# Explanation a8edc4f

In this second example, the review (https://review.openstack.org/563555)
adds a new volume options. The job is failing with:
  "{0} tempest.api.volume.test_volumes_extend.VolumesExtendAttachedTest.test_extend_attached_volume [25.977745s] ... FAILED"

In the report.html, the exception is found in the job-output as well as in screen-n-cpu logs:
ERROR oslo_messaging.rpc.server VolumePathsNotFound: Could not find any paths for the volume.

Also, for some reason, the zuul worker user isn't part of the kvm group:
libguestfs: warning: current user is not a member of the KVM group (group ID 121). This user cannot access /dev/kvm, so libguestfs may run very slowly. It is recommended that you 'chmod 0666 /dev/kvm' or add the current user to the KVM group (you might need to log out and log in again).

Some others issues are reported in screen-placement-api.txt.gz and screen-q-dhcp.txt.gz
