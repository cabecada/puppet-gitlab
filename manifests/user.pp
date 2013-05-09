# == Class: gitlab::user
#
# Create the gitlab user.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::user {
  group { $gitlab::git_group:
    ensure  => present,
    require => Package['git-core'],
  }

  user { $gitlab::git_user:
    ensure     => present,
    gid        => $gitlab::git_group,
    shell      => '/usr/sbin/nologin',
    home       => $gitlab::git_home,
    managehome => true,
    require    => Package['git-core'],
  }
}
