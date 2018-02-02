# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # PostgreSQL server
  config.vm.define "postgres" do |postgres|
    postgres.vm.box = "puppetlabs/centos-6.6-64-puppet"
    postgres.vm.box_version = "1.0.1"

    postgres.vm.hostname = 'pglocal'

    postgres.vm.network "private_network", ip: "192.168.55.100"

    postgres.vm.provision "shell", inline: <<-SHELL
      # puppetlabs-stdlib is "pinned" to v4.22.0 for v4.9.0 of puppetlabs-postgresql
      puppet module install puppetlabs-stdlib --version 4.22.0
      # puppetlabs-firewall is "pinned" to v1.10.0 for v4.9.0 of puppetlabs-postgresql
      puppet module install puppetlabs-firewall --version 1.10.0
      puppet module install puppetlabs-postgresql --version 4.9.0
    SHELL

    postgres.vm.provision "puppet", manifest_file: 'postgres.pp', environment: 'local'
  end

  # CMS Server
  config.vm.define "cms" do |cms|
    cms.vm.box = "puppetlabs/centos-6.6-64-puppet"
    cms.vm.box_version = "1.0.1"

    cms.vm.provider "virtualbox" do |vb|
       vb.memory = "4096"
    end
    
    cms.vm.hostname = 'cmslocal'
    cms.vm.network "private_network", ip: "192.168.55.10"

    cms.vm.synced_folder "../public-hippo-cms-env", "/apps/git/public-hippo-cms-env"
    
    # Puppet Modules
    cms.vm.provision "shell", inline: <<-SHELL
      # puppetlabs-stdlib is "pinned" to v4.22.0 for "solr.pp"
      puppet module install puppetlabs-stdlib --version 4.22.0
      # puppetlabs-firewall is "pinned" to v1.10.0 for "solr.pp"
      puppet module install puppetlabs-firewall --version 1.10.0
    SHELL

    # system provisioning
    cms.vm.provision "puppet", manifest_file: 'cms.pp', environment: 'local'
    
    # JDK
    cms.vm.provision "shell", path: 'scripts/jdk.sh'
    
    cms.vm.provision "shell", path: 'scripts/cms-https-cert.sh'
        
    cms.vm.provision "shell", path: 'scripts/cms.sh'
    cms.vm.provision "shell", path: 'scripts/cms-hippo.sh', args: ENV["HIPPO_VERSION"] || [], privileged: false
  end

#  # Site
#  config.vm.define "site" do |site|
#    site.vm.box = "puppetlabs/centos-6.6-64-puppet"
#    site.vm.box_version = "1.0.1"
#
#    site.vm.hostname = 'wwwlocal'
#    site.vm.network "private_network", ip: "192.168.55.20"
#
#    # Puppet Modules
#    site.vm.provision "shell", inline: <<-SHELL
#      # puppetlabs-stdlib is "pinned" to v4.22.0 for "solr.pp"
#      puppet module install puppetlabs-stdlib --version 4.22.0
#      # puppetlabs-firewall is "pinned" to v1.10.0 for "solr.pp"
#      puppet module install puppetlabs-firewall --version 1.10.0
#    SHELL
#
#    # system provisioning
#    site.vm.provision "puppet", manifest_file: 'site.pp', environment: 'local'
#
#    # JDK
#    site.vm.provision "shell", path: 'scripts/jdk.sh'
#  end
end

