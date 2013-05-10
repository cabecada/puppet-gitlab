# == Class: gitlab::packages
#
# Ensure required packages are installed.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::packages {
  if $::operatingsystem != 'debian' {
    fail('Only debian supported for now.')
  }

  package { [
    'git-core',
    'build-essential',
    'bundler',
    'redis-server',
    'libxml2-dev',
    'libxslt1-dev',
    'libicu-dev',
    'libpq-dev',
  ]:
    ensure => present,
  }

  service { 'redis-server':
    ensure  => running,
    enable  => true,
    require => Package['redis-server'],
  }

  file { '/usr/bin/python2':
    ensure => link,
    target => '/usr/bin/python2.7',
  }
}
