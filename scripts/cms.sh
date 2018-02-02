#!/bin/bash

# First install mod_jk
sudo rpm -Uvh /vagrant/dist/apache2-mod_jk-1.2.37-4.1.x86_64.rpm

## Install mod_ssl
#sudo yum -y install mod_ssl openssl

## Install mod_auth_cas
#sudo yum -y install epel-release
#sudo yum -y install --enablerepo=epel mod_auth_cas

cp /vagrant/env/apache.tgz /apps/cms/
cd /apps/cms/
tar -xvzf apache.tgz

cp /vagrant/env/apache_bin.tar.gz /apps/cms/
cd /apps/cms/
tar -xvzf apache_bin.tar.gz

# Tomcat
mkdir -p /apps/cms/storage/workspaces
# directories needed by Tomcat
mkdir -p /apps/cms/tomcat/{logs,temp}

cp -r /apps/apache-tomcat-8.0.39/webapps/ /apps/cms/webapps/

#sudo chown -R vagrant:vagrant /apps/cms/tomcat
#sudo chown -R vagrant:vagrant /apps/cms/storage
#sudo chown -R vagrant:vagrant /apps/cms/webapps

# Copy public-hippo-cms-env config files into /apps/cms/
cp -r /apps/git/public-hippo-cms-env/* /apps/cms/

cd /apps/cms/
sudo chown -R vagrant:vagrant *

# Modify the apachectl executables.
cd /apps/cms/apache/bin
sudo chown root:vagrant /apps/cms/apache/bin/apachectl
sudo chmod 4755 /apps/cms/apache/bin/apachectl
sudo cp -p /usr/sbin/apachectl /apps/cms/apache/bin/apachectl.exec
sudo chown root:root /apps/cms/apache/bin/apachectl.exec

# Overwrite /apps/cms/apache/conf/env-variables
cat << EOF > /apps/cms/apache/conf/env-variables
# variables for cmsdev
export LISTEN_IP=192.168.55.10
export VIRTUAL_HOST_IP=192.168.55.10
export SERVER_NAME=192.168.55.10
export SSL_CERT_NAME=cmslocal
export SSL_KEY_NAME=cmslocal
EOF

# Fix lines in httpd.conf
sed -i "s/User cms/User vagrant/g" /apps/cms/apache/conf/httpd.conf
sed -i "s/Group cms/Group vagrant/g" /apps/cms/apache/conf/httpd.conf
sed -i "s/SSLCertificateChainFile/# SSLCertificateChainFile/g" /apps/cms/apache/conf/httpd.conf

sed -i "s/export JAVA_HOME=\/apps\/jdk1.8.0_112/export JAVA_HOME=\/apps\/java/g" /apps/cms/tomcat/control
