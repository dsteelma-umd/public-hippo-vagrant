package { 'httpd':
  ensure => present,
}

firewall { '110 allow http access to tomcat-site':
  dport => [80, 443, 9700, 9703, 9704, 9705],
  proto => tcp,
  action => accept,
}