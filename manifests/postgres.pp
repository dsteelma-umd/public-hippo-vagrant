Package {
  allow_virtual => false,
}

class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.5',
}->
class { 'postgresql::server': 
  listen_addresses  => '*',
  postgres_password => 'postgres',
}->

postgresql::server::db { 'hippo':
  user => 'hippo',
  owner => 'hippo',
  password => postgresql_password('hippo', 'hippo'),
  encoding => 'UNICODE',
}

postgresql::server::database_grant { 'hippo':
  privilege => 'ALL',
  db        => 'hippo',
  role      => 'hippo',
}

postgresql::server::pg_hba_rule { 'allow application network to access app database':
  description => 'Open up PostgreSQL for access from 192.168.55.0/24',
  type        => 'host',
  database    => 'hippo',
  user        => 'hippo',
  address     => '192.168.55.0/24',
  auth_method => 'md5',
}

firewall { '100 allow access to PostgreSQL':
  dport => [5432],
  proto => tcp,
  action => accept,
}
