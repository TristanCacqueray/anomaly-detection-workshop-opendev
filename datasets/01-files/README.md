# Story

In this example, the user created a disk image using this command
(dib-success.log):

$ disk-image-create -o test.qcow2 vm simple-init centos7

Then the user added a new rdo-repo elements to setup openstack-queens
repos (dib-failure.log):

$ disk-image-create -o test.qcow2 vm simple-init centos7 rdo-repo


# Usage

Using logreduce, the user can extract anomalies in the failure logs:

Workshop command (3 seconds):

  logreduce diff dib-success.log dib-failure.log

Expected output:

0.000 | dib-failure.log:0501:	2018-04-23 03:17:22.055 | dib-run-parts Running /tmp/in_target.d/pre-install.d/03-baseline-tools
0.000 | dib-failure.log:0502:	2018-04-23 03:17:22.058 | dib-run-parts 03-baseline-tools completed
0.125 | dib-failure.log:0503:	2018-04-23 03:17:22.060 | dib-run-parts Running /tmp/in_target.d/pre-install.d/03-install-openstack-release
0.667 | dib-failure.log:0504:	2018-04-23 03:17:22.061 | + echo 'This pre-install.d task setup centos-release-openstack-queens'
0.646 | dib-failure.log:0505:	2018-04-23 03:17:22.061 | This pre-install.d task setup centos-release-openstack-queens
0.553 | dib-failure.log:0506:	2018-04-23 03:17:22.061 | + yum install -y centos-release-openstack-queens
0.000 | dib-failure.log:0507:	2018-04-23 03:17:22.180 | Loaded plugins: fastestmirror

1.000 | dib-failure.log:1230:	2018-04-23 03:18:36.678 | Replaced:
0.423 | dib-failure.log:1231:	2018-04-23 03:18:36.678 |   python-babel.noarch 0:0.9.6-8.el7      python-jinja2.noarch 0:2.7.2-2.el7
0.423 | dib-failure.log:1232:	2018-04-23 03:18:36.678 |   python-jsonpatch.noarch 0:1.2-4.el7    python-jsonpointer.noarch 0:1.9-2.el7
0.423 | dib-failure.log:1233:	2018-04-23 03:18:36.678 |   python-markupsafe.x86_64 0:0.11-10.el7 python-requests.noarch 0:2.6.0-1.el7_1
0.333 | dib-failure.log:1234:	2018-04-23 03:18:36.678 |   python-setuptools.noarch 0:0.9.8-7.el7 python-six.noarch 0:1.9.0-2.el7
0.333 | dib-failure.log:1235:	2018-04-23 03:18:36.678 |   python-urllib3.noarch 0:1.10.2-3.el7
0.000 | dib-failure.log:1236:	2018-04-23 03:18:36.678 |

0.000 | dib-failure.log:2255:	2018-04-23 03:18:44.118 |  * epel: mirror.sfo12.us.leaseweb.net
0.000 | dib-failure.log:2256:	2018-04-23 03:18:44.120 |  * extras: mirror.keystealth.org
0.000 | dib-failure.log:2257:	2018-04-23 03:18:44.120 |  * updates: mirror.sfo12.us.leaseweb.net
0.250 | dib-failure.log:2258:	2018-04-23 03:18:44.570 | Package python-setuptools-0.9.8-7.el7.noarch is obsoleted by python2-setuptools-22.0.5-1.el7.noarch which is already installed
0.000 | dib-failure.log:2259:	2018-04-23 03:18:44.571 | Resolving Dependencies

INFO  Classifier - Testing took 0.926s at 0.250MB/s (2.484kl/s) (0.231 MB - 2.300 kilo-lines)
92.61% reduction (from 2300 lines to 170)


# Explanation

* The first blocks show the new pre-install.d script being copied and executed.

* Installing centos-release-openstack repository enables more recent packages,
  logreduce shows many packages being replaced by different versions.

* The last block is the culpit, not necessarly obvious because in that case
  the issue was tricky. It was fixed with: https://review.openstack.org/562936
