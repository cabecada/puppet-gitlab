# == Class: gitlab::application
#
# Set up the GitLab application and initialize the database. Requires
# the database to exist.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::application {
  anchor { 'gitlab-pre-setup': }

  vcsrepo { 'gitlab':
    ensure   => present,
    provider => git,
    path     => "${gitlab::git_home}/gitlab",
    source   => 'https://github.com/gitlabhq/gitlabhq.git',
    revision => $gitlab::gitlabhq_revision,
    require  => User[$gitlab::git_user],
    before   => Anchor['gitlab-pre-setup'],
  }

  file { 'gitlab-config':
    ensure  => present,
    path    => "${gitlab::git_home}/gitlab/config/gitlab.yml",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('gitlab/gitlab-config.yml.erb'),
    require => Vcsrepo['gitlab'],
    before  => Anchor['gitlab-pre-setup'],
  }

  file { [ "${gitlab::git_home}/gitlab/log",
           "${gitlab::git_home}/gitlab/tmp",
           "${gitlab::git_home}/gitlab/tmp/pids",
           "${gitlab::git_home}/gitlab/tmp/sockets",
           "${gitlab::git_home}/gitlab-satellites" ]:
    ensure  => directory,
    owner   => $gitlab::git_user,
    group   => $gitlab::git_group,
    mode    => '0755',
    require => Vcsrepo['gitlab'],
    before  => Anchor['gitlab-pre-setup'],
  }

  file { "${gitlab::git_home}/gitlab/config/puma.rb":
    ensure  => present,
    owner   => root,
    group   => root,
    content => template('gitlab/puma.rb.erb'),
    require => Vcsrepo['gitlab'],
    before  => Anchor['gitlab-pre-setup'],
  }

  file { 'gitlab-database-yml':
    ensure  => present,
    path    => "${gitlab::git_home}/gitlab/config/database.yml",
    owner   => root,
    group   => root,
    content => template('gitlab/database.yml.erb'),
    require => Vcsrepo['gitlab'],
    before  => Anchor['gitlab-pre-setup'],
  }

  exec { 'gitlab-install-bundle':
    command     => '/usr/bin/bundle install --deployment --without development test mysql',
    cwd         => "${gitlab::git_home}/gitlab",
    timeout     => 0,
    before      => Anchor['gitlab-pre-setup'],
    subscribe   => Vcsrepo['gitlab'],
    refreshonly => true,
  }

  exec { 'gitlab-setup':
    command     => '/usr/bin/bundle exec rake gitlab:setup RAILS_ENV=production force=yes',
    cwd         => "${gitlab::git_home}/gitlab",
    user        => $gitlab::git_user,
    group       => $gitlab::git_group,
    timeout     => 0,
    require     => Anchor['gitlab-pre-setup'],
    subscribe   => File['gitlab-database-yml'],
    refreshonly => true,
  }
}
