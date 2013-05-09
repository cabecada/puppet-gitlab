# == Class: gitlab::database
#
# Create a database for GitLab. Included by the gitlab class if the
# class parameter $create_db is true.
#
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen
#
class gitlab::database {
  postgresql::db { $gitlab::db_name:
    user     => $gitlab::db_user,
    password => postgresql_password($gitlab::db_user, $gitlab::db_pass),
  }
}
