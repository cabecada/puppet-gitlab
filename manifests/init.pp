# == Class: gitlab
#
# The gitlab module allows you to install GitLab on your server. It can
# install the required packages, configure the git user, set up GitLab
# and configure nginx.
#
# === Parameters
#
# [*git_user*]
#   Specify which user to use for the GitLab (and git repository) hosting.
#
# [*git_group*]
#   The primary group for the git user.
#
# [*git_home*]
#   Specify where to host the GitLab repository and application.
#
# [*shell_revision*]
#   Specify which revision of gitlab-shell to use.
#
# [*gitlab_revision*]
#   Specify which revision of the gitlab application to use.
#
# [*create_db*]
#   Specify wether to create the database (and database user) or not. This
#   only works if your local database server is managed using
#   puppetlabs/postgresql.
#
# [*db_host*]
#   Specify which database server to connect to.
#
# [*db_port*]
#   Specify which port on the database server to connect to.
#
# [*db_name*]
#   Specify which database user to use.
#
# [*db_user*]
#   Specify which username to use when connecting to the database.
#
# [*db_pass*]
#   Specify which password to use when connecting to the database.
#
# [*webserver*]
#   When set to 'nginx', this module will use jfryman's nginx module to
#   configure a virtual host.
#
# [*www_scheme*]
#   Wether to use http or https (currently only http is supported).
#
# [*www_server*]
#   Specify which (virtual) hostname to use. Required even when not
#   configuring nginx.
#
# [*www_port*]
#   Specify which port on the server to listen on.
#
# [*www_path*]
#   Specify which (sub) page on the server to host the gitlab application
#   on. Currently does not support configuring nginx properly.
#
# [*www_ssl_cert*]
#   Path to SSL certificate (if www_scheme == https).
#
# [*www_ssl_key*]
#   Path to SSL key (if www_scheme == https).
#
# [*email_from*]
#   Specify which email address GitLab will use to send from mail.
#
# [*support_email*]
#   Email address of your support contact.
#
# [*default_projects_limit*]
#   Default projects limit.
#
# [*signup_enabled*]
#   Wether the signup option should be enabled.
#
# [*username_changing_enabled*]
#   Wether users are allowed to change their username.
#
# === Examples
#
#  class { gitlab:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab(
  $git_user                  = 'git',
  $git_group                 = 'git',
  $git_home                  = '/srv/git',

  $shell_revision            = 'fc55020536f738f253a4c21285e38fd59e549056', # v1.3.0
  $gitlab_revision           = '5-1-stable',

  $create_db                 = false,
  $db_host                   = 'localhost',
  $db_port                   = 5432,
  $db_name                   = 'gitlab',
  $db_user                   = 'git',
  $db_pass                   = 'gitlab',

  $webserver                 = 'nginx',
  $www_scheme                = 'http',
  $www_server                = $::fqdn,
  $www_port                  = undef,
  $www_path                  = '',
  $www_ssl_cert              = undef,
  $www_ssl_key               = undef,

  $email_from                = "root@${::fqdn}",
  $support_email             = "root@${::fqdn}",

  $default_projects_limit    = 10,
  $signup_enabled            = false,
  $username_changing_enabled = false,
) {
  $gitlab_url = "${www_scheme}://${www_server}/${www_path}"
  if $www_port == undef {
    case $www_scheme {
      https: { $www_port_real = 443 }
      default: { $www_port_real = 80 }
    }
  } else {
    $www_port_real = $www_port
  }

  if $create_db {
    require gitlab::database
  }

  require gitlab::packages
  include gitlab::user
  include gitlab::shell
  include gitlab::application
  include gitlab::service

  case $webserver {
    nginx: { include gitlab::nginx }
    default: { }
  }
}
