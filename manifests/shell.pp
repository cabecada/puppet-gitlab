# == Class: gitlab::shell
#
# Install the gitlab-shell.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::shell {
  vcsrepo { 'gitlab-shell':
    ensure   => present,
    provider => git,
    path     => "${gitlab::git_home}/gitlab-shell",
    source   => 'https://github.com/gitlabhq/gitlab-shell.git',
    revision => $gitlab::shell_revision,
    require  => User[$gitlab::git_user],
  }

  file { 'gitlab-shell-config':
    ensure  => present,
    path    => "${gitlab::git_home}/gitlab-shell/config.yml",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('gitlab/shell-config.yml.erb'),
    require => Vcsrepo['gitlab-shell'],
  }

  exec { "${gitlab::git_home}/gitlab-shell/bin/install":
    user        => $gitlab::git_user,
    refreshonly => true,
    subscribe   => [
      Vcsrepo['gitlab-shell'],
      File['gitlab-shell-config'],
    ]
  }
}
