Package {
  allow_virtual => false,
}

package { 'epel-release':
  ensure => present,
}

package { 'httpd':
  ensure => present,
}

package { 'mod_ssl':
  ensure  => present,
  require => Package['httpd'],
}
package { 'mod_auth_cas':
  ensure  => present,
  require => Package['epel-release'],
}
package { 'openssl':
  ensure => present,
}


host { 'cmslocal':
  ip => '192.168.55.10',
}

firewall { '100 allow http access to tomcat-cms':
  dport => [80, 443, 8091, 8205, 9600, 9603, 9604, 9605],
  proto => tcp,
  action => accept,
}
