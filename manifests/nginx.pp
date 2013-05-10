# == Class: gitlab::nginx
#
# Set up an nginx virtual host for the GitLab application.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::nginx {
  nginx::resource::upstream { 'gitlab':
    ensure  => present,
    members => [
      "unix:/${gitlab::git_home}/gitlab/tmp/sockets/gitlab.socket",
    ],
  }

  $ssl = $gitlab::www_scheme ? {
    https => true,
    default => false,
  }

  case $gitlab::www_scheme {
    https: {
      nginx::resource::vhost { $gitlab::www_server:
        listen_port => $gitlab::www_port_real,
        www_root    => "${gitlab::git_home}/gitlab/public",
        index_files => [],
        try_files   => ['$uri', '$uri/index.html', '$uri.html', '@gitlab'],
        ssl         => true,
        ssl_cert    => $gitlab::www_ssl_cert,
        ssl_key     => $gitlab::www_ssl_key,
        ssl_port    => $gitlab::www_port_real,
      }
    }
    default: {
      nginx::resource::vhost { $gitlab::www_server:
        listen_port => $gitlab::www_port_real,
        www_root    => "${gitlab::git_home}/gitlab/public",
        index_files => [],
        try_files   => ['$uri', '$uri/index.html', '$uri.html', '@gitlab'],
      }
    }
  }

  $config = {
    'proxy_connect_timeout'              => 300,
    'proxy_redirect'                     => 'off',
    'proxy_set_header X-Forwarded-Proto' => '$scheme',
    'proxy_set_header Host'              => '$http_host',
    'proxy_set_header X-Real-IP'         => '$remote_addr',
  }

  nginx::resource::location { 'gitlab':
    ensure              => present,
    location            => '@gitlab',
    proxy               => 'http://gitlab',
    proxy_read_timeout  => 300,
    vhost               => $gitlab::www_server,
    location_cfg_append => $config,
    ssl                 => $ssl,
    ssl_only            => $ssl,
  }
}
