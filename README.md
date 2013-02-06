jenkins-devstack-plugin
=======================

A jenkins plugin which provisions an openstack instance, and installs devstack on it.


# Development
* `bundle install`
* `jpi server` - launch a dev jenkins server including the plugin.

# Packaging
* `jpi build`

# Gotchas:
* must be run with ruby 1.9: `export JRUBY_OPTS=--1.9` or `echo "compat.version=1.9" >> ~/.jrubyrc`

* jenkins builds 1.490 and newer require manual install of bouncycastle on jenkins server (until ruby-openssl or jenkins is fixed)

    ssh ubuntu@your-jenkins-server
    cd /var/cache/jenkins/war/WEB-INF/lib/
    sudo wget http://repo2.maven.org/maven2/org/bouncycastle/bcprov-jdk15/1.45/bcprov-jdk15-1.45.jar
    sudo chown jenkins:jenkins bcprov-jdk15-1.45.jar
    sudo service jenkins restart

