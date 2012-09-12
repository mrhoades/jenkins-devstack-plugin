jenkins-devstack-plugin
=======================

A jenkins plugin which provisions an openstack instance, and installs devstack on it.


# Development
* `bundle install`
* `jpi server` - launch a dev jenkins server including the plugin.

# Gotchas:
* must be run with ruby 1.9: `export JRUBY_OPTS=--1.9``
