# == Class: gitlab::packages
#
# Set up the GitLab service and make sure it is running.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::service {
  file { '/etc/init.d/gitlab':
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('gitlab/gitlab-init.erb'),
  }

  service { 'gitlab':
    ensure  => running,
    enable  => true,
    require => [
      File['/usr/bin/python2'],
      File['/etc/init.d/gitlab'],
      Exec['gitlab-setup'],
    ]
  }
}
