# Story

In this example, the user added a new config-download default to tripleo client
(https://review.openstack.org/558925) and the
tripleo-ci-centos-7-undercloud-oooq job is failing.

Unfortunately, the job-output doesn't help as it just shows:
"ERROR: the main setup script run by this job failed - exit code: 2"


# Usage

After getting all the logs of a successful run and the one of the failures,
the user can use logreduce to look for anomalies in services logs:

Workshop command (2 minutes):

  logreduce --debug diff --html report.html success-*/ failure-*/

Expected output:

# A model is trained for each file in success logs
[...]
logs/quickstart_install.txt: Loading success-fa2f567/logs/quickstart_install.txt.gz
logs/quickstart_install.txt: 243 samples, 1048576 features 0.049s at 0.349MB/s (6.337kl/s) (0.017 MB - 0.308 kilo-lines)
INFO  Classifier - Training took 186.749s at 0.179MB/s (0.895kl/s) (33.457 MB - 167.116 kilo-lines)
# Then each file is mapped to a model and tested for anomalies, e.g.:
[...]
logs/quickstart_install.txt: Testing failure-72c222c/logs/quickstart_install.txt.gz
logs/quickstart_install.txt.gz: compared with success-fa2f567/logs/quickstart_install.txt.gz
INFO  Classifier - Testing took 173.464s at 0.132MB/s (0.743kl/s) (22.952 MB - 128.882 kilo-lines)
99.68% reduction (from 128868 lines to 407)


# Explanation

* Some false positives are reported, as this job outputs some extra debug when
  it failed. For example the logs/quickstart_install.txt.gz can be ignored.

* The error was an incorrect URL for the config-download file as showed in the
  mistral service logs.

* Other interesting anomalies are reported:
0.229 | logs/undercloud/var/log/ironic/ironic-dbsync.log.txt.gz:0047:	2018-04-19 14:26:23.639 3627 WARNING ironic.drivers.base [req-473ef514-b991-4ca3-b834-bea49e723523 - - - - -] The "async" parameter is deprecated, please use "async_call" instead. The "async" parameter will be removed in the Stein cycle.

0.627 | logs/undercloud/var/log/neutron/l3-agent.log.txt.gz:0524:	2018-04-19 14:40:01.355 3105 WARNING pyroute2 [-] module pyroute2.ipdb.common is deprecated, use pyroute2.ipdb.exceptions instead

0.000 | logs/undercloud/home/zuul/undercloud_install.log.txt.gz:0527:	2018-04-19 14:17:40 | 2018-04-19 14:17:40,813 INFO: Warning: ModuleLoader: module 'keystone' has unresolved dependencies - it will only see those that are resolved. Use 'puppet module list --tree' to see information about modules
0.000 | logs/undercloud/home/zuul/undercloud_install.log.txt.gz:0528:	2018-04-19 14:17:40 | 2018-04-19 14:17:40,813 INFO:    (file & line not available)
0.000 | logs/undercloud/home/zuul/undercloud_install.log.txt.gz:0529:	2018-04-19 14:17:41 | 2018-04-19 14:17:41,459 INFO: Warning: This method is deprecated, please use the stdlib validate_legacy function,
0.254 | logs/undercloud/home/zuul/undercloud_install.log.txt.gz:0530:	2018-04-19 14:17:41 | 2018-04-19 14:17:41,460 INFO:                     with Stdlib::Compat::String. There is further documentation for validate_legacy function in the README. at ["/etc/puppet/modules/keystone/manifests/db/mysql.pp", 63]:
0.000 | logs/undercloud/home/zuul/undercloud_install.log.txt.gz:0531:	2018-04-19 14:17:41 | 2018-04-19 14:17:41,460 INFO:    (at /etc/puppet/modules/stdlib/lib/puppet/functions/deprecation.rb:28:in `deprecation')
