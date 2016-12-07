package { 'httpd':
  ensure => present,
}

class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.5',
}->
class { 'postgresql::server': 
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

firewall { '100 allow http access to tomcat-cms':
  dport => [80, 9600, 9603, 9604, 9605],
  proto => tcp,
  action => accept,
}
firewall { '110 allow http access to tomcat-site':
  dport => [80, 9700, 9703, 9704, 9705],
  proto => tcp,
  action => accept,
}
